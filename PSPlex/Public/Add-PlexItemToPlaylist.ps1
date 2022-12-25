function Add-PlexItemToPlaylist
{
	<#
		.SYNOPSIS
			Copies a single item to a playlist.
		.DESCRIPTION
			Copies a single item to a playlist.
		.PARAMETER PlaylistId
			The id of the playlist.
		.PARAMETER ItemId
			The id of the item.
		.EXAMPLE
			# Add an item to a playlist on the default plex server
			Add-PlexItemToPlaylist -PlaylistId 12345 -ItemId 7204
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$PlaylistId,

		[Parameter(Mandatory = $true)]
		[String]
		$ItemId
	)

	#############################################################################
	#Region Import Plex Configuration
	if(!$script:PlexConfigData)
	{
		try
		{
			Import-PlexConfiguration
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion


	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting list of Plex servers (to get machine identifier)"
	try
	{
		$CurrentPlexServer = Get-PlexServer -Name $DefaultPlexServer.PlexServer -ErrorAction Stop
		if(!$CurrentPlexServer)
		{
			throw "Could not find $CurrentPlexServer in $($Servers -join ', ')"
		}
	}
	catch
	{
		throw $_
	}


	#############################################################################
	$RestEndpoint = "playlists/$PlaylistID/items?uri=server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemID"


	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Adding item to playlist."
	try
	{
		Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?&X-Plex-Token=$($DefaultPlexServer.Token)" -Method PUT -ErrorAction Stop | Out-Null
	}
	catch
	{
		throw $_
	}
}