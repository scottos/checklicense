# .SYNOPSIS
#  Diagnose why a given mailbox fails License validation
#
#  Copyright (c) 2019 Microsoft Corporation. All rights reserved.
#
#  THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK
#  OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$MailboxGuid,

    [Parameter(Mandatory=$true)]
    [string]$Organization
    )

# Globals
$ErrorActionPreference = "SilentlyContinue";

# Commands
Write-Progress "Getting Organization properties";
$o = Get-Organization $Organization;

Write-Progress "Getting Mailbox properties";
$m = Get-Mailbox $MailboxGuid -Organization $o;

# Is this a UserMailbox? Otherwise, we don't enforce licensing
[bool] $boolIsUserMailbox = $false;
$boolIsUserMailbox = ($m.RecipientTypeDetails -contains 'UserMailbox');
if($boolIsUserMailbox -eq $true){
    Write-Host "SUCCESS: UserMailbox is" $boolIsUserMailbox;
}
else{
    Write-Host "Not a UserMailbox (licensing is not enforced on Shared, Room, and Resource mailboxes)";
}

# Validate IsLicensingEnforced at org level
$boolIsLicensingEnforced = $o.IsLicensingEnforced;
if($boolIsLicensingEnforced -eq $true){
    Write-Host "SUCCESS: IsLicensingEnforced is" $boolIsLicensingEnforced;
}
else{
    Write-Host "IsLicensingEnforced is" $boolIsLicensingEnforced "(Licensing is not being enforced within this Tenant)";
}

# Evaluate PersistedCapabilities
[bool] $boolPersistedCapabilities = $false;
$boolPersistedCapabilities = (($m.PersistedCapabilities -contains 'BPOS_S_Standard') -or ($m.PersistedCapabilities -contains 'BPOS_S_Enterprise'));
if($boolPersistedCapabilities -eq $true){
    Write-Host "SUCCESS: PersistedCapabilities is" $boolPersistedCapabilities;
}
else{
    Write-Warning "PersistedCapabilities is null (a Mailbox Plan has not been assigned to this Mailbox)";
}

# Evaluate SkuAssigned
[bool] $boolSkuAssigned = $false;
$boolSkuAssigned = ($null -ne $m.SkuAssigned);
if($boolSkuAssigned -eq $true){
    Write-Host "SkuAssigned is" $boolSkuAssigned;
}
else{
    Write-Warning "SkuAssigned is null (a license has not been assiged to this mailbox)";
}

# Evaluate WithinGracePeriod (Grace period == MailboxCreated < 30 days)
$boolWithinGracePeriod = $m.WhenMailboxCreated -gt (Get-Date).AddDays(-30)
if($boolWithinGracePeriod -eq $true){
    Write-Host "WithinGracePeriod is" $boolWithinGracePeriod;
}
else{
    Write-Warning "Mailbox not within Grace Period (Mailbox was created > 30 days ago)";
}