function Lookup-ServiceTag {
	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		 [string[]]$Computer=($Env:COMPUTERNAME),
		[System.Management.Automation.CredentialAttribute()]$Credential,
		[Alias("O")]
		 [switch]$OpenInBrowser
    )
	
	begin {}
	
	process {

		function GenerateURL($ST) {
			Return ('http://www.dell.com/support/home/us/en/04/product-support/servicetag/'+($ST)+'/research')
		}
	
		foreach ($ComputerName in $Computer) {
			if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
				try {
					$wmi = Get-WmiObject Win32_BIOS -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
				} catch {
					$WMIError = $_.exception.message
					$wmi = 'WMIError'
				}
				if ($wmi.Manufacturer -match 'Dell Inc') {
					$Result = [PSCustomObject]@{
						ComputerName = $ComputerName
						ServiceTag = $wmi.SerialNumber
					}
					if ($OpenInBrowser) {
						Start-Process (GenerateURL($Result.ServiceTag))
					}
				} elseif ($wmi -match 'WMIError') {
					$Result = [PSCustomObject]@{
						ComputerName = $ComputerName
						ServiceTag = $WMIError
					}
				} else {
					$Result = [PSCustomObject]@{
						ComputerName = $ComputerName
						ServiceTag = "Not Dell/No ServiceTag"
					}
				}
			} else {
				$Result = [PSCustomObject]@{
					ComputerName = $ComputerName
					ServiceTag = "Not Reachable"
				}
			}
			Write-Output $Result
		}
	}
	
	end {}
}