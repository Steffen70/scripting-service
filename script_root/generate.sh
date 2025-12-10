#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDIR="$DIR/generated"

# Create or clean the output directory
if [ -d "$OUTDIR" ]; then
  rm -f "$OUTDIR"/**/*pb2*
else
  mkdir -p "$OUTDIR"
fi

# Generate Python protobufs
pipenv run python -m grpc_tools.protoc \
  -I "$DIR/../protos" \
  --python_out="$OUTDIR" \
  --pyi_out="$OUTDIR" \
  "$DIR/../protos/common/common.proto"
