Function Invoke-ErrRcd {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
            [String]$Message,

        [Parameter(Mandatory)]
            [Int]$Results
    )
      
    Process {    
        $ErrorCategory = @{
            0x80070057 = "InvalidArgument";
            0x800703EC = "InvalidData";
            0x80070490 = "ObjectNotFound";
            0x80070520 = "SecurityError";
            0x8007089A = "SecurityError"
        }
                
        $ErrMessage = [Management.ManagementException]::New($Message)

        [Management.Automation.ErrorRecord]::New($ErrMessage, $Results.ToString("X"), $ErrorCategory[$Results], $Null)
    }
} # Function Invoke-ErrRcd