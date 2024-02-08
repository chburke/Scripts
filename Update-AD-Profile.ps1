Try {
    #COLLECTS THE CREDENTIALS OF THE ADMINS ACCOUNT
    if ($creds -eq $null) {
        $creds = Get-Credential  -Message "Enter Elevated Credentials"
    }

    #FUCNTION CHOOSING MULTIPLE OR A SINGLE ASSOCIATE
    function SingleMultiple-Menu {
        param (
            [string] $singleMultipleMenu = "Individual or Multuple Associates"
        )
        Write-Host "=================== $singleMultipleMenu ==================="


        Write-Host "1: Press '1' for an Individual Associate"
        Write-Host "2: Press '2' for Multiple Associates"
    }
    Clear-Host

    # FUNCTION FOR ADD OR REMOVE A LICENSE
    function AddRemove-Menu {
        param (
            [string] $addRemoveMenu = "Add or Remove License"
        )
        Write-Host "=================== $addRemoveMenu ==================="


        Write-Host "1: Press '1' for Adding a license"
        Write-Host "2: Press '2' for Removing a license"
    }
    Clear-Host

    #FUCNTION FOR WHICH ATTRIBUTE NEEDS UPDATED
    function ChooseAttribute-Menu {
        param (
            [string] $menuTitle = "Which Attribute"
        )
        Write-Host "=================== $menuTitle ==================="


        Write-Host "1: Press '1' for Extension Attribute 5"
        Write-Host "2: Press '2' for Extension Attribute 6"
    }
    Clear-Host

    #FUNCTION FOR WHICH LICENSE NEEDS APPLIED
    function LicenseType-Menu {
        param (
            [string] $licenseMenu = "License Types"
        )
        Clear-Host
        Write-Host "=================== $licenseMenu ==================="

        Write-Host "1: Press '1' for VisioP1"
        Write-Host "2: Press '2' for VisioP2"
        Write-Host "3: Press '3' for ProjectP1"
        Write-Host "4: Press '4' for ProjectP3"
        Write-Host "5: Press '5' for O365PowerBI"
        Write-Host "6: Press '6' for O365PowerBIPrem"
    }
    Clear-Host

    #FUNCTION FOR O365 LICENSE
    function o365LicenseType-Menu {
        param (
            [string] $o365LicenseMenu = "O365 License Types"
        )
        Clear-Host
        Write-Host "=================== $o365LicenseMenu ==================="

        Write-Host "1: Press '1' for O365E3-NoExch"
        Write-Host "2: Press '2' for O365E3"
        Write-Host "3: Press '3' for M365E3"
        Write-Host "4: Press '4' for O365E3+EMSE3"
    }
    Clear-Host

    #PROMPT FOR WHICH ATTRIBUTE NEEDS CHANGED
    SingleMultiple-Menu
    $update = Read-Host "Please make a selection"
    switch ($update) {
        '1' {
            'Individual Associate'
        }
        '2' {
            'Multiple Associates'
        }
    }

    #INDIVIDUAL ASSOCIATE UPDATE
    if ($update -eq 1) {
        Clear-Host

        #PROMPT FOR NETWORK ID
        $userNetworkID = Read-Host "Enter the users network ID"

        #GETS THE USERS CURRENT EXTENSION ATTRIBUTE 5 SETTINGS
        $currentSettings = Get-ADUser $userNetworkID -Properties extensionattribute5

        #OPTION FOR ADD OR REMOVE
        AddRemove-Menu
        $option = Read-Host "Choose if you want to Add ore Move a license"

        # ADDING A LICENSE
        if ($option -eq 1) {

            #STORES THE ATTRIBUTE OPTION THE USER CHOSE
            ChooseAttribute-Menu
            $selectedAttribute = Read-Host "Choose which attribute needs updated"

            # CREATING ARRAY NEEDED TO REMOVE LICENSE
            [System.Collections.ArrayList]$currentExtension5Array = @()

            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

            # EXTENION ATTRIBUTE 5 ADDING LICENSE UPDATE
            if ($selectedAttribute -eq 1) {

                # STORES THE LICENSE OPTION THE USER CHOSE
                LicenseType-Menu
                $selectedLicense = Read-Host "Choose the license needed"

                #SWITCH USED TO DETEREMINE WHICH LICENSE TO ADD TO THE USER ACCOUNT
                switch ($selectedLicense) {
                    '1' {
                        if ($currentSettings.extensionattribute5 -split ";" -notcontains "VisioP1") {
                            $currentExtension5Array.Remove("VisioP2")
                            $newExtension5 = $currentExtension5Array -join ";"
                            Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$($newExtension5)VisioP1;" } -Credential $creds
                            Write-Host "License Update Completed"
                        }
                    }
                    '2' {
                        if ($currentSettings.extensionattribute5 -split ";" -notcontains "VisioP2") {
                            $currentExtension5Array.Remove("VisioP1")
                            $newExtension5 = $currentExtension5Array -join ";"
                            Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$($newExtension5)VisioP2;" } -Credential $creds
                            Write-Host "License Update Completed"
                        }
                    }
                    '3' {
                        if ($currentSettings.extensionattribute5 -split ";" -notcontains "ProjectP1") {
                            $currentExtension5Array.Remove("ProjectP3")
                            $newExtension5 = $currentExtension5Array -join ";"
                            Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$($newExtension5)ProjectP1;" } -Credential $creds
                            Write-Host "License Update Completed"
                        }
                    }
                    '4' {
                        if ($currentSettings.extensionattribute5 -split ";" -notcontains "ProjectP3") {
                            $currentExtension5Array.Remove("ProjectP1")
                            $newExtension5 = $currentExtension5Array -join ";"
                            Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$($newExtension5)ProjectP3;" } -Credential $creds
                            Write-Host "License Update Completed"
                        }
                    }
                    '5' {
                        if ($currentSettings.extensionattribute5 -split ";" -notcontains "O365PowerBI") {
                            $currentExtension5Array.Remove("O365PowerBIPrem")
                            $newExtension5 = $currentExtension5Array -join ";"
                            Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$($newExtension5)O365PowerBI;" } -Credential $creds
                            Write-Host "License Update Completed"
                        }
                    }
                    '6' {
                        if ($currentSettings.extensionattribute5 -split ";" -notcontains "O365PowerBIPrem") {
                            $currentExtension5Array.Remove("O365PowerBI")
                            $newExtension5 = $currentExtension5Array -join ";"
                            Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$($newExtension5)O365PowerBIPrem;" } -Credential $creds
                            Write-Host "License Update Completed"
                        }
                    }
                }
            }

            # EXTENSION ATTRIBUTE 6 UPDATE
            if ($selectedAttribute -eq 2) {

                # STORES THE LICENSE OPTION THE USER CHOSE FOR O365
                o365LicenseType-Menu
                $selectedLicense = Read-Host "Choose the license needed"

                #SWITCH USED TO DETEREMINE WHICH LICENSE TO ADD TO THE USER ACCOUNT
                switch ($selectedLicense) {
                    '1' {
                        Set-ADUser $userNetworkID -Replace @{extensionattribute6 = "O365E3-NoExch" } -Credential $creds
                        Get-ADUser $userNetworkID -Properties extensionattribute6 | Select-Object extensionattribute6
                    }
                    '2' {
                        Set-ADUser $userNetworkID -Replace @{extensionattribute6 = "O365E3" } -Credential $creds
                        Get-ADUser $userNetworkID -Properties extensionattribute6 | Select-Object extensionattribute6
                    }
                    '3' {
                        Set-ADUser $userNetworkID -Replace @{extensionattribute6 = "M365E3" } -Credential $creds
                        Get-ADUser $userNetworkID -Properties extensionattribute6 | Select-Object extensionattribute6
                    }
                    '4' {
                        Set-ADUser $userNetworkID -Replace @{extensionattribute6 = "O365E3+EMSE3" } -Credential $creds
                        Get-ADUser $userNetworkID -Properties extensionattribute6 | Select-Object extensionattribute6
                    }
                }
            }
        }

        # REMOVING A LICENSE
        if ($option -eq 2) {

            #STORES THE ATTRIBUTE OPTION THE USER CHOSE
            ChooseAttribute-Menu
            $selectedAttribute = Read-Host "Choose which attribute needs updated"

            # EXTENION ATTRIBUTE 5 REMOVING LICENSE UPDATE
            if ($selectedAttribute -eq 1) {

                # STORES THE LICENSE OPTION THE USER CHOSE
                LicenseType-Menu
                $selectedLicense = Read-Host "Choose the license needed"

                # CREATING ARRAY NEEDED TO REMOVE LICENSE
                [System.Collections.ArrayList]$currentExtension5Array = @()

                # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                #SWITCH USED TO DETEREMINE WHICH LICENSE TO ADD TO THE USER ACCOUNT
                switch ($selectedLicense) {
                    '1' {
                        $currentExtension5Array.Remove("VisioP1")
                        $newExtension5 = $currentExtension5Array -join ";"
                        Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                        Write-Host "License Remove Completed"
                    }
                    '2' {
                        $currentExtension5Array.Remove("VisioP2")
                        $newExtension5 = $currentExtension5Array -join ";"
                        Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                        Write-Host "License Remove Completed"
                    }
                    '3' {
                        $currentExtension5Array.Remove("ProjectP1")
                        $newExtension5 = $currentExtension5Array -join ";"
                        Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                        Write-Host "License Remove Completed"
                    }
                    '4' {
                        $currentExtension5Array.Remove("ProjectP3")
                        $newExtension5 = $currentExtension5Array -join ";"
                        Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                        Write-Host "License Remove Completed"
                    }
                    '5' {
                        $currentExtension5Array.Remove("O365PowerBI")
                        $newExtension5 = $currentExtension5Array -join ";"
                        Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                        Write-Host "License Remove Completed"
                    }
                    '6' {
                        $currentExtension5Array.Remove("O365PowerBIPrem")
                        $newExtension5 = $currentExtension5Array -join ";"
                        Set-ADUser $userNetworkID -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                        Write-Host "License Remove Completed"
                    }
                }
            }
            # EXTENSION ATTRIBUTE 6 REMOVING LICENSE UPDATE
            if ($selectedAttribute -eq 2) {
                Set-ADUser $userNetworkID -Clear extensionattribute6 -Credential $creds
                Write-Host "License Remove Completed"
            }
        }
    }

    # MULTIPLE ASSOCIATES UPDATE
    if ($update -eq 2) {
        Clear-Host

        #FINDS THE CSV FILE
        Write-Host "Please select the CSV file"
        Add-Type -AssemblyName System.Windows.Forms
        $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        [void]$fileBrowser.ShowDialog()
        $csvFile = $fileBrowser.FileName

        #GET DATA FROM CSV FILE
        $csvData = Import-Csv -Path $csvFile

        #OPTION FOR ADD OR REMOVE
        AddRemove-Menu
        $option = Read-Host "Choose if you want to Add ore Move a license"

        # ADDING A LICENSE
        if ($option -eq 1) {

            #STORES THE ATTRIBUTE OPTION THE USER CHOSE
            ChooseAttribute-Menu
            $selectedAttribute = Read-Host "Choose which attribute needs updated"

            # EXTENSION ATTRIBUTE 5  ADDING LICENSE UPDATE
            if ($selectedAttribute -eq 1) {

                # STORES THE LICENSE OPTION THE USER CHOSE
                LicenseType-Menu
                $selectedLicense = Read-Host "Choose the license needed"

                #SWITCH USED TO DETEREMINE WHICH LICENSE TO ADD TO THE USER ACCOUNT
                switch ($selectedLicense) {
                    '1' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -notcontains "VisioP1") {
                                $currentExtension5Array.Remove("VisioP2")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$($newExtension5)VisioP1;" } -Credential $creds
                            }
                        }
                    }
                    '2' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -notcontains "VisioP2") {
                                $currentExtension5Array.Remove("VisioP1")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$($newExtension5)VisioP2;" } -Credential $creds
                            }
                        }
                    }
                    '3' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -notcontains "ProjectP1") {
                                $currentExtension5Array.Remove("ProjectP3")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$($newExtension5)ProjectP1;" } -Credential $creds
                            }
                        }
                    }
                    '4' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -notcontains "ProjectP3") {
                                $currentExtension5Array.Remove("ProjectP1")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$($newExtension5)ProjectP3;" } -Credential $creds
                            }
                        }
                    }
                    '5' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -notcontains "O365PowerBI") {
                                $currentExtension5Array.Remove("O365PowerBIPrem")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$($newExtension5)O365PowerBI;" } -Credential $creds
                            }
                        }
                    }
                    '6' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -notcontains "O365PowerBIPrem") {
                                $currentExtension5Array.Remove("O365PowerBI")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$($newExtension5)O365PowerBIPrem;" } -Credential $creds
                            }
                        }
                    }
                }
            }

            # EXTENSION ATTRIBUTE 6 UPDATE
            if ($selectedAttribute -eq 2) {

                # STORES THE LICENSE OPTION THE USER CHOSE FOR O365
                o365LicenseType-Menu
                $selectedLicense = Read-Host "Choose the license needed"

                #SWITCH USED TO DETEREMINE WHICH LICENSE TO ADD TO THE USER ACCOUNT
                switch ($selectedLicense) {
                    '1' {
                        foreach ($user in $csvData) {
                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute6
                            Set-ADUser $user.USERS -Replace @{extensionattribute6 = "O365E3-NoExch" } -Credential $creds
                        }
                    }
                    '2' {
                        foreach ($user in $csvData) {
                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute6
                            Set-ADUser $user.USERS -Replace @{extensionattribute6 = "O365E3" } -Credential $creds
                        }
                    }
                    '3' {
                        foreach ($user in $csvData) {
                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute6
                            Set-ADUser $user.USERS -Replace @{extensionattribute6 = "M365E3" } -Credential $creds
                        }
                    }
                    '4' {
                        foreach ($user in $csvData) {
                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute6
                            Set-ADUser $user.USERS -Replace @{extensionattribute6 = "O365E3+EMSE3" } -Credential $creds
                        }
                    }
                }
            }
        }

        # REMOVING A LICENSE
        if ($option -eq 2) {

            #STORES THE ATTRIBUTE OPTION THE USER CHOSE
            ChooseAttribute-Menu
            $selectedAttribute = Read-Host "Choose which attribute needs updated"

            # EXTENION ATTRIBUTE 5 REMOVING LICENSE UPDATE
            if ($selectedAttribute -eq 1) {

                # STORES THE LICENSE OPTION THE USER CHOSE
                LicenseType-Menu
                $selectedLicense = Read-Host "Choose the license needed"

                #SWITCH USED TO DETEREMINE WHICH LICENSE TO REMOVE FROM THE USER ACCOUNT
                switch ($selectedLicense) {
                    '1' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -contains "VisioP1") {
                                $currentExtension5Array.Remove("VisioP1")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                            }
                        }
                    }
                    '2' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -contains "VisioP2") {
                                $currentExtension5Array.Remove("VisioP2")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                            }
                        }
                    }
                    '3' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -contains "ProjectP1") {
                                $currentExtension5Array.Remove("ProjectP1")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                            }
                        }
                    }
                    '4' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -contains "ProjectP3") {
                                $currentExtension5Array.Remove("ProjectP3")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                            }
                        }
                    }
                    '5' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -contains "O365PowerBI") {
                                $currentExtension5Array.Remove("O365PowerBI")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                            }
                        }
                    }
                    '6' {
                        foreach ($user in $csvData) {
                            # CREATING ARRAY NEEDED TO REMOVE LICENSE
                            [System.Collections.ArrayList]$currentExtension5Array = @()

                            $currentSettings = Get-ADUser $user.USERS -Properties extensionattribute5

                            # SEPARATES THE LICENSES IN EXTENSION ATTRIBUTE 5
                            $currentExtension5Array += $currentSettings.extensionattribute5 -split ";"

                            if ($currentSettings.extensionattribute5 -split ";" -contains "O365PowerBIPrem") {
                                $currentExtension5Array.Remove("O365PowerBIPrem")
                                $newExtension5 = $currentExtension5Array -join ";"
                                Set-ADUser $user.USERS -Replace @{extensionattribute5 = "$newExtension5" } -Credential $creds
                            }
                        }
                    }
                }
            }

            # EXTENSION ATTRIBUTE 6 REMOVING LICENSE UPDATE
            if ($selectedAttribute -eq 2) {
                foreach ($user in $csvData) {
                    Set-ADUser $user.USERS -Clear extensionattribute6 -Credential $creds
                }
            }
        }
    }

    # NO SELECTION EXIT
    if ($update -eq "") { return }
}
Catch {
    Write-Host -f Red "Error:" $_.Exception.Message
}