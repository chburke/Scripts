# https://learn.microsoft.com/en-us/exchange/recipients/room-mailboxes?view=exchserver-2019
# https://learn.microsoft.com/en-us/powershell/module/exchange/set-calendarprocessing?view=exchange-ps

####################### VARIABLES #######################
$adserver = "AD Server URL"

# CONNECTZ TO AZURE AD
$TestAzureADConnection = Get-AzureADCurrentSessionInfo -ErrorAction SilentlyContinue
If (!($TestAzureADConnection)) {
    Connect-AzureAD
}

# CONNECTZ TO EXCHANGE ONLINE
$testExchangeOnlineConnection = Get-ConnectionInformation
if (!($testExchangeOnlineConnection)) {
    Connect-ExchangeOnline -ShowBanner:$False
}

# FUNCTION FOR NEW OR EDIT
function NewEdit-Menu {
    param (
        [string]$menutitle = "New Room or Edit"
    )
    Clear-Host
    Write-Host "=================== $menutitle ==================="

    Write-Host "1: Press '1' to Create a New Room"
    Write-Host "2: Press '2' to Edit a Room"
    Write-Host "3: Press '3' to View Room Settings"
}


# FUNCTION FOR ROOM TYPE OPTIONS
function RoomType-Menu {
    param (
        [string]$menutitle = "Room Types"
    )
    #Clear-Host
    Write-Host "=================== $menutitle ==================="

    Write-Host "1: Press '1' for Public Room (Auto request processing is disabled)"
    Write-Host "2: Press '2' for Private Room (Auto accept requests based upon the policies)"
    Write-Host "3: Press '3' for Managed Room (Requests are set to tenative until they are approved by a delegate)"
}

Clear-Host

# PROMPT FOR NEW CREATION OR EDIT
NewEdit-Menu
$roomchoice = Read-Host "Please make a selection"
switch ($roomchoice) {
    '1' {
        'Create New Room'
    }
    '2' {
        'Edit Room'
    }
}

# NEW ROOM
if ($roomchoice -eq 1) {
    $roomname = Read-Host "Enter Conference Room Name - CR DC 2nd Floor - 238 (seats 04)"
    if ($roomname -eq "") { return }
    $crname = Read-Host "Enter Primary SMTP Address - Test@mydomain.com"
    $samacctname = $crname.Split("@")[0]

    New-Mailbox -Name $roomname -DisplayName $roomname -Room -PrimarySmtpAddress $crname -Alias $samacctname

    Start-Sleep 2
    $objid = Get-Mailbox -Identity $crname | Select-Object ExternalDirectoryObjectId -ExpandProperty ExternalDirectoryObjectId

    #Set Resource Account Password - AAD
    Set-AzureADUserPassword -ObjectId $objid -Password $roompass
    Set-AzureADUser -ObjectId $objid -UserPrincipalName $crname
    Set-AzureADUser -ObjectId $objid -PasswordPolicies disablepasswordexpiration
}

# EDIT ROOM
if ($roomchoice -eq 2) {
    Clear-Host


    # PROMPT FOR DETAILS ON CONFERENCE ROOM
    Clear-Host
    Write-Host ""
    Write-Host ""
    $cacheprompt = Read-Host "Enter the Conference Room Address or Press ENTER to Continue with [$($crname)]"
    $crname = ($crname, $cacheprompt)[[bool]$cacheprompt]
    Write-Host ""

    if ($crname -eq "") { return }
    $samacctname = $crname.Split("@")[0]
}

