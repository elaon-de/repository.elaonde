#!/usr/bin/env bash
set -euo pipefail

WEBROOT="webroot"
REPOTOOL="./tools/create_repository.py"

# Gehe durch alle Repos in webroot (z.B. repo-testing, repo)
for REPO in "$WEBROOT"/*/; do
    REPO_NAME=$(basename "$REPO")
    echo "Processing repo: $REPO_NAME"

    ZIP_ARGS=()  # Array, um alle neuesten ZIPs in diesem Repo zu sammeln

    # Gehe durch alle Addon-Unterordner im Repo
    for ADDON in "$REPO"*/; do
        ADDON_NAME=$(basename "$ADDON")

        # Finde alle ZIP-Dateien im Addon-Ordner
        ZIP_FILES=( "$ADDON"*.zip )

        # Prüfen, ob ZIPs gefunden wurden
        # ${ZIP_FILES[0]} == literal Glob, wenn keine Dateien existieren
        if [ ! -e "${ZIP_FILES[0]}" ]; then
            echo "  No ZIPs in addon $ADDON_NAME"
            continue
        fi

        # ZIP mit der höchsten Version ermitteln
        LATEST_ZIP=$(printf "%s\n" "${ZIP_FILES[@]}" | sort -V | tail -n1)
        echo "  Latest ZIP for $ADDON_NAME: $LATEST_ZIP"

        ZIP_ARGS+=( "$LATEST_ZIP" )
    done

    # Wenn mindestens ein ZIP gefunden wurde, create_repository.py aufrufen
    if [ ${#ZIP_ARGS[@]} -gt 0 ]; then
        echo "Running create_repository.py for repo $REPO_NAME with ZIPs: ${ZIP_ARGS[*]}"
        echo $REPOTOOL --datadir "$REPO" "${ZIP_ARGS[@]}"
        $REPOTOOL --datadir "$REPO" "${ZIP_ARGS[@]}"
    else
        echo "  No ZIPs found in repo $REPO_NAME"
    fi
done
