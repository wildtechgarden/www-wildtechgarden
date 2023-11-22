# cspell:ignore curdir
Remove-Item -Path public -Recurse -Force

$Env:URL="https://www.wildtechgarden.ca/"
$URL="https://www.wildtechgarden.ca/"
$Env:HUGO_PARAMS_DEPLOYEDBASEURL="$URL"
$Env:BASEURL="$URL"
$BASEURL = "$URL"
$curdir = Get-Location
$Env:HUGO_RESOURCEDIR="$curdir\resources"
hugo.exe --gc --minify -b $BASEURL --destination "$curdir\public"
rclone sync --checksum --progress .\public\ wtgdeml-wtg:./
