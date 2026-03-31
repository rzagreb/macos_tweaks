#!/bin/bash
# Creates an AppleScript-based macOS application that prompts for a URL,
# extracts an identifier from it (domain-like part), and creates a .url file.

app_name="CreateURL.app"
target_directory="/Applications/FinderApps"
source_icon_filepath="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns"

applescript_file="__temp.applescript"
app_filepath="$target_directory/$app_name"

compile_and_customize_app() {
    mkdir -p "$target_directory"
    osacompile -o "$app_filepath" "$applescript_file"

    if [ -f "$source_icon_filepath" ]; then
        cp "$source_icon_filepath" "$app_filepath/Contents/Resources/applet.icns"
    else
        echo "Icon file not found: $source_icon_filepath"
    fi

    rm "$applescript_file"
}

cat <<EOF > "$applescript_file"
on run
    -- Get the current Finder window's target folder
    tell application "Finder"
        if (count of windows) = 0 then
            display dialog "No Finder windows are open." buttons {"OK"} default button "OK"
            return
        end if
        set currentFolder to (target of window 1) as alias
    end tell

    -- Prompt for URL
    display dialog "Enter the URL:" default answer "https://"
    set theURL to text returned of the result

    -- Extract everything after '://'
    -- e.g. "https://www.example.com/1/2" -> "www.example.com/1/2"
    set AppleScript's text item delimiters to "://"
    set tempList to text items of theURL
    set tempURL to item 2 of tempList


    -- Extract everything befiore the first '/'
    -- e.g. "www.example.com/1/2" -> "www.example.com"

    set AppleScript's text item delimiters to "/"

    -- Split at first '/'
    set AppleScript's text item delimiters to "/"
    set domain to item 1 of tempURL

    -- Remove leading "www."
    if domain begins with "www." then
        set domain to text 5 thru (length of domain) of domain
    end if

    -- Build the .url content
    set urlContent to "[InternetShortcut]
URL=" & theURL & "
"

    -- Define the path for the .url file
    set urlPath to (currentFolder as text) & domain & ".url"

    -- Write the .url file
    try
        set fileRef to open for access file urlPath with write permission
        set eof of fileRef to 0
        write urlContent to fileRef
        close access fileRef
    on error errMsg number errNum
        try
            close access file urlPath
        end try
        display dialog "Error creating .url file: " & errMsg buttons {"OK"} default button "OK"
        return
    end try

    -- Reveal the newly created file in Finder
    tell application "Finder"
        reveal file urlPath
        activate
    end tell
end run
EOF

compile_and_customize_app
open "$target_directory"
