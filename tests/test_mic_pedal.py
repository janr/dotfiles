import importlib.machinery
import importlib.util
from pathlib import Path
import sys
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock, patch


SCRIPT = Path(__file__).parents[1] / "bin/.local/bin/mic-pedal"
loader = importlib.machinery.SourceFileLoader("mic_pedal", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
mic_pedal = importlib.util.module_from_spec(spec)
assert spec and spec.loader
sys.modules[loader.name] = mic_pedal
spec.loader.exec_module(mic_pedal)


class PedalStateTests(unittest.TestCase):
    def test_default_is_push_to_mute(self):
        state = mic_pedal.PedalState()
        self.assertEqual(state.mode, "ptm")
        self.assertFalse(state.muted)
        state.set_pressed(True)
        self.assertTrue(state.muted)
        state.set_pressed(False)
        self.assertFalse(state.muted)

    def test_assistant_is_push_to_talk(self):
        state = mic_pedal.PedalState(assistant=True)
        self.assertTrue(state.muted)
        state.set_pressed(True)
        self.assertFalse(state.muted)
        state.set_pressed(False)
        self.assertTrue(state.muted)

    def test_duplicate_events_are_idempotent(self):
        state = mic_pedal.PedalState()
        self.assertTrue(state.set_pressed(True))
        self.assertFalse(state.set_pressed(True))
        self.assertTrue(state.set_pressed(False))
        self.assertFalse(state.set_pressed(False))

    def test_dictation_keeps_microphone_live(self):
        state = mic_pedal.PedalState(assistant=True, pressed=True, dictating=True)
        self.assertEqual(state.mode, "dictation")
        self.assertFalse(state.muted)
        state.dictating = False
        self.assertFalse(state.muted)  # assistant PTT is still held
        state.set_pressed(False)
        self.assertTrue(state.muted)

    def test_mode_change_while_held_recomputes_mute(self):
        state = mic_pedal.PedalState(pressed=True)
        self.assertTrue(state.muted)
        state.set_assistant(True)
        self.assertFalse(state.muted)


class DetectionTests(unittest.TestCase):
    def setUp(self):
        self.config = mic_pedal.Config(
            device="/dev/null",
            pedal_key="KEY_F13",
            target="source",
            assistant_patterns=("chatgpt", "claude"),
            browser_patterns=("firefox", "zen"),
            poll_interval=0.5,
            notifications=False,
        )

    def test_terminal_detection_matches_class_not_title(self):
        daemon = mic_pedal.Daemon(self.config, Path("/tmp"))
        with patch.object(mic_pedal.subprocess, "run") as run:
            run.return_value.stdout = '{"class": "kitty", "title": "Google Meet"}'
            self.assertTrue(daemon.terminal_focused())
            run.return_value.stdout = '{"class": "firefox", "title": "kitty"}'
            self.assertFalse(daemon.terminal_focused())

    def test_pedal_press_and_release_latches_dictation(self):
        daemon = mic_pedal.Daemon(self.config, Path("/tmp"))
        daemon.device = MagicMock()
        ecodes = SimpleNamespace(EV_KEY=1)
        daemon.key_code = 48
        with patch.dict(sys.modules, {"evdev": SimpleNamespace(ecodes=ecodes)}), \
             patch.object(daemon, "terminal_focused", side_effect=[True]) as focused, \
             patch.object(daemon, "start_dictation", return_value=True) as start, \
             patch.object(daemon, "stop_dictation") as stop, \
             patch.object(daemon, "apply_state"):
            daemon.device.read.return_value = [SimpleNamespace(type=1, code=48, value=1)]
            daemon.read_device(None, 0)
            daemon.state.dictating = True  # start_dictation mock skips its side effect
            daemon.device.read.return_value = [SimpleNamespace(type=1, code=48, value=0)]
            daemon.read_device(None, 0)
            focused.assert_called_once()
            start.assert_called_once()
            stop.assert_called_once()

    def test_dictation_commands_use_sibling_executable_not_service_path(self):
        daemon = mic_pedal.Daemon(self.config, Path("/tmp"))
        with patch.object(mic_pedal.subprocess, "Popen") as popen, \
             patch.object(mic_pedal.subprocess, "run") as run:
            popen.return_value.poll.return_value = 1
            popen.return_value.returncode = 1
            with patch.object(daemon, "log"):
                self.assertFalse(daemon.start_dictation())
            self.assertEqual(popen.call_args.args[0], [mic_pedal.DICTATE, "start", "--submit"])
            daemon.state.dictating = True
            daemon.stop_dictation()
            self.assertEqual(run.call_args.args[0], [mic_pedal.DICTATE, "stop"])
            self.assertTrue(Path(mic_pedal.DICTATE).is_absolute())

    def test_native_assistant_capture(self):
        blocks = ['application.name = "Claude"']
        self.assertTrue(mic_pedal.assistant_from_observations(blocks, "", self.config))

    def test_browser_assistant_must_be_active(self):
        blocks = ['application.name = "Firefox"']
        self.assertTrue(
            mic_pedal.assistant_from_observations(
                blocks, '{"title":"ChatGPT"}', self.config
            )
        )
        self.assertFalse(
            mic_pedal.assistant_from_observations(
                blocks, '{"title":"Google Meet"}', self.config
            )
        )

    def test_assistant_window_without_capture_is_not_assistant_mode(self):
        self.assertFalse(
            mic_pedal.assistant_from_observations(
                [], '{"title":"Claude"}', self.config
            )
        )

    def test_corked_capture_is_ignored(self):
        output = """Source Output #1
\tCorked: yes
\tapplication.name = \"Claude\"
Source Output #2
\tCorked: no
\tapplication.name = \"Google Chrome\"
"""
        self.assertEqual(len(mic_pedal.active_capture_blocks(output)), 1)


if __name__ == "__main__":
    unittest.main()
