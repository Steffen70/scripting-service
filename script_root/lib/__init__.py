import sys
import argparse
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent / "generated"))

from generated import DemoScriptContext, DemoScriptResult


def read_context(context_file: str) -> DemoScriptContext:
    """Read and deserialize context protobuf from file."""
    with open(context_file, 'rb') as f:
        context = DemoScriptContext()
        context.ParseFromString(f.read())
        return context


def write_response(response_file: str, result: DemoScriptResult) -> None:
    """Serialize and write response protobuf to file."""
    with open(response_file, 'wb') as f:
        f.write(result.SerializeToString())


def get_script_args() -> tuple[str, str]:
    """Parse --context and --response arguments."""
    parser = argparse.ArgumentParser()
    parser.add_argument('--context', required=True)
    parser.add_argument('--response', required=True)
    args = parser.parse_args()
    return args.context, args.response
