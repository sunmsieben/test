param (
  [Parameter(Mandatory=$true)]  
  [string]$storageAccountName,
  [Parameter(Mandatory=$true)]  
  [string]$storageAccountKey,
  [Parameter(Mandatory=$true)]  
  [string]$storageAccountFileShareName,
  [Parameter(Mandatory=$false)]  
  [char]$networkDriveLetter
)
$fullStorageAccountName = "$storageAccountName.file.core.windows.net"
if(!($networkDriveLetter)){
    $networkDriveLetter = 'Z'
}

$connectTestResult = Test-NetConnection -ComputerName $fullStorageAccountName -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"$fullStorageAccountName`" /user:`"Azure\$storageAccountName`" /pass:`"$storageAccountKey`""
    # Mount the drive
    New-PSDrive -Name $networkDriveLetter -PSProvider FileSystem -Root "\\$fullStorageAccountName\$storageAccountFileShareName" -Persist -Scope Global
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}