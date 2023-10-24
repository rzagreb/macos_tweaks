# Do you like dark theme on macOS but still prefer light theme in other apps? This script disables dark theme in Finder and other apps.

# Replace "Notes" with the name of your app
BundleIdentifier=$(osascript -e 'id of app "Notes"') && defaults write $BundleIdentifier NSRequiresAquaSystemAppearance -bool yes