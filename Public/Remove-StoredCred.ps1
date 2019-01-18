<#
    .Synopsis
        Deletes the specified credentials

    .Description
        Calls Win32 CredDeleteW via [PsUtils.CredMan]::CredDelete

    .INPUTS
        See Function-level notes

    .OUTPUTS
        0 or non-0 according to action success
        [Management.Automation.ErrorRecord] if error encountered

    .PARAMETER Target
        Specifies the URI for which the credentials are associated
    
    .PARAMETER CredType
        Specifies the desired credentials type; defaults to 
        "CRED_TYPE_GENERIC"
#>
Function Remove-StoredCred {
    [CmdLetBinding()]
	Param (
        [Parameter(Position=0,Mandatory,ValuefromPipelineByPropertyName)]
        [ValidateLength(1,32767)]
            [String]$Target,
        
        [Parameter()]
        [ValidateSet("GENERIC",
                    "DOMAIN_PASSWORD",
                    "DOMAIN_CERTIFICATE",
                    "DOMAIN_VISIBLE_PASSWORD",
                    "GENERIC_CERTIFICATE",
                    "DOMAIN_EXTENDED",
                    "MAXIMUM",
                    "MAXIMUM_EX")]
            [String]$Type = "GENERIC"
	)
	
	[Int] $Results = 0
    
    Try {
		$Results = [PsUtils.CredMan]::CredDelete($Target, $(Get-CredType $Type))
	} Catch {
		Throw $PSItem
	}
    
    If ($Results -ne 0) {
        Invoke-ErrRcd -Message ("Failed to delete credentials store for : {0}" -F $Target) -Results $Results
        Break
	} Else {
        Write-Output ('Successfully removed credential for : {0}' -F $Target)
    }
} # Function Remove-StoredCred