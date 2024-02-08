

####################### LEARNING MATERIALS #######################
#  https://learn.microsoft.com/en-us/powershell/module/exchange/add-distributiongroupmember?view=exchange-ps
#  https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.openfiledialog?view=windowsdesktop-8.0

Try {
	#CONNECT TO EXCHANGE ONLINE
	$testExchangeOnlineConnection = Get-ConnectionInformation
	If (!($testExchangeOnlineConnection)) {
		Connect-ExchangeOnline -ShowBanner:$False
	}

	#FINDS THE CSV FILE
	Write-Host "Please select the CSV file needed for Distribution Group Update."
	Add-Type -AssemblyName System.Windows.Forms
	$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
	[void]$fileBrowser.ShowDialog()
	$csvFile = $fileBrowser.FileName


	#GET DATE FROM CSV FILE
	$csvData = Import-Csv -Path $csvFile

	#FUNCTION FOR ADD OR REMOVE FROM DISTRIBUTION GROUP
	function AddRemove-Menu {
		param (
			[string]$menuTitle = "Add or Remove"
		)
		Clear-Host
		Write-Host "=================== $menuTitle ==================="


		Write-Host "1: Press '1' to Add users to a Distribution Group"
		Write-Host "2: Press '2' to Remove users from a Distribution Group"
	}
	Clear-Host

	#PROMPT TO ADD OR REMOVE USERS
	AddRemove-Menu
	$update = Read-Host "Please make a selection"
	switch ($update) {
		'1' {
			'Add Users'
		}
		'2' {
			'Remove Users'
		}
	}

	#ADD USERS
	if ($update -eq 1) {
		Clear-Host

		#CREATING A VARIABLE AND ARRAY TO TRACK USERS ALREADY EXISTING AND ADDED
		$userAddedCounter = 0
		$userAddedArray = @()

		#CREATING A VARIBALES FOR THE PROGRESS BAR
		$progressBar = 0
		$totalUsersAdded = $csvData.Count

		foreach ($row in $csvData) {

			#PROGRESS BAR
			$progressBar++
			Write-Progress -Status "Processing $($row.Users)" -Activity "$progressBar out of $totalUsersAdded" -PercentComplete ($progressBar / $csvData.Count * 100)
			Start-Sleep -Milliseconds 20

			#GET THE DISTRIBUTION GROUP
			$group = Get-DistributionGroup -Identity $row.GroupEmail

			If ($group -ne $null) {
				#GET EXISTING MEMBERS OF THE GROUP
				$groupMembers = Get-distributiongroupmember -Identity $row.GroupEmail -ResultSize Unlimited | Select-Object -Expand PrimarySmtpAddress

				#GET USERS TO ADD TO THE GROUP
				$usersToAdd = $row.Users -split ","

				#ADD EACH USER TO THE DISTRIBUTION LIST
				foreach ($user in $usersToAdd) {

					#CHECK IF THE GROUP HAS THE MEMBER ALREADY
					If ($groupMembers -contains $user) {
						$userAddedCounter++
						$userAddedArray += $user
					}
					else {
						add-distributiongroupmember -Identity $row.GroupEmail -Member $user -WhatIf
						$userAddedCounter
						$userAddedArray += $user
					}
				}
			}

			Else {
				Write-Host "Could not Find Group:"$row.GroupName
			}
		}
		#OUTPUTS THE AMOUNT OF USERS ADDED OUT OF THE TOTAL AMOUNT OF USERS PROVIDED TO THE SCRIPT
		Write-Host "$($userAddedCounter) users Added out of $($csvData.Count)"
	}

	#REMOVE USERS
	if ($update -eq 2) {
		Clear-Host

		#CREATING A VARIABLE AND ARRAY TO TRACK USERS ALREADY REMOVED AND THOSE BEING REMOVED
		$userRemovedCounter = 0
		$userRemovedArray = @()

		#CREATING A VARIBALES FOR THE PROGRESS BAR
		$progressBar = 0
		$totalUsersRemoved = $csvData.Count

		foreach ($row in $csvData) {

			ROGRESS BAR
			$progressBar++
			Write-Progress -Status "Processing $($row.Users)" -Activity "$progressBar out of $totalUsersRemoved" -PercentComplete ($progressBar / $csvData.Count * 100)
			Start-Sleep -Milliseconds 20

			#GET THE DISTRIBUTION GROUP
			$group = Get-DistributionGroup -Identity $row.GroupEmail

			If ($group -ne $null) {
				#GET EXISTING MEMBERS OF THE GROUP
				$groupMembers = Get-distributiongroupmember -Identity $row.GroupEmail -ResultSize Unlimited | Select-Object -Expand PrimarySmtpAddress

				#GET USERS TO REMOVE FROM THE GROUP
				$usersToRemove = $row.Users -split ","

				#REMOVE EACH USER FROM THE DISTRIBUTION LIST
				foreach ($user in $usersToRemove) {
					#CHECK IF MEMBER HAS ALREADY BEEN REMOVED
					If ($groupMembers -notcontains $user) {
						$userRemovedCounter++
						$userRemovedArray += $user
					}
					Else {
						remove-distributiongroupmember -Identity $row.GroupEmail -Member $user
						$userRemovedCounter
						$userRemovedArray += $user
					}
				}
			}

			Else {
				Write-Host "Could not Find Group:"$row.GroupName
			}
		}
		#OUTPUTS THE AMOUNT OF USERS REMOVED OUT OF THE TOTAL AMOUNT OF USERS PROVIDED TO THE SCRIPT
		Write-Host "$($userRemovedCounter) users removed out of $($csvData.Count)"
	}
	# NO SELECTION EXIT
	if ($update -eq "") { return }
}
Catch {
	Write-Host -f Red "Error:" $_.Exception.Message
}