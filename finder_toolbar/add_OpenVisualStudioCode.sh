#!/bin/bash
# Creates an AppleScript-based macOS application that opens the Visual Studio Code from a specific directory.

app_name="OpenVisualStudioCode.app"
target_directory="/Applications/FinderApps"
source_icon_filepath="/Applications/Visual Studio Code.app/Contents/Resources/Code.icns"

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
	set currentFolder to (folder of the front window) as alias
	tell application "Visual Studio Code"
		open currentFolder
	end tell
end tell
EOF

compile_and_customize_app
open $target_directory