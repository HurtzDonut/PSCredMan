Function Get-CredPersist {
    [CmdLetBinding()]
    Param (
        [Parameter(Mandatory)]
        [ValidateSet("SESSION",
                    "LOCAL_MACHINE",
                    "ENTERPRISE")]
        [String]$PersistType
	)
	
	Switch ($PersistType) {
		"SESSION"       { [PsUtils.CredMan+CRED_PERSIST]::SESSION }
		"LOCAL_MACHINE" { [PsUtils.CredMan+CRED_PERSIST]::LOCAL_MACHINE }
		"ENTERPRISE"    { [PsUtils.CredMan+CRED_PERSIST]::ENTERPRISE }
	}
} # Function Get-CredPersist