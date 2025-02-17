$user = "lidia.delasheras@cepheid.com"
$group = "f8526aee-ca83-43e6-a7b5-bbe47d9905b7"
$ownerCondition = "Owner"





try {
    Connect-MicrosoftTeams
    $listOfChannels = Get-TeamAllChannel -GroupId $group

    $newTeamMember = Add-TeamUser -GroupId $group -User $user -Role Owner
    Write-Host $newTeamMember "Added successfully"
    foreach($channel in $listOfChannels){
        if ($channel.MembershipType -eq "Private") {
            Write-Host $channel.DisplayName
            Add-TeamChannelUser -GroupId $group -DisplayName $channel.DisplayName -User $user 
            Write-Host -f Green $newchannelMember "Added successfully"

            Add-TeamChannelUser -GroupId $group -DisplayName $channel.DisplayName -User $user -Role Owner
        }else {
            Write-Host
            Write-Host $channel.DisplayName
            Write-Host "This is a Standard team" -f Green
        }
        

    }

    
}
catch {
    Write-host -f Red "Error adding Team member to channel and Team:" $_.Exception.Message
    <#Do this if a terminating exception happens#>
}



