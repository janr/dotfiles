import importlib.machinery
import importlib.util
from pathlib import Path
import sys
import unittest


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
