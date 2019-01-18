<#
    .Synopsis
        Reads specified credentials for operating user
    .Description
        Calls Win32 CredReadW via [PsUtils.CredMan]::CredRead
    .OUTPUTS
        [PsUtils.CredMan+Credential] if successful
        [Management.Automation.ErrorRecord] if unsuccessful or error encountered
    .PARAMETER Target
        Specifies the URI for which the credentials are associated
        If not provided, the username is used as the target
    .PARAMETER Type
        Specifies the desired credentials type; defaults to 
        "CRED_TYPE_GENERIC"
#>
Function Get-StoredCred {
    [CmdLetBinding(DefaultParameterSetName='All')]
	Param (
        [Parameter(Mandatory,ParameterSetName='Single')]
        [ValidateLength(1,32767)]
            [String] $Target,

        [Parameter(ParameterSetName='Single')]
        [ValidateSet("GENERIC",
                    "DOMAIN_PASSWORD",
                    "DOMAIN_CERTIFICATE",
                    "DOMAIN_VISIBLE_PASSWORD",
                    "GENERIC_CERTIFICATE",
                    "DOMAIN_EXTENDED",
                    "MAXIMUM",
                    "MAXIMUM_EX")]
            [String]$Type = "GENERIC",

        [Parameter(ParameterSetName='All')]
            [Switch]$All,

        [Parameter(ParameterSetName='All')]
        [AllowEmptyString()]
            [String]$Filter = [String]::Empty
    ) # Param Block
    
    Begin {
        [Int]$Results = 0
    } # Begin Block

    Process {
        Switch ($PSCmdLet.ParameterSetName) {
            'Single' {
                # CRED_MAX_DOMAIN_TARGET_NAME_LENGTH
                If (($Type -ne "GENERIC") -and ($Target.Length -lt 337)) {
                    Invoke-ErrRcd -Message ("Target field is longer than allowed : {0} actual / 337 max" -F $Target.Length) -Results $Results
                    Return
                }

                $Cred = New-Object PsUtils.CredMan+Credential

                Try {
                    $Results = [PsUtils.CredMan]::CredRead($Target, $(Get-CredType $Type), [Ref]$Cred)
                } Catch { Throw $PSItem }

                $ErrMsg = ("Error reading credentials for : {0}" -F $Target)
            } # Single
            'All' {
                $Cred = [Array]::CreateInstance([PsUtils.CredMan+Credential], 0)
                
                Try {
                    $Results = [PsUtils.CredMan]::CredEnum($Filter, [Ref]$Cred)
                } Catch { Throw $PSItem }

                $ErrMsg = "Failed to enumerate credentials store"
            } # All
        } # Parameter Set Switch
    } # Process Block

    End {
        Switch ($Results) {
            0           { $Cred }
            0x80070490  { $Cred }
            Default     {
                Invoke-ErrRcd -Message $ErrMsg -Results $Results
            }
        }
    } # End Block
} # Function Get-StoredCred