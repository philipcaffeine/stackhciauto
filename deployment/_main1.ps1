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

foreach ($server1 in $appConfig.configuration.server1.add) {
    $myServer1 = $server1.serverName
    $myServer1Pass = $server1.passwd
    Write-Host $myServer1 -ForegroundColor Cyan
}

foreach ($server2 in $appConfig.configuration.server2.add) {
    $myServer2 = $server2.serverName
    $myServer2Pass = $server2.passwd
    Write-Host $myServer2 -ForegroundColor Green
    Write-Host $myServer2Pass -ForegroundColor Green
}


$domainName = ""
$domainuUser = ""
$domainPasswd = ""

foreach ($domain in $appConfig.configuration.domain.add) {
    $domainName = $domain.domainName
    $domainUser = $domain.domainUser
    $domainPasswd = $domain.domainPasswd
    Write-Host $domainName -ForegroundColor Green
    Write-Host $domainUser -ForegroundColor Green
    Write-Host $domainPasswd -ForegroundColor Green
}


# ---- for server 1 ------------------------------------------------

# Step 1.2: Join the domain and add domain accounts

# Enter-PSSession -ComputerName DELLHCINODES01 -Credential $cred
# Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer2 -Force
# In each server Enter-PSSession session 

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force

$user = $myServer1 + "\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer1Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
# Enter-PSSession -ComputerName $myServer1 -Credential $cred

$ScriptBlockContent = {
    $domainName = $args[0]
    $domainUser = $args[1]
    $domainPasswd = $args[2]

    $dPass = convertto-securestring -AsPlainText -Force -String $domainPasswd
    $credDomain = new-object -typename System.Management.Automation.PSCredential -argumentlist $domainUser,$dPass
    (Add-Computer -DomainName $domainName -Credential $credDomain -Restart -Force)
}
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $domainName,$domainUser,$domainPasswd


# ---- need control mechanism between 2 restarts

# Step 1.3: Install roles and features

$ScriptBlockContent = {
    $myServer = $args[0]
    Install-WindowsFeature -ComputerName $myServer -Name "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica" -IncludeAllSubFeature -IncludeManagementTools
    Restart-Computer -ComputerName $myServer -WSManAuthentication Kerberos -Force   
}
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $myServer1


# ---- for server 2 ------------------------------------------------

# Step 1.2: Join the domain and add domain accounts

# Enter-PSSession -ComputerName DELLHCINODES01 -Credential $cred
# Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer2 -Force
# In each server Enter-PSSession session 

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer2 -Force

$user = $myServer2 + "\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer2Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
# Enter-PSSession -ComputerName $myServer1 -Credential $cred

$ScriptBlockContent = {
    $domainName = $args[0]
    $domainUser = $args[1]
    $domainPasswd = $args[2]

    $dPass = convertto-securestring -AsPlainText -Force -String $domainPasswd
    $credDomain = new-object -typename System.Management.Automation.PSCredential -argumentlist $domainUser,$dPass
    (Add-Computer -DomainName $domainName -Credential $credDomain -Restart -Force)
}
Invoke-Command -ComputerName $myServer2 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $domainName,$domainUser,$domainPasswd


# Step 1.3: Install roles and features

$ScriptBlockContent = {
    $myServer = $args[0]
    Install-WindowsFeature -ComputerName $myServer -Name "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica" -IncludeAllSubFeature -IncludeManagementTools
    Restart-Computer -ComputerName $myServer -WSManAuthentication Kerberos -Force   
}
Invoke-Command -ComputerName $myServer2 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $myServer2

