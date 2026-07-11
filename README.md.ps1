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

"### Projects"

"|Project|Description|Stargazers|"
"|:-|:-:|-:|"
foreach (
    $project in $script:Cache[$projectsUrl] | 
        Sort-Object stargazers_count -Descending
) {
    "|$("[$($project.name)]($($project.html_url))",
        "[$($project.description -replace '\|', '\|')]($($project.html_url))",
            "[$($project.stargazers_count)]($($project.html_url)/stargazers)" -join '|')|"
}
