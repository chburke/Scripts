Try {
    #CONNECT TO EXCHANGE ON-PREM
    Import-Module 'D:\Program Files\Microsoft\Exchange Server\V15\bin\RemoteExchange.ps1'
    Connect-ExchangeServer -auto -ClientApplication:ManagementShell

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

        #PROMPT FOR DL USER IS MIGRATING
        Write-Host ""
        Write-Host ""
        $dlMigrating = Read-Host "Enter the Distribution List Address - Eg: Test_DL"
        Write-Host ""


        #CHECKING IF THE DL IS A SECURITY GROUP
        $unsafeToMigrate = Get-DistributionGroup $dlMigrating | Select-Object GroupType
        if ($unsafeToMigrate -like "*SecurityEnabled*") {
            Write-Host -f Red "This Distribution List is a Mail Enabled Security Group and can NOT be Migrated."
            Return
        }

        #DL INFORMATION GATHERING
        $distributionList = Get-DistributionGroup $dlMigrating
        $displayName = $distributionList.DisplayName
        $alias = $distributionList.Alias
        $manager = $distributionList.ManagedBy
        $members = Get-DistributionGroupMember $dlMigrating | Select-Object Name
        $primaryEmail = $distributionList.PrimarySmtpAddress
        $deliveryManagment = $distributionList.AcceptMessagesOnlyFrom
        $openInternet = $distributionList.RequireSenderAuthenticationEnabled

        #CONVERTING INFORMATION TO A JSON OBJECT AND EXPORTING TO A TXT FILE
        $singleDL = @{DisplayName = $displayName; Alias = $alias; Members = $members.Name; ManagedBy = $manager; PrimaryEmail = $primaryEmail; RequireSenderAuthenticationEnabled = $openInternet; DeliveryManagement = $deliveryManagment }
            (ConvertTo-Json $singleDL) | Out-File -FilePath "Input Local File Path Here"

        #DELETE THE DL FROM ON-PREM
        Remove-DistributionGroup -Identity $dlMigrating

        #STATEMENT ADIVSING THE DL HAS BEEN DELETED
        Write-Host "$dlMigrating has been deleted from Exchange On-Prem. Please wait for sync to complete before moving on to part 2"
        Return
    }

    #MULTIPLE DL MIGRATION
    if ($dlChoice -eq 2) {
        Clear-Host

        #FINDS THE CSV FILE
        Write-Host "Please select the CSV file needed for DL Migration."
        Add-Type -AssemblyName System.Windows.Forms
        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        [void]$fileBrowser.ShowDialog()
        $csvFile = $fileBrowser.FileName

        #GET DATA FROM CSV FILE
        $csvData = Import-Csv -Path $csvFile

        #CREATING A VARIABLE AND ARRAY FOR THE SECURITY COUNTER
        $securityCounter = 0
        $doNotMigrateArray = @()

        #CREATING A VARIABLE AND ARRAY FOR THE MIGRATION COUNTER
        $migrationCounter = 0
        $migratedListArray = @()
        $safeToMigrateArray = @()

        #CREATING A VARIBALES FOR THE PROGRESS BAR
        $progressBar = 0
        $totalDLS = $csvData.Count

        foreach ($row in $csvData) {

            #PROGRESS BAR
            $progressBar++
            Write-Progress -Status "Processing $($row.EmailAddress)" -Activity "$progressBar out of $totalDLS" -PercentComplete ($progressBar / $csvData.Count * 100)

            #CHECKING IF THE DL IS A SECURITY GROUP
            $distributionGroup = $row.'EmailAddress '
            $doNotMigrate = Get-DistributionGroup $distributionGroup
            if ($doNotMigrate.GroupType -like "*SecurityEnabled*") {
                $securityCounter++
                $doNotMigrateArray += $row.EmailAddress
                Start-Sleep -Milliseconds 20

            }
            else {
                #DL INFORMATION GATHERING
                $distributionList = Get-DistributionGroup $row.'EmailAddress '
                $displayName = $distributionList.DisplayName
                $alias = $distributionList.Alias
                $manager = $distributionList.ManagedBy
                $members = Get-DistributionGroupMember $row.'EmailAddress ' | Select-Object Name
                $primaryEmail = $distributionList.PrimarySmtpAddress
                $deliveryManagment = $distributionList.AcceptMessagesOnlyFrom
                $openInternet = $distributionList.RequireSenderAuthenticationEnabled

                #ADDING INFORMATION TO AN ARRAY AND INCREASING THE MIGRATION COUNTER
                $safeToMigrateArray += @{DisplayName = $displayName; Alias = $alias; ManagedBy = $manager; Members = $members.Name; PrimaryEmail = $primaryEmail; RequireSenderAuthenticationEnabled = $openInternet; DeliveryManagement = $deliveryManagment }
                $migrationCounter++
                $migratedListArray += $row.'EmailAddress '
                Start-Sleep -Milliseconds 20
            }
        }

        #EXPORTS THE TXT FILE
            (ConvertTo-Json $safeToMigrateArray) | Out-File -FilePath "Input Local File Path Here"

        #CREATING A VARIABLE FOR DELTEING DLS FROM ON-PREM PROGRESS BAR
        $deleteProgressBar = 0
        $totalToDelete = $migratedListArray.Count

        foreach ($item in $migratedListArray) {
            #PROGRESS BAR
            $deleteProgressBar++
            Write-Progress -Status "Processing Deletion of $item"  -Activity "$deleteProgressBar out of $totalToDelete" -PercentComplete (($deleteProgressBar / $migratedListArray.Count) * 100)

            #DELETE EACH DL FROM ON-PREM SERVER
            Remove-DistributionGroup -Identity $item
            Start-Sleep -Milliseconds 20
        }

    }

    # NO SELECTION EXIT
    if ($dlChoice -eq "") { return }
}

Catch {
    Write-Host -f Red "Error:" $_.Exception.Message
}