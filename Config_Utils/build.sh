#!/bin/bash
# Auto-generated build script for KV260 Configurator

echo "Compiling config.c to config.so..."
# Assuming aarch64-linux-gnu-gcc is available, or just gcc if compiling on board
if command -v aarch64-linux-gnu-gcc &> /dev/null; then
    CC=aarch64-linux-gnu-gcc
else
    CC=gcc
fi

$CC -o config.so -shared -fPIC config.c

if [ $? -eq 0 ]; then
    echo "----------------------------------------"
    echo "Build successful! Output: config.so"
    echo "Usage:"
    echo "  1. Use Python (ctypes) or C to load ./config.so"
    echo "  2. Call 'dma_transfer_one_input' with physical addresses."
    echo "----------------------------------------"
else
    echo "Build failed."
    exit 1
fi