# GET ROOM DETAILS
if ($roomchoice -eq 3) {
    # PROMPT FOR DETAILS ON CONFERENCE ROOM
    Clear-Host
    Write-Host ""
    $crname = Read-Host "Enter Conference Room Address - CRDC169@mydomain.com"
    if ($crname -eq "") { return }
    $samacctname = $crname.Split("@")[0]

    Get-CalendarProcessing $crname | Format-List
    Write-Host ""
    $bookinpolicy = Get-CalendarProcessing $crname | Select-Object -ExpandProperty:bookinpolicy
    if ($bookinpolicy -ne $null) { Write-Host "NOTICE - BookInPolicy Set - NOTICE" }
    Write-Host ""

    Write-Host "--- BOOK-IN POLICY USERS ---"
    ((Get-CalendarProcessing $samacctname).bookinpolicy | Get-Recipient).primarysmtpaddress

    Get-ADUser $samacctname -Properties Office, Title, msExchHideFromAddressLists -Server $adserver | Select-Object Office, Title, msExchHideFromAddressLists

    Write-Host ""

    return
}

# NO SELECTION EXIT
if ($roomchoice -eq "") { return }

RoomType-Menu
$roomtype = Read-Host "Please make a selection"
switch ($roomtype) {
    '1' {
        'Applying Room Type - Public Room'
    }
    '2' {
        'Applying Room Type - Private Room'
    }
    '3' {
        'Applying Room Type - Managed Room'
    }
}

# PUBLIC
if ($roomtype -eq 1) {
    $roomtype = "Public Use"
    $processingoption = "AutoAccept"
}

# PRIVATE
if ($roomtype -eq 2) {
    $roomtype = "Private CR"
    $processingoption = "AutoAccept"
    $managedby = Read-Host "Managed By Name(s)"
    $bookinpolicyusers = Read-Host "Enter Email Addresses of users that need explicit Book-In Policy permissions - Comma Delimited"
}

# MANAGED
if ($roomtype -eq 3) {
    $roomtype = "Managed"
    $processingoption = "AutoAccept"
    $managedby = Read-Host "Managed By Names(s)"
    $managedbyusers = Read-Host "Enter Email Addresses of users that will be the managers of the Room - Comma Delimited"
}

# NO SELECTION EXIT
if ($roomtype -eq "") {
    return
}

# DETERMINING IF ACCOUNT IS ON-PREMISE OR CLOUD
try {
    if (Get-ADUser -Identity $samacctname -ErrorAction continue) { $onprem = $true }
    Write-Host ""
    Write-Host "On-Premise Account" -ForegroundColor Green -BackgroundColor Red
    Write-Host ""
}
catch {
    $onprem = $false
    $objid = Get-Mailbox -Identity $crname | Select-Object ExternalDirectoryObjectId -ExpandProperty ExternalDirectoryObjectId
    Write-Host ""
    Write-Host "Cloud Account" -ForegroundColor Blue -BackgroundColor Yellow
    Write-Host ""
}

# SET CONFERENCE ROOM DETAILS
Write-Host "Automate Processing set to $processingoption"
Set-CalendarProcessing $crname -AutomateProcessing $processingoption
Write-Host "Booking Window Set to 500 days"
Set-CalendarProcessing $crname -BookingWindowInDays 500
Write-Host "Delete Subject set to false"
Set-CalendarProcessing $crname -DeleteSubject $false
Write-Host "Add Organizer to Subject set to false"
Set-CalendarProcessing $crname -AddOrganizerToSubject $false
Write-Host "Process External Meeting Messages set to true"
Set-CalendarProcessing $crname -ProcessExternalMeetingMessages $true
Write-Host "Room Title set to $roomtype"
if ($onprem -eq $true) {

    if ($elevatedcreds -eq $null) {
        # GET ELEVATED CREDENTIALS TO SET AD ATTRIBUTES
        $elevatedcreds = Get-Credential -Message "Enter Elevated Credentials"
        Write-Host ""
    }

    Try {
        Set-ADUser $samacctname -Title $roomtype -Credential $elevatedcreds -Server $adserver -ErrorAction SilentlyContinue
    }
    Catch {
        # GET ELEVATED CREDENTIALS TO SET AD ATTRIBUTES
        $elevatedcreds = Get-Credential -Message "Enter Elevated Credentials"
        Write-Host ""

        Set-ADUser $samacctname -Title $roomtype -Credential $elevatedcreds -Server $adserver
    }
}
else {
    Set-AzureADUser -ObjectId $objid -JobTitle $roomtype
}

