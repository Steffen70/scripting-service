#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDIR="$DIR/lib/generated"

# Clean the output directory
if [ -d "$OUTDIR" ]; then
  # Remove only auto-generated proto files, keep manual barrels
  find "$OUTDIR" -type f -name '*pb*.dart' -delete
else
  # Create output directory
  mkdir -p "$OUTDIR"
fi

# Generate Dart stubs
protoc \
  --proto_path="$DIR/../protos" \
  --dart_out="grpc:$OUTDIR" \
  "$DIR/../protos/common/common.proto" \
  "$DIR/../protos/invoker.proto"

echo "Generated Dart protobuf stubs in $OUTDIR"
