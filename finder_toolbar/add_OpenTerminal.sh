#!/bin/bash
# Creates an AppleScript-based macOS application that opens the Terminal and sets its working directory to the current Finder window

app_name="OpenTerminal.app"
target_directory="/Applications/FinderApps"
source_icon_filepath=/System/Applications/Utilities/Terminal.app/Contents/Resources/Terminal.icns

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
	set currentFolder to (quoted form of POSIX path of (target of firstWindow as alias))
	tell application "Terminal"
		activate
		tell window 1
			do script "cd " & currentFolder
		end tell
	end tell
end tell
EOF

compile_and_customize_app
open $target_directory