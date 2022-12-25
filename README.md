# About

This project started out as a script to copy a playlist from my account as a Plex Server owner to another user's account (on the same server). Slowly it got broken up into separate functions and became a simple PowerShell module.

<br>

# Getting Started:

1. Install the module from the PowerShell Gallery: `Install-Module -Name PSPlex`.
2. Run: `Get-PlexAuthenticationToken`. You will be prompted to enter your Plex account name and password.
    * To inspect the code for this function, see: [Get-PlexAuthenticationToken.ps1](/PSPlex/Public/Get-PlexAuthenticationToken.ps1).
3. Run: `Save-PlexConfiguration` and provide your Plex server name, the Plex hostname (or IP address), protocol and port.
    * Example 1: `Save-PlexConfiguration -PlexServer myserver -PlexServerHostname namaste.yourdomain.com -Protocol https -Port 32400`
    * Example 2: `Save-PlexConfiguration -PlexServer myserver -PlexServerHostname 86.123.105.18 -Protocol https -Port 32400`
4. Try a command from the 'Simple Examples' below.

<br>

# Simple Examples:

**Get a list of users you've shared with:**

`Get-PlexUser`

**Get a list of libraries and select the title, type and key (Id):**

`Get-PlexLibrary | Select title,type,key`

**Get all the items from a library called 'Films' that are unwatched:**

`Get-PlexItem -LibraryTitle 'Films' | Where-Object { $Null -eq $_.lastViewedAt }`

**Get collections from library '3' show only the title and ratingKey (Id):**

`Get-PlexCollection -LibraryId 3 | Select title,ratingKey`

**Get playlists:**

`Get-PlexPlaylist`

**Remove a playlist for your account:**

`Remove-PlexPlaylist -Id 12345`

**Remove a share for a user:**

`Remove-PlexShare -LibraryId 5 -Username 'yourfriend@theiremail.com'`

<br>

# More complex examples:

**Get a user and the libraries you've shared with them:**

`Get-PlexShare -Username 'friendusername' | Select username,@{Name='Shared';Expression={$_.Section | Where-Object { $_.Shared -eq 1 } | Select -Expand Title }}`

**Get a user and their access token (for use in further automation, see the next few examples):**

`$User = Get-PlexUser -Username 'friendusername' -IncludeToken`<br>
`$User.Token`

  * **Get playlists for a different account:**

    * `Get-PlexPlaylist -AlternativeToken $User.Token`

  * **Remove a playlist for a different account:**

    * `Remove-PlexPlaylist -Id 54321 -AlternativeToken $User.Token`

**Copy a playlist from your account to another account (e.g. a friend you have shared content with):**

`Copy-PlexPlaylist -Id 54321 -Username 'friendusername' -verbose`

**Copy *all* playlists from your account to another account:**

`Get-PlexPlaylist | Foreach-Object { Copy-PlexPlaylist -Id $_.ratingKey -Username 'friendusername' }`

**Copy a single playlist to *all* users:**

`$Users = Get-PlexUser`<br>
`$Users | Foreach-Object { Copy-PlexPlaylist -Id 54321 -Username $_.username }`

**Stop sessions where Safari is being used:**

`Get-PlexSession | Where-Object { $_.Player.platform -eq 'Safari' } | Stop-PlexSession -Reason 'Use a better browser'`

<br>

# Notes:

1. The Plex API has a little inconsistency with the naming of unique indentifiers for certain objects. For example, users have `id` properties, whereas libraries have `key` properties. Other objects have `ratingKey`. This makes passing identifiers sometimes odd/confusing. Please raise an issue if you get stuck.

2. Some functions return data fairly 'raw' - that is, without any helpful formatting to display the most commonly used fields (etc). Some functions however apply formatting rules in `PSPlex.Format.ps1xml`. This may be expanded later.

3. Plex sometimes returns 'JSON' data with keys of the same name, but differing casing (e.g. `Guid` and `guid`, `ratingKey` and `RatingKey`). PowerShell cannot convert this to JSON, so we choose to prepend the lowercase keys with `_`. You'll likely see this when using `Get-PlexItem`.


# Troubleshooting:

> In the event that your token should become invalid and you receive `401` errors, try repeating the installation steps to refresh the token.

> Should you need to delete it (e.g. to regenerate), the configuration file is stored at `$env:appdata\PSPlex\PSPlexConfig.json` on Windows, and `$HOME/.PSPlex/$FileName` on MacOS/Linux.

# Resources

* https://support.plex.tv/articles/201638786-plex-media-server-url-commands/
https://docs.github.com/en/enterprise-server@3.5/actions/automating-builds-and-tests/building-and-testing-powershell