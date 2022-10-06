
# Typically, you manage VMs from a remote computer, rather than on a host server in a cluster. This remote computer is called the management computer

Write-Host "Creating VM ..."

$invocation = (Get-Variable MyInvocation).Value
$currentDirectory = Split-Path $invocation.MyCommand.Path
Write-Host $currentDirectory

$appConfigFile = [IO.Path]::Combine($currentDirectory, 'vmConfig.xml')

$appConfig = New-Object XML
$appConfig.Load($appConfigFile)

$myServer1 = ""
$vmName = ""
$vSwitch = ""

foreach ($server1 in $appConfig.configuration.server1.add) {
    $myServer1 = $server1.serverName
    $vmName = $server1.vmName
    $vSwitch = $server1.vSwitch

    Write-Host $myServer1 -ForegroundColor Cyan
    Write-Host $vmName -ForegroundColor Cyan
    Write-Host $vSwitch -ForegroundColor Cyan
}

Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell

New-VM -ComputerName $myServer1 -Name $vmName -MemoryStartupBytes 4GB -BootDevice VHD -NewVHDPath "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\tw-test-vm02.vhdx" -Path .\VMData -NewVHDSizeBytes 20GB -Generation 2 -Switch $vSwitch



