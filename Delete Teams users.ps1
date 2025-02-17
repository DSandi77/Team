$excelFile = "C:\Users\dhruv.sandoval\OneDrive - Danaher\spain\UserstoRemove.csv"


Connect-MicrosoftTeams

Try {
    $membersData = Import-Csv -Path $excelFile
    

##### Remember to enable the line below if it is the first time running the code after a long time. 
    


    <# We are Removing Team Users first with their respective Role.  #>
    foreach($membersDataUser in $membersData){
        try {
            Write-Host "Removing member" $membersDataUSer.Email "from Team Channel:" $membersDataUser.ChannelName

                $newmembersDataUser = Remove-TeamUser -GroupId $membersDataUser.GroupID -User $membersDataUser.Email 
                Write-Host -f Green $newmembersDataUser.Email "Removed successfully"
            
        }
        catch {
            Write-host -f Red "Could not Remove team member" $_.Exception.Message
        }
    }
}
catch {
    Write-host -f Red "Error adding Team member to channel and Team:" $_.Exception.Message
    <#Do this if a terminating exception happens#>
}







