#!/bin/bash
# Helper script to move project out of Desktop to avoid macOS restrictions

echo "🔧 Moving project out of Desktop folder..."
echo ""

# Source and destination
SOURCE_DIR="$HOME/Desktop/new-vue3/webui-vue"
DEST_DIR="$HOME/Projects/webui-vue"

# Check if source exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Source directory not found: $SOURCE_DIR"
    echo "Please update SOURCE_DIR in this script to match your project location"
    exit 1
fi

# Create Projects directory if it doesn't exist
mkdir -p "$HOME/Projects"

# Check if destination already exists
if [ -d "$DEST_DIR" ]; then
    echo "⚠️  Destination already exists: $DEST_DIR"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 1
    fi
    rm -rf "$DEST_DIR"
fi

# Move the project
echo "Moving $SOURCE_DIR"
echo "    to $DEST_DIR"
mv "$SOURCE_DIR" "$DEST_DIR"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Project moved successfully!"
    echo ""
    echo "📝 Next steps:"
    echo "1. In the Firefox extension, use this path:"
    echo "   $DEST_DIR"
    echo ""
    echo "2. If you want to keep using the Desktop location, create a symlink:"
    echo "   ln -s $DEST_DIR $SOURCE_DIR"
    echo ""
else
    echo "❌ Failed to move project"
    exit 1
fi

