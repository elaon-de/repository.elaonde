#!/usr/bin/env bash

CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
echo "Changed files: $CHANGED_FILES"
ZIP_PATH=$(echo "$CHANGED_FILES" | grep -E '^webroot/.+\.zip$' || true)

if [ -n "$ZIP_PATH" ]; then
    DATADIR=$(echo "$ZIP_PATH" | cut -d'/' -f2);
    echo "Found ZIP $ZIP_PATH, datadir $DATADIR";
    ./tools/create_repository.py --datadir webroot/$DATADIR/ $ZIP_PATH;
else
    echo "No ZIP file changed";
fi