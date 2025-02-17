$excelFile = "C:\Users\dhruv.sandoval\OneDrive - Danaher\Spain\MembersMigration.csv"
$group = "eee6e7c7-d646-4a74-a476-6b9d53b5b7ab"
$ownerCondition = "Owner"

Connect-MicrosoftTeams

Try {
    $membersData = Import-Csv -Path $excelFile
    $currentTeam = Get-TeamUser -GroupId $group

##### Remember to enable the line below if it is the first time running the code after a long time. 
    


    <# We are adding Team Users first with their respective Role.  #>
    foreach($membersDataUser in $membersData){
        try {
            #$userFound = Get-Team -GroupId $group -User $membersDataUSer.userEmail
            foreach($currentUser in $currentTeam){
                try {
                    Write-Host "Adding member" $membersDataUSer.userEmail "to Team Channel:" $membersDataUser.ChannelName
                    if ($currentUser.email -eq $membersDataUSer.email) {
                        <# We are making sure that the user that we are trying to add does not already exist. #>
                        Write-Host -f Yellow "User already exists in Team"
                    }else {
                        <# if the user does not exist we will add them to the list of users with their respective permission level. #>
                        #Write-Host  "Adding member" $membersDataUSer.userEmail "to Team Channel:" $membersDataUser.ChannelName
                        $newmembersDataUser = Add-TeamUser -GroupId $group -User $membersDataUser.userEmail -Role $membersDataUser.role
                        Write-Host -f Green $newmembersDataUser.userEmail "Added successfully"
                    }
                }
                catch {
                    Write-host -f Red "Could not add team member" $_.Exception.Message
                }
            } 
        }
        catch {
            Write-host -f Red "Error adding user to Team:" $_.Exception.Message
            <#Do this if a terminating exception happens#>
        }
    }


    foreach($channelMember in $membersData){
        try {
            Write-Host -f Green "Adding member" $membersDataUSer.userEmail "to Team Channel:" $membersDataUser.ChannelName
            
            $newchannelMember = Add-TeamChannelUser -GroupId $group -DisplayName $channelMember.ChannelName -User $channelMember.userEmail 
            Write-Host $newchannelMember "Added successfully"

            if ($channelMember.role -eq $ownerCondition ) {
                <# We have to add the members and then make them owners #>
                Write-Host -f Green "Adding Owner to Channels" $channelMember.ChannelName
                $newOwner = Add-TeamChannelUser -GroupId $group -DisplayName $channelMember.ChannelName -User $channelMember.userEmail -Role Owner
                Write-Host $newOwner "Owner Added successfully"
            }
        }
        catch {
            Write-host -f Red "Error adding user to Channel:" $_.Exception.Message
            <#Do this if a terminating exception happens#>
        }
    }
    Write-Host -f Blue "All users were added successfully. Congrats!"
}
catch {
    Write-host -f Red "Error adding Team member to channel and Team:" $_.Exception.Message
    <#Do this if a terminating exception happens#>
}








