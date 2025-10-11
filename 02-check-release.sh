#!/bin/bash

FILES=(
    "maven-sources.json"
    "static/yarn.lock"
    "generated-sources.json"
)

errors=0
for (( i = 0; i < ${#FILES[@]}; i++ )); do
    # []\n\0 is just 4 bytes
    f="${FILES[$i]}"
    if [ ! -f "$f" ]; then
        echo The file "$f" does not exist>&2
        errors=1
        continue
    fi
    fsize=$(stat -c%s "$f")
    if (( fsize <= 4 )); then
        echo The file "$f" seems to be empty>&2
        cat "$f"
        errors=1
    fi
done

exit $errors

