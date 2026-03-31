#!/bin/bash
# Creates an AppleScript-based macOS application that creates a new file in the Finder.

app_name="CreateProjectFolder.app"
target_directory="/Applications/FinderApps"
source_icon_filepath=/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericFolderIcon.icns

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
on create_home_folder()
	set timeStamp to do shell script "date +%y%m%d_%H%M%S"
	
	-- Validate that Finder is Open
	try
		tell application "Finder" to set currentDirectory to target of Finder window 1
	on error
		display dialog "There is no open Finder window."
		return
	end try
	
	set baseFolderName to timeStamp
	set indexLetter to 0
	set folderCreated to false
	
	-- Create Folder
	-- Determine whether _all exists in current folder
	set useAllFolder to false
	tell application "Finder"
		if exists folder "_all" of currentDirectory then
			set useAllFolder to true
			set targetDirectory to folder "_all" of currentDirectory
		else
			set targetDirectory to currentDirectory
		end if
	end tell

	repeat while folderCreated is false
		if indexLetter = 0 then
			set folderName to baseFolderName
		else
			set folderName to baseFolderName & "_" & character id (64 + indexLetter)
		end if
		
		tell application "Finder"
			if not (exists folder folderName of targetDirectory) then
				set newFolder to make new folder at targetDirectory with properties {name:folderName}
				set folderCreated to true
			end if
		end tell
		
		set indexLetter to indexLetter + 1
	end repeat
	
	-- If using _all, place alias in current folder for convenience
	if useAllFolder then
		tell application "Finder"
			set aliasName to folderName & ""
			if not (exists alias file aliasName of currentDirectory) then
				make new alias file at currentDirectory to newFolder with properties {name:aliasName}
			end if
		end tell
	end if

	return newFolder
end create_home_folder

-- Create Project home folder
set home_dir to create_home_folder()

-- Create an empty README.md file in the project folder
set home_dir_path to POSIX path of (home_dir as alias)
do shell script "touch " & quoted form of (home_dir_path & "README.md")

EOF

compile_and_customize_app
open $target_directory