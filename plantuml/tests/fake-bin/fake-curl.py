import os
import sys

sys.stdin.buffer.read()
status = os.environ.get("FAKE_STATUS", "200")
sys.stdout.buffer.write(b"\x89PNG\r\n\x1a\nIASI-TEST")
sys.stdout.buffer.write(
    f"\nIASI_PLANTUML_HTTP_STATUS:{status}".encode("ascii")
)
