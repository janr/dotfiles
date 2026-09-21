import importlib.machinery
import importlib.util
from pathlib import Path
from types import SimpleNamespace
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
    def test_uncorked_sink_input_is_active(self):
        output = """Sink Input #42
\tDriver: PipeWire
\tSink: 51
\tCorked: no
"""
        self.assertEqual(focal_keepalive.active_sink_indexes(output), {"51"})

    def test_corked_sink_input_is_ignored(self):
        output = """Sink Input #42
\tSink: 51
\tCorked: yes
Sink Input #43
\tSink: 52
\tCorked: no
"""
        self.assertEqual(focal_keepalive.active_sink_indexes(output), {"52"})

    def test_stream_without_corked_field_is_treated_as_active(self):
        output = """Sink Input #42
\tSink: 51
"""
        self.assertEqual(focal_keepalive.active_sink_indexes(output), {"51"})

    def test_no_sink_inputs_means_no_active_sinks(self):
        self.assertEqual(focal_keepalive.active_sink_indexes(""), set())

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
