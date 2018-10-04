function Get-XmlNode([ xml ]$XmlDocument, [string]$NodePath, [string]$NamespaceURI = "", [string]$NodeSeparatorCharacter = '.')
{
    # If a Namespace URI was not given, use the Xml document's default namespace.
    if ([string]::IsNullOrEmpty($NamespaceURI)) { $NamespaceURI = $XmlDocument.DocumentElement.NamespaceURI }   
     
    # In order for SelectSingleNode() to actually work, we need to use the fully qualified node path along with an Xml Namespace Manager, so set them up.
    $xmlNsManager = New-Object System.Xml.XmlNamespaceManager($XmlDocument.NameTable)
    $xmlNsManager.AddNamespace("ns", $NamespaceURI)
    $fullyQualifiedNodePath = "/ns:$($NodePath.Replace($($NodeSeparatorCharacter), '/ns:'))"
     
    # Try and get the node, then return it. Returns $null if the node was not found.
    $node = $XmlDocument.SelectSingleNode($fullyQualifiedNodePath, $xmlNsManager)
    return $node
}

$currentLocation = Get-Location

$projectFilePath = "CitadelCore.Windows\CitadelCore.Windows.csproj"
$projectId = "CitadelCore.Windows"

[xml] $projectFile = Get-Content $projectFilePath

$currentVersionNode = Get-XmlNode -XmlDocument $projectFile -NodePath "Project.PropertyGroup.Version"

$currentVersion = $currentVersionNode.InnerText

Write-Host "Current nuget version for $projectId is $currentVersion"
$newVersion = Read-Host -Prompt "Enter new version"

$currentVersionNode.InnerText = $newVersion

$assemblyVersionNode = Get-XmlNode -XmlDocument $projectFile -NodePath "Project.PropertyGroup.AssemblyVersion"
$fileVersionNode = Get-XmlNode -XmlDocument $projectFile -NodePath "Project.PropertyGroup.FileVersion"

$assemblyVersionNode.InnerText = $newVersion + ".0"
$fileVersionNode.InnerText = $newVersion + ".0"

$releaseNotesNode = Get-XmlNode -XmlDocument $projectFile -NodePath "Project.PropertyGroup.PackageReleaseNotes"

$msg = "Current Release Notes: " + $releaseNotesNode.InnerText
Write-Host $msg
$newReleaseNotes = Read-Host -Prompt "Enter new release notes"

$releaseNotesNode.InnerText = $newReleaseNotes

$savePath = Join-Path $currentLocation $projectFilePath
$projectFile.Save($savePath)
