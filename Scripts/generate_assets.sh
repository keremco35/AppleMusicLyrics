#!/bin/bash
set -e

echo "Generating large assets for 100MB target..."
mkdir -p Apps/App/Resources

# Create a 50MB dummy ML model
dd if=/dev/urandom of=Apps/App/Resources/LyricsModel.mlmodel bs=1M count=50

# Create a 40MB offline cache pre-seed
dd if=/dev/zero of=Apps/App/Resources/OfflineCache.db bs=1M count=40

# Create 20MB of high-res textures (dummy)
dd if=/dev/urandom of=Apps/App/Resources/BackgroundTextures.assets bs=1M count=20

echo "Assets generated. Total size check:"
du -sh Apps/App/Resources/*
