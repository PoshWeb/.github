<#
.SYNOPSIS
    Organization Repos
.DESCRIPTION
    Gets the public repos in this organization
#>
param(
# The GitHub organization.
# This should default to the repository owner.
[string]$Organization = $(
    if ($env:GITHUB_REPOSITORY_OWNER) {
        $env:GITHUB_REPOSITORY_OWNER
    } else {
        'PoshWeb'
    }
),

[string]
$Logo = "/PoshWeb-Animated.svg",

[string]
$Intro = "

We make a few cool projects

"
)

if (-not $script:Cache) {$script:Cache = [Ordered]@{}}

$orgInfoUrl = "https://api.github.com/orgs/$Organization"
if (-not $script:Cache[$orgInfoUrl]) {
    Write-Warning "Getting $orgInfoUrl"
    $script:Cache[$orgInfoUrl] = Invoke-RestMethod -Uri $orgInfoUrl
}

$projectsUrl = "https://api.github.com/orgs/$Organization/repos?per_page=100"

if (-not $script:Cache[$projectsUrl]) {
    Write-Warning "Getting $projectsUrl"
    $script:Cache[$projectsUrl] = Invoke-RestMethod -Uri $projectsUrl |
        Where-Object Name -notmatch '^.github'
}

if ($logo) {
"
<div align='center'>
<img src='$Logo' style='height:400px' />
</div>
"    
}


"# $($script:Cache[$orgInfoUrl].name)"

"## $($script:Cache[$orgInfoUrl].description)"

$Intro

"### Repo of the Build:"

$randomRepo = $script:Cache[$projectsUrl] | Get-Random

"#### [$($randomRepo.Name)]($($randomRepo.html_url))"

"> $($randomRepo.description)"

"### Recently Updated"

$(
    ""
    $script:Cache[$projectsUrl] | 
        Sort-Object updated_at -Descending |
        Select-Object -First 10 | 
        Get-Random -Count 10 |
        ForEach-Object {
            $project =  $_
            "* [$($project.Name)]($($project.html_url))"
        }
    ""
)

"### All Projects"

"|Project|Description|Badges|"
"|:-|:-:|-:|"
foreach (
    $project in $script:Cache[$projectsUrl] | 
        Sort-Object stargazers_count -Descending
) {
    $projectBadges = @(
        "[![GitHub Repo stars](https://img.shields.io/github/stars/$(
                $($project.owner.login)
            )/$($(
                $project.name
            )))]($(
                $project.html_url
            )/stargazers)"
        if ($project.custom_properties.PowerShellGalleryID) {
            $galleryId = $project.custom_properties.PowerShellGalleryID            
            # "[★ $($project.stargazers_count)]()"
            "[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/$galleryId)]($(
                "https://www.powershellgallery.com/packages/$galleryId"
            ))"            
        }
    ) -join ' '
    "|$("[$($project.name)]($($project.html_url))",        
        "[$($project.description -replace '\|', '\|')]($($project.html_url))",
            "$projectBadges" -join 
                '|')|"
}