# PRIVATE
if ($roomtype -eq "Private CR") {
    Write-Host "Book-in Policy set to Auto Accept for BookIn Users ONLY"
    if ($bookinpolicyusers) {
        $bookinpolicyusers = $bookinpolicyusers.split(",")
        Get-Mailbox -Identity $samacctname | Set-CalendarProcessing -BookInPolicy $bookinpolicyusers -AllBookInPolicy $false -AddAdditionalResponse $true -AdditionalResponse "Private CR - Booking Restricted, see $($managedby) for more details"

    }
    else {
        Set-CalendarProcessing $crname -BookInPolicy $null -Allbookinpolicy $false -AddAdditionalResponse $true -AdditionalResponse "Booking Restricted"
        $managedby = "N/A"
    }

    Write-Host "Room Office set to ""Managed By: $managedby"""

    if ($onprem -eq $true) {
        Set-ADUser $samacctname -Office "Managed by $managedby" -Credential $elevatedcreds -Server $adserver
        Write-Host "Room Hidden from the Address Book"
        Set-ADUser -Identity $samacctname -Replace @{msExchHideFromAddressLists = $true } -Credential $elevatedcreds -Server $adserver
    }
    else {
        Set-AzureADUser -ObjectId $objid -PhysicalDeliveryOfficeName "Managed by $managedby"
        Write-Host "Room Hidden from the Address Book"
        Set-AzureADUser -ObjectId $objid -ShowInAddressList $false
    }
}

# MANAGED
if ($roomtype -eq "Managed") {
    # SETTING BOOK-IN POLICY FOR MANAGED USERS
    $managedbyusers = $managedbyusers.split(",")
    Get-mailbox -Identity $samacctname | Set-CalendarProcessing -ResourceDelegates $managedbyusers -BookInPolicy $managedbyusers -AllBookInPolicy $False -AllRequestInPolicy $True -AddAdditionalResponse $true -AdditionalResponse "Booking Restricted, see $($managedby) for more details"

    if ($onprem -eq $true) {
        Write-Host "Room Office set to ""Managed By: $managedby"
        Set-ADUser $samacctname -Office "Managed by $managedby" -Credential $elevatedcreds -Server $adserver

        Write-Host "Validating CR is not Hidden from the Address Book"
        Set-ADUser -Identity $samacctname -Clear msExchHideFromAddressLists -Credential $elevatedcreds -Server $adserver
    }
    else {
        Write-Host "Room Office set to ""Managed By: $managedby"
        Set-AzureADUser -ObjectId $objid -PhysicalDeliveryOfficeName "Managed by $managedby"

        Write-Host "Validating CR is not Hidden from Address Book"
        Set-AzureADUser -ObjectId $objid -ShowInAddressList $null
    }
}

# PUBLIC
if ($roomtype -eq "Public Use") {
    Write-Host "Book-in Policy set to Auto Accept"
    Set-CalendarProcessing $crname -Allbookinpolicy $true
    Set-CalendarProcessing $crname -BookInPolicy $null
    Set-CalendarProcessing $crname -AddAdditionalResponse:$false -AdditionalResponse $null

    if ($onprem -eq $true) {
        Write-Host "Room Office set to Public"
        Set-ADUser $samacctname -Office "Public Use" -Credential $elevatedcreds -Server $adserver

        Write-Host "Validating CR is not Hidden from the Address Book"
        Set-ADUser -Identity $samacctname -Clear msExchHideFromAddressLists -Credential $elevatedcreds -Server $adserver
    }
    else {
        Write-Host "Room Office set to Public"
        Set-AzureADUser -ObjectId $objid -PhysicalDeliveryOfficeName "Public Use"

        Write-Host "Validating CR is not Hidden from the Address Book"
        Set-AzureADUser -ObjectId $objid -ShowInAddressList $null
    }
}