
#　https://learn.microsoft.com/en-us/azure-stack/hci/manage/vm-powershell

# install hyper V powershell module 

Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell

$hciHostName = "DELLHCINODES01"

$vmName = "pw-test-vm01"
$vSwitch = "tw-mtc-test-vwitch01"

New-VM -ComputerName $hciHostName -Name $vmName -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\tw-test-vm02.vhdx" -Path .\VMData -NewVHDSizeBytes 20GB -Generation 2 -Switch $vSwitch



