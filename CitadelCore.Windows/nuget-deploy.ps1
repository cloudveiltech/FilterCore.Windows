$apiKey = Get-Content .nuget-apikey
cd CitadelCore.Windows

# Get package version from csproj
$file = [xml](gc .\CitadelCore.Windows.csproj)

$packageVersion = $file.Project.PropertyGroup.Version

if($packageVersion.Length -gt 0) {
	$packageVersion = $packageVersion[0]
} else {
	echo "No package version specified in csproj. Exiting."
}

dotnet pack -c Release

cd bin\Release
dotnet nuget push CloudVeil.CitadelCore.Windows.$packageVersion.nupkg -k $apiKey -s https://api.nuget.org/v3/index.json

cd ..\..
cd ..
