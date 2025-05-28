#!/bin/bash

# Test script for unified Docker build
set -e

echo "Testing unified Docker build for opbnb project..."

# Test unified image build
echo "Building unified opbnb image..."
docker build --platform linux/amd64 -t opbnb-unified:test .

echo "Testing if all components are present in the image..."

# Test if all binaries exist in the image
echo "Checking op-node binary..."
docker run --rm opbnb-unified:test ls -la /app/op-node

echo "Checking op-batcher binary..."
docker run --rm opbnb-unified:test ls -la /app/op-batcher

echo "Checking op-proposer binary..."
docker run --rm opbnb-unified:test ls -la /app/op-proposer

# Test if binaries can run (show help/version)
echo "Testing op-node binary..."
docker run --rm opbnb-unified:test /app/op-node --help | head -5

echo "Testing op-batcher binary..."
docker run --rm opbnb-unified:test /app/op-batcher --help | head -5

echo "Testing op-proposer binary..."
docker run --rm opbnb-unified:test /app/op-proposer --help | head -5

echo "All components are working correctly!"

# Clean up test image
echo "Cleaning up test image..."
docker rmi opbnb-unified:test

echo "Unified image test completed successfully!"
echo ""
echo "Usage examples:"
echo "  docker run ghcr.io/zypher-game/opbnb:latest ./op-node [args]"
echo "  docker run ghcr.io/zypher-game/opbnb:latest ./op-batcher [args]"
echo "  docker run ghcr.io/zypher-game/opbnb:latest ./op-proposer [args]" 