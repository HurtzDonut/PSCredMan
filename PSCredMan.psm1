$PSUtilsAssembly = Join-Path -Path $PSScriptRoot -ChildPath 'PsUtils_CredMan.dll'
[Void][System.Reflection.Assembly]::LoadFile($PSUtilsAssembly)

#region Module Vars
    $PrivateDir     = Join-Path -Path $PSScriptRoot -ChildPath Private
    $PublicDir      = Join-Path -Path $PSScriptRoot -ChildPath Public

    $PrivateFiles   = Get-ChildItem -Path $PrivateDir -Include *.ps1 -Recurse
    $PublicFiles    = Get-ChildItem -Path $PublicDir -Include *.ps1 -Recurse
#endregion Module Vars

#region Import Public/Private Functions
    ForEach ($File in @($PrivateFiles + $PublicFiles)) {
        Try {
            . $File.FullName
        } Catch {
            Write-Warning ('Failed to load function : {0}' -F $File.BaseName)
            Write-Error $PSItem.Exception.Message
        }
    }
#endregion Import Public/Private Functions

#region Export Public Functions
    Export-ModuleMember -Function $PublicFiles.BaseName
#endregion Export Public Functions
