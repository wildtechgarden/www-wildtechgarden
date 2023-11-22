$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding =
	New-Object System.Text.UTF8Encoding

$htmlFiles = Get-ChildItem -Path .\public -Filter *.html -Recurse -ErrorAction SilentlyContinue -Force | %{$_.FullName}
$cssFiles = Get-ChildItem -Path .\public -Filter *.css -Recurse -ErrorAction SilentlyContinue -Force | %{$_.FullName}

java -jar "$Env:USERPROFILE\jar\vnu.jar" -Werror $htmlFiles

