# Globals
$ErrorActionPreference = "SilentlyContinue";

# Variables
$exchangeGuid = "3ba2b1c0-77e5-47c9-b4b9-4f2472418d2e"
$org = "expediacorp.onmicrosoft.com"

# Commands
Write-Progress "Getting Organization properties";
$o = Get-Organization $org;
Write-Progress "Getting Mailbox properties";
$m = Get-Mailbox $exchangeGuid -Organization $o;

# Is this a UserMailbox? Otherwise, we don't enforce licensing
[bool] $boolIsUserMailbox = $false;
$boolIsUserMailbox = ($m.RecipientTypeDetails -contains 'UserMailbox');
if($boolIsUserMailbox -eq $true){
    Write-Host "UserMailbox is" $boolIsUserMailbox;
}
else{
    Write-Host "Not a UserMailbox; license not enforced";
}

# Validate IsLicensingEnforced at org level
$boolIsLicensingEnforced = $o.IsLicensingEnforced;
if($boolIsLicensingEnforced -eq $true){
    Write-Host "IsLicensingEnforced is" $boolIsLicensingEnforced;
}
else{
    Write-Host "IsLicensingEnforced is" $boolIsLicensingEnforced;
}

# Evaluate PersistedCapabilities
[bool] $boolPersistedCapabilities = $false;
$boolPersistedCapabilities = ($m.PersistedCapabilities -contains 'BPOS_S_Enterprise');
if($boolPersistedCapabilities -eq $true){
    Write-Host "PersistedCapabilities is" $boolPersistedCapabilities;
}
else{
    Write-Warning "PersistedCapabilities is null";
}

# Evaluate SkuAssigned
[bool] $boolSkuAssigned = $false;
$boolSkuAssigned = ($null -ne $m.SkuAssigned);
if($boolSkuAssigned -eq $true){
    Write-Host "SkuAssigned is" $boolSkuAssigned;
}
else{
    Write-Warning "SkuAssigned is null";
}

# Evaluate WithinGracePeriod (Grace period == MailboxCreated < 30 days)
$boolWithinGracePeriod = $m.WhenMailboxCreated -gt (Get-Date).AddDays(-30)
if($boolWithinGracePeriod -eq $true){
    Write-Host "WithinGracePeriod is" $boolWithinGracePeriod;
}
else{
    Write-Warning "Mailbox not within Grace Period";
}