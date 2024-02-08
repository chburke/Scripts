Try {
    #CONNECT TO EXCHANGE ONLINE
    $testExchangeOnlineConnection = Get-ConnectionInformation
    if (!($testExchangeOnlineConnection)) {
        Connect-ExchangeOnline -ShowBanner:$False
    }

    #FUNCTION ASKING FOR SINGLE OR MULTIPLE DL'S
    function SingleMultiple-Menu {
        param (
            [string]$menuTitle = "Single or Multiple"
        )
        Clear-Host
        Write-Host "=================== $menuTitle ==================="


        Write-Host "1: Press '1' if Migrating a Single DL"
        Write-Host "2: Press '2' if Migrating Multiple DLs"
	   }
    Clear-Host

    #PROMPT FOR SINGLE OR MULTIPLE DL'S
    SingleMultiple-Menu
    $dlChoice = Read-Host "Please make a selection"
    switch ($dlChoice) {
        '1' {
            'Single DL'
        }
        '2' {
            'Multiple DLs'
        }
	   }

    #SINGLE DL MIGRATION
    if ($dlChoice -eq 1) {
        Clear-Host

        #FINDS THE TXT FILE
        Write-Host "Please select the TXT file needed to complete DL creation."
        Add-Type -AssemblyName System.Windows.Forms
        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        [void]$fileBrowser.ShowDialog()
        $txtFile = $fileBrowser.FileName

        #GET DATA FROM CSV FILE
        $txtData = Get-Content -Path $txtFile | ConvertFrom-Json


        #CONFIRMATION THAT THE DL HAS BEEN DELETED FROM THE CLOUD AS WELL
        $dlDeleted = Get-DistributionGroup $txtData.DisplayName -ErrorAction SilentlyContinue
        if ($dlDeleted) {
            Write-Host -f Red "DL Failed to delete from the cloud."
            Return
        }

        if ($txtData.ManagedBy -eq "" -or $txtData.ManagedBy -eq "Organization Management") {
            #CREATING NEW DL IN THE CLOUD WITHOUT AN OWNER
            New-DistributionGroup -Name $txtData.DisplayName -PrimarySmtpAddress $txtData.PrimaryEmail -Alias $txtData.Alias -RequireSenderAuthenticationEnabled $txtData.RequireSenderAuthenticationEnabled
            Set-DistributionGroup $txtData.DisplayName -AcceptMessagesOnlyFrom $txtData.DeliveryManagement
        }
        else {
            #CREATING NEW DL IN THE CLOUD WITH AN OWNER
            New-DistributionGroup -Name $txtData.DisplayName -ManagedBy $txtData.ManagedBy -PrimarySmtpAddress $txtData.PrimaryEmail -Alias $txtData.Alias -RequireSenderAuthenticationEnabled $txtData.RequireSenderAuthenticationEnabled
            Set-DistributionGroup $txtData.DisplayName -AcceptMessagesOnlyFrom $txtData.DeliveryManagement
        }

        #CONFIRMATION THAT THE DL HAS BEEN CREATED IN THE CLOUD AND ADDING MEMBERS
        $dlCreated = Get-DistributionGroup $txtData.DisplayName
        if ($dlCreated) {
            #CREATING A VARIBALE FOR THE PROGRESS BAR
            $progressBar = 0
            $totalMembers = $txtData.Members.Count

            foreach ($user in $txtData.Members) {
                #PROGRESS BAR
                $progressBar++
                Write-Progress -Status "Processing $user" -Activity "$progressBar out of $totalMembers" -PercentComplete ($progressBar / $txtData.Members.Count * 100)
                Start-Sleep -Milliseconds 20

                #ADDING MEMBERS
                Add-DistributionGroupMember $txtData.DisplayName -Member $user
            }

        }

        else {
            Write-Host -f Red "DL has failed to create in the cloud"
            Return
        }
    }

    #MULTIPLE DL MIGRATION
    if ($dlChoice -eq 2) {
        Clear-Host

        #FINDS THE TXT FILE
        Write-Host "Please select the TXT file needed to complete DL creation."
        Add-Type -AssemblyName System.Windows.Forms
        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        [void]$fileBrowser.ShowDialog()
        $txtFile = $fileBrowser.FileName

        #GET DATA FROM TXT FILE
        $txtData = Get-Content -Path $txtFile | ConvertFrom-Json

        #CREATING A VARIABLE AND ARRAY FOR THE FAILED TO DELETE COUNTER
        $failedToDeleteCounter = 0
        $failedToDeleteArray = @()

        #CREATING A VARIABLE AND ARRAY FOR THE MIGRATION COUNTER
        $migrationCounter = 0
        $migratedListArray = @()

        #CREATING A VARIABLE FOR THE PROGRESS BAR
        $progressBar = 0
        $totalDLS = $txtData.Count

        #CONFIRMATION THAT THE DL HAS BEEN DELETED FROM THE CLOUD AS WELL
        foreach ($item in $txtData) {

            #PROGRESS BAR
            $progressBar++
            Write-Progress -Id 1 -Status "Processing $($item.DisplayName)"  -Activity "$progressBar out of $totalDLS" -PercentComplete ($progressBar / $txtData.Count * 100)

            $dlDeleted = Get-DistributionGroup $item.DisplayName -ErrorAction SilentlyContinue
            if ($dlDeleted) {
                $failedToDeleteCounter++
                $failedToDeleteArray += @{DisplayName = $item.DisplayName; Alias = $item.Alias; ManagedBy = $item.ManagedBy; Members = $item.Members; PrimaryEmail = $item.PrimaryEmail; RequireSenderAuthenticationEnabled = $item.RequireSenderAuthenticationEnabled; DeliveryManagement = $item.DeliveryManagement }
                Start-Sleep -Milliseconds 20
            }
            else {
                if ($item.ManagedBy -eq "" -or $item.ManagedBy -eq "Organization Management") {
                    #CREATING NEW DL IN THE CLOUD WITHOUT AN OWNER
                    New-DistributionGroup -Name $item.DisplayName -PrimarySmtpAddress $item.PrimaryEmail -Alias $item.Alias -RequireSenderAuthenticationEnabled $item.RequireSenderAuthenticationEnabled
                    Set-DistributionGroup $item.DisplayName -AcceptMessagesOnlyFrom $item.DeliveryManagement
                    Update-DistributionGroupMember $item.DisplayName -Members $item.Members
                }
                else {
                    #CREATING NEW DL IN THE CLOUD WITH AN OWNER
                    New-DistributionGroup -Name $item.DisplayName -ManagedBy $item.ManagedBy -PrimarySmtpAddress $item.PrimaryEmail -Alias $item.Alias -RequireSenderAuthenticationEnabled $item.RequireSenderAuthenticationEnabled
                    Set-DistributionGroup $item.DisplayName -AcceptMessagesOnlyFrom $item.DeliveryManagement
                    Update-DistributionGroupMember $item.DisplayName -Members $item.Members
                }

                #ADDING SUCCESSFUL DL CREATIONS TO THE ARRAY AND INCREASING THE COUNTER
                $migrationCounter++
                $migratedListArray += $item.DisplayName
                Start-Sleep -Milliseconds 20

            }
        }

        #EXPORTS THE TXT FILE
            (ConvertTo-Json $failedToDeleteArray) | Out-File -FilePath "Input Local File Path Here"

    }

    # NO SELECTION EXIT
    if ($dlChoice -eq "") { return }
}

Catch {
    Write-Host -f Red "Error:" $_.Exception.Message
}
