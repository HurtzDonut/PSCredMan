Function Get-CredType {
    [CmdLetBinding()]
	Param (
        [Parameter(Mandatory)]
        [ValidateSet("GENERIC",
                    "DOMAIN_PASSWORD",
                    "DOMAIN_CERTIFICATE",
                    "DOMAIN_VISIBLE_PASSWORD",
                    "GENERIC_CERTIFICATE",
                    "DOMAIN_EXTENDED",
                    "MAXIMUM",
                    "MAXIMUM_EX")]
            [String]$Type
	)
	
	Switch ($Type) {
		"GENERIC"                   { [PsUtils.CredMan+CRED_TYPE]::GENERIC }
		"DOMAIN_PASSWORD"           { [PsUtils.CredMan+CRED_TYPE]::DOMAIN_PASSWORD }
		"DOMAIN_CERTIFICATE"        { [PsUtils.CredMan+CRED_TYPE]::DOMAIN_CERTIFICATE }
		"DOMAIN_VISIBLE_PASSWORD"   { [PsUtils.CredMan+CRED_TYPE]::DOMAIN_VISIBLE_PASSWORD }
		"GENERIC_CERTIFICATE"       { [PsUtils.CredMan+CRED_TYPE]::GENERIC_CERTIFICATE }
		"DOMAIN_EXTENDED"           { [PsUtils.CredMan+CRED_TYPE]::DOMAIN_EXTENDED }
		"MAXIMUM"                   { [PsUtils.CredMan+CRED_TYPE]::MAXIMUM }
		"MAXIMUM_EX"                { [PsUtils.CredMan+CRED_TYPE]::MAXIMUM_EX }
	}
} # Function Get-CredType