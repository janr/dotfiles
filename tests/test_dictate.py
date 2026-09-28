"""Tests for local dictation without a microphone or compositor."""

import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest
import wave
from unittest.mock import MagicMock, patch


SCRIPT = Path(__file__).resolve().parents[1] / "bin/.local/bin/dictate"
loader = importlib.machinery.SourceFileLoader("dictate", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
dictate = importlib.util.module_from_spec(spec)
loader.exec_module(dictate)


class DictationTests(unittest.TestCase):
    def test_valid_wav_is_accepted_despite_sigint_exit_status(self):
        with tempfile.TemporaryDirectory() as directory:
            wav = Path(directory) / "speech.wav"
            with wave.open(str(wav), "wb") as audio:
                audio.setnchannels(1)
                audio.setsampwidth(2)
                audio.setframerate(16000)
                audio.writeframes(b"\x00\x00" * 1600)
            dictate.validate_recording(wav, 1, Path(directory) / "missing.log")
            with self.assertRaisesRegex(RuntimeError, "exit 1"):
                dictate.validate_recording(Path(directory) / "missing.wav", 1,
                                           Path(directory) / "missing.log")

    def test_transcribe_reads_whisper_text_file(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "speech"
            output.with_suffix(".txt").write_text("  hello world  \n")
            with patch.object(dictate.subprocess, "run") as run:
                self.assertEqual(dictate.transcribe(Path(directory) / "speech.wav", output),
                                 "hello world")
                args = run.call_args.args[0]
                self.assertIn("-otxt", args)
                self.assertEqual(args[args.index("-of") + 1], str(output))

    def test_multiline_transcript_uses_shift_enter_then_submits_once(self):
        with patch.object(dictate.subprocess, "run") as run:
            dictate.insert_text("first\r\nsecond\rthird\nfourth", submit=True)
        self.assertEqual([call.args[0] for call in run.call_args_list], [
            ["wtype", "--", "first"],
            ["wtype", "-M", "shift", "-k", "Return", "-m", "shift"],
            ["wtype", "--", "second"],
            ["wtype", "-M", "shift", "-k", "Return", "-m", "shift"],
            ["wtype", "--", "third"],
            ["wtype", "-M", "shift", "-k", "Return", "-m", "shift"],
            ["wtype", "--", "fourth"],
            ["wtype", "-k", "Return"],
        ])

    def test_shortcut_does_not_submit_and_preserves_blank_lines(self):
        with patch.object(dictate.subprocess, "run") as run:
            dictate.insert_text("hello\n\nworld")
        self.assertEqual([call.args[0] for call in run.call_args_list], [
            ["wtype", "--", "hello"],
            ["wtype", "-M", "shift", "-k", "Return", "-m", "shift"],
            ["wtype", "-M", "shift", "-k", "Return", "-m", "shift"],
            ["wtype", "--", "world"],
        ])

    def test_single_line_submission_and_failed_typing(self):
        with patch.object(dictate.subprocess, "run") as run:
            dictate.insert_text("hello", submit=True)
            self.assertEqual([call.args[0] for call in run.call_args_list],
                             [["wtype", "--", "hello"], ["wtype", "-k", "Return"]])
            run.reset_mock()
            run.side_effect = OSError("typing failed")
            with self.assertRaises(OSError):
                dictate.insert_text("hello", submit=True)
            run.assert_called_once()

    def test_focus_change_discards_text(self):
        with tempfile.TemporaryDirectory() as directory:
            model = Path(directory) / "model.bin"
            model.touch()
            proc = MagicMock(returncode=0)
            proc.poll.return_value = 0
            server = MagicMock()
            server.accept.return_value = (MagicMock(), None)
            with patch.object(dictate, "MODEL", model), \
                 patch.object(dictate, "active_window", side_effect=["0x1", "0x2"]), \
                 patch.object(dictate, "transcribe", return_value="hello"), \
                 patch.object(dictate, "notify") as notify, \
                 patch.object(dictate.subprocess, "Popen", return_value=proc), \
                 patch.object(dictate.subprocess, "run") as run, \
                 patch.object(dictate, "tempfile") as temp:
                temp.TemporaryDirectory.return_value.__enter__.return_value = directory
                # pw-record's output exists after the recorder exits.
                with wave.open(str(Path(directory) / "speech.wav"), "wb") as audio:
                    audio.setnchannels(1)
                    audio.setsampwidth(2)
                    audio.setframerate(16000)
                    audio.writeframes(b"\x00\x00" * 1600)
                proc.returncode = 1  # pw-record returns 1 on SIGINT here
                server.accept.return_value[0].recv.return_value = b"stop"
                dictate.record_and_insert(server)
                run.assert_not_called()
                self.assertIn("Focus changed", notify.call_args.args[1])


if __name__ == "__main__":
    unittest.main()
