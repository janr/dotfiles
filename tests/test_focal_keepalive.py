import importlib.machinery
import importlib.util
from pathlib import Path
from types import SimpleNamespace
import subprocess
import sys
import unittest
from unittest import mock


SCRIPT = Path(__file__).parents[1] / "bin/.local/bin/focal-keepalive"
loader = importlib.machinery.SourceFileLoader("focal_keepalive", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
focal_keepalive = importlib.util.module_from_spec(spec)
assert spec and spec.loader
sys.modules[loader.name] = focal_keepalive
spec.loader.exec_module(focal_keepalive)


class PlaybackDetectionTests(unittest.TestCase):
    @mock.patch.object(focal_keepalive.subprocess, "run")
    def test_nonzero_monitor_sample_is_audio(self, run):
        run.side_effect = subprocess.TimeoutExpired(
            "parec", 1, output=b"\x00\x00\x01\x00"
        )

        self.assertTrue(focal_keepalive.sink_has_audio("focusrite"))

    @mock.patch.object(focal_keepalive.subprocess, "run")
    def test_zero_monitor_samples_are_silence(self, run):
        run.side_effect = subprocess.TimeoutExpired(
            "parec", 1, output=b"\x00\x00\x00\x00"
        )

        self.assertFalse(focal_keepalive.sink_has_audio("focusrite"))

    @mock.patch.object(focal_keepalive.subprocess, "run")
    def test_monitor_failure_is_unknown(self, run):
        run.side_effect = subprocess.CalledProcessError(1, "parec")

        self.assertIsNone(focal_keepalive.sink_has_audio("focusrite"))

    @mock.patch.object(
        focal_keepalive, "sink_has_audio", side_effect=[False, True]
    )
    def test_playing_sink_indexes_uses_monitor_signal(self, has_audio):
        sinks = [("51", "idle-focusrite"), ("52", "busy-focusrite")]

        self.assertEqual(focal_keepalive.playing_sink_indexes(sinks), {"52"})
        self.assertEqual(
            has_audio.call_args_list,
            [mock.call("idle-focusrite"), mock.call("busy-focusrite")],
        )

    @mock.patch.object(focal_keepalive.subprocess, "run")
    @mock.patch.object(focal_keepalive, "pulse", return_value=b"tone")
    @mock.patch.object(focal_keepalive, "playing_sink_indexes", return_value={"51"})
    @mock.patch.object(
        focal_keepalive,
        "focusrite_sinks",
        return_value=[("51", "busy-focusrite"), ("52", "idle-focusrite")],
    )
    @mock.patch.object(
        focal_keepalive,
        "arguments",
        return_value=SimpleNamespace(frequency=20_000, volume=0.9, duration=2),
    )
    def test_main_only_plays_to_idle_sinks(
        self, _arguments, _sinks, _playing, _pulse, run
    ):
        run.return_value.returncode = 0

        self.assertEqual(focal_keepalive.main(), 0)
        _playing.assert_called_once_with(
            [("51", "busy-focusrite"), ("52", "idle-focusrite")]
        )
        run.assert_called_once()
        self.assertEqual(run.call_args.args[0][-2:], ["idle-focusrite", "-"])

    @mock.patch.object(focal_keepalive, "pulse")
    @mock.patch.object(focal_keepalive, "playing_sink_indexes", return_value=None)
    @mock.patch.object(
        focal_keepalive,
        "focusrite_sinks",
        return_value=[("51", "focusrite")],
    )
    @mock.patch.object(focal_keepalive, "arguments", return_value=mock.sentinel.args)
    def test_main_does_not_generate_tone_when_activity_check_fails(
        self, _arguments, _sinks, _playing, pulse
    ):
        self.assertEqual(focal_keepalive.main(), 0)
        pulse.assert_not_called()


if __name__ == "__main__":
    unittest.main()
