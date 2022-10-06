$invocation = (Get-Variable MyInvocation).Value
$currentDirectory = Split-Path $invocation.MyCommand.Path
Write-Host $currentDirectory

$appConfigFile = [IO.Path]::Combine($currentDirectory, 'appConfig.xml')

$appConfig = New-Object XML
$appConfig.Load($appConfigFile)

$myServer1 = ""
$myServer2 = ""
$myServer1Pass = ""
$myServer2Pass = ""

$myServer1Adapter1 = ""
$myServer1Adapter2 = ""

$myServer2Adapter1 = ""
$myServer2Adapter2 = ""

foreach ($server1 in $appConfig.configuration.server1.add) {
    $myServer1 = $server1.serverName
    $myServer1Pass = $server1.passwd
    $myServer1Adapter1 = $server1.adapter1
    $myServer1Adapter2 = $server1.adapter2

    Write-Host $myServer1 -ForegroundColor Cyan
    Write-Host $myServer1Pass -ForegroundColor Cyan
    Write-Host $myServer1Adapter1 -ForegroundColor Cyan
    Write-Host $myServer1Adapter2 -ForegroundColor Cyan
}

foreach ($server2 in $appConfig.configuration.server2.add) {
    $myServer2 = $server2.serverName
    $myServer2Pass = $server2.passwd
    $myServer2Adapter1 = $server2.adapter1
    $myServer2Adapter2 = $server2.adapter2
    
    Write-Host $myServer2 -ForegroundColor Green
    Write-Host $myServer2Pass -ForegroundColor Green
    Write-Host $myServer2Adapter1 -ForegroundColor Green
    Write-Host $myServer2Adapter2 -ForegroundColor Green
}

Write-Host "Step 0: config file loaded ... "

$clusterName = ""
$clusterIp = ""
$intentName = ""

foreach ($server in $appConfig.configuration.cluster.add) {
    $clusterName = $server.clusterName
    $clusterIp = $server.clusterIp
    $intentName = $server.intName
    Write-Host $clusterName -ForegroundColor Green
    Write-Host $clusterIp -ForegroundColor Green
    Write-Host $intentName -ForegroundColor Green
}


# Step 4: Configure host networking

# Step 4.1: Review physical adapters

# Step 4.2: Configure an intent

# in server 1

Write-Host "Step 4.2: Configure an intent for server 1 ... "

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force

$user = $myServer1 + "\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer1Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

$ScriptBlockContent = {
    $intentName = $args[0]
    $myServer1Adapter1 = $args[1]
    $myServer1Adapter2 = $args[2]

    (Add-NetIntent -Name $intentName -Compute -Storage -AdapterName $myServer1Adapter1,$myServer1Adapter2)
}
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $intentName,$myServer1Adapter1,$myServer1Adapter2



Write-Host "Step 4.2: Configure an intent for server 2 ... "

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer2 -Force

$user = $myServer2 + "\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer2Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

$ScriptBlockContent = {
    $intentName = $args[0]
    $myServer1Adapter1 = $args[1]
    $myServer1Adapter2 = $args[2]

    (Add-NetIntent -Name $intentName -Compute -Storage -AdapterName $myServer1Adapter1,$myServer1Adapter2)
}
Invoke-Command -ComputerName $myServer2 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $intentName,$myServer2Adapter1,$myServer2Adapter2



# Step 4.3: Validate intent deployment

Write-Host "Step 4.3: Validate intent deployment ... "


Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force
$ScriptBlockContent = {
    $clusterName = $args[0]
    $intentName = $args[1]
    (Get-NetIntent -ClusterName $clusterName),
    (Get-NetIntentStatus -ClusterName $clusterName -Name $intentName),
    (Get-VMSwitch -CimSession (Get-ClusterNode).Name | Select Name, ComputerName)
}
# Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $clusterName,$intentName



# Step 6: Enable Storage Spaces Direct


Write-Host "Step 6: Enable Storage Spaces Direct ... "

Enable-WSManCredSSP Client –DelegateComputer [$myServer1][*] -Force
Enable-WSManCredSSP Client –DelegateComputer [$myServer2][*] -Force


Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force
$ScriptBlockContent = {
    
    Enable-PSRemoting
    Enable-WSManCredSSP server -Force

    $clusterName = $args[0]
    Enable-ClusterStorageSpacesDirect -PoolFriendlyName "$clusterName Storage Pool" 
    Get-StoragePool
}
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $clusterName


Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer2 -Force
$ScriptBlockContent = {
    
    Enable-PSRemoting
    Enable-WSManCredSSP server -Force

    $clusterName = $args[0]
    Enable-ClusterStorageSpacesDirect -PoolFriendlyName "$clusterName Storage Pool" 
    Get-StoragePool
}
Invoke-Command -ComputerName $myServer2 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $clusterName






