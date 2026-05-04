#!/bin/bash
# Simple script to create placeholder icons using ImageMagick
# If you don't have ImageMagick, you can create icons manually or use online tools

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick not found. Please install it with: brew install imagemagick"
    echo "Or create icons manually (48x48 and 96x96 PNG files)"
    exit 1
fi

# Create 48x48 icon
convert -size 48x48 xc:none -fill "#0066cc" -draw "circle 24,24 24,4" \
    -fill white -pointsize 24 -gravity center -annotate +0+0 "🚀" \
    icon-48.png

# Create 96x96 icon
convert -size 96x96 xc:none -fill "#0066cc" -draw "circle 48,48 48,8" \
    -fill white -pointsize 48 -gravity center -annotate +0+0 "🚀" \
    icon-96.png

echo "Icons created successfully!"

