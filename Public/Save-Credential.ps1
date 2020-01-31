<#
    .Synopsis
        Saves or updates specified credentials for operating user
    .Description
        Calls Win32 CredWriteW via [PsUtils.CredMan]::CredWrite
    .OUTPUTS
        [Boolean] true if successful
        [Management.Automation.ErrorRecord] if unsuccessful or error encountered
    .PARAMETER Target
        Specifies the URI for which the credentials are associated
        If not provided, the username is used as the target
    .PARAMETER UserName
        Specifies the name of credential to be read
    .PARAMETER Password
        Specifies the password of credential to be read
    .PARAMETER Comment
        Allows the caller to specify the comment associated with 
        these credentials
    .PARAMETER Type
        Specifies the desired credentials type; defaults to 
        "CRED_TYPE_GENERIC"
    .PARAMETER PersistType
        Specifies the desired credentials storage type;
        defaults to "CRED_PERSIST_ENTERPRISE"
#>
Function Save-Credential {
    [CmdLetBinding()]
	Param (
        [Parameter()]
        [ValidateLength(0,32676)]
            [String]$Target,
        
        [Parameter(Mandatory)]
        [ValidateLength(1,512)]
            [String]$UserName,
        
        [Parameter(Mandatory)]
            [String]$Password,
        
        [Parameter()]
        [ValidateLength(0,256)]
            [String]$Comment = [String]::Empty,
        
        [Parameter()]
        [ValidateSet("GENERIC",
                    "DOMAIN_PASSWORD",
                    "DOMAIN_CERTIFICATE",
                    "DOMAIN_VISIBLE_PASSWORD",
                    "GENERIC_CERTIFICATE",
                    "DOMAIN_EXTENDED",
                    "MAXIMUM",
                    "MAXIMUM_EX")]
            [String]$Type = "GENERIC",
        
        [Parameter()]
        [ValidateSet("SESSION",
                    "LOCAL_MACHINE",
                    "ENTERPRISE")]
            [String]$PersistType = "ENTERPRISE"
	)

	If ([String]::IsNullOrEmpty($Target)) {
		$Target = $UserName
	}
    
    # CRED_MAX_DOMAIN_TARGET_NAME_LENGTH
    If (($Type -ne "GENERIC") -and ($Target.Length -lt 337)) {
        Invoke-ErrRcd -Message "Target field is longer ($($Target.Length)) than allowed (max 337 characters)"
        Break
	}
    
    If ([String]::IsNullOrEmpty($Comment)) {
        $Comment = [String]::Format(("Last edited by {0}\{1} on {2}" -F $Env:UserDomain,$Env:UserName,$Env:ComputerName))
    }
    
    $Cred = New-Object PsUtils.CredMan+Credential
    
    If (($Target -eq $UserName) -and  (($Type -eq "CRED_TYPE_DOMAIN_PASSWORD")  -or  ($Type -eq "CRED_TYPE_DOMAIN_CERTIFICATE"))) {
		$Cred.Flags = [PsUtils.CredMan+CRED_FLAGS]::USERNAME_TARGET
	} Else {
        $Cred.Flags = [PsUtils.CredMan+CRED_FLAGS]::NONE
    }

	$Cred.Type                  = Get-CredType -Type $Type
	$Cred.TargetName            = $Target
	$Cred.UserName              = $UserName
	$Cred.AttributeCount        = 0
	$Cred.Persist               = Get-CredPersist -PersistType $PersistType
	$Cred.CredentialBlobSize    = [Text.Encoding]::Unicode.GetBytes($Password).Length
	$Cred.CredentialBlob        = $Password
	$Cred.Comment               = $Comment

	[Int] $Results = 0
	Try {
		$Results = [PsUtils.CredMan]::CredWrite($Cred)
	} Catch {
		Throw $PSItem
	}

	If ($Results -ne 0) {
        Invoke-ErrRcd -Message "Failed to write to credentials store for target '$Target' using '$UserName', '$Password', '$Comment'" -Results $Results
        Break
	} ElseIf ($Results -eq 0) {
        [PSCustomObject][Ordered]@{
            UserName    = $Cred.UserName
            Target      = $Cred.TargetName
            Updated     = Get-Date -Format G
            Comment     = $Cred.Comment
        }
    }
} # Function Save-Credential