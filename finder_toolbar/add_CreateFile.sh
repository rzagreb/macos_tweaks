#!/bin/bash
# Creates an AppleScript-based macOS application that creates a new file in the Finder.

app_name="CreateFile.app"
target_directory="/Applications/FinderApps"
source_icon_filepath=/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ClippingUnknown.icns

applescript_file="__temp.applescript"
app_filepath="$target_directory/$app_name"

compile_and_customize_app() {
    # Compile the AppleScript into an application
    mkdir -p "$target_directory"
    osacompile -o "$app_filepath" "$applescript_file"

    # Add Icon
    if [ -f "$source_icon_filepath" ]; then
        cp "$source_icon_filepath" "$app_filepath/Contents/Resources/applet.icns"
    else
        echo "Icon file not found: $source_icon_filepath"
    fi

    # Clean up
    rm "$applescript_file"
}

cat <<EOF > "$applescript_file"
tell application "Finder"
	set firstWindow to window 1
	set currentFolder to (target of firstWindow as alias)
	set newFile to make new file at folder currentFolder
end tell
EOF

compile_and_customize_app
open $target_directory