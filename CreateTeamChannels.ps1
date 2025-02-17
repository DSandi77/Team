$excelFile = "C:\Users\dhruv.sandoval\OneDrive - Danaher\Documents\channelCreationItaly.csv"
#This script will get or create Teams
$TeamName = "CEP-EMEA-Italy"
$TeamDescription = "This is the Italy country Teams where all the teams will reside within Channels"
$TeamVisability = "Private" #Public or Private
$TeamOwner = "dhruv.sandoval@cepheid.com"


try {
    #Connect-MicrosoftTeams
    try {
        Write-Host -f Green "`t`Team is getting crated: "
        $teamId = New-Team -DisplayName $TeamName -Visibility $TeamVisability -Description $TeamDescription -MailNickName $TeamName -Owner $TeamOwner -AllowCreatePrivateChannels false -AllowDeleteChannels false 
        Write-Host $teamId.GroupId " with name " 
        write-host $teamId.Name
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-host -f Red "`t`Error Creating Teams" $_.Exception.Message
    }

    Try {
        $channelData = Import-Csv -Path $excelFile
        $group = $teamId.GroupId


        foreach($Channel in $channelData){
            try {
                Write-Host -f Green "`t`Creating Channels" $Channel.ChannelName
                $newChannel = New-TeamChannel -GroupId $group  -membership Private -DisplayName $Channel.ChannelName 
                Write-Host $newChannel.DisplayName "`t`Created successfully"
                
            }
            catch {
                Write-host -f Red "`t`Error Creating Team:" $_.Exception.Message
                <#Do this if a terminating exception happens#>
            }
        }
    }
    catch {
        Write-host -f Red "`t`Error Creating Team:" $_.Exception.Message
        <#Do this if a terminating exception happens#>
    }

    Write-Host
    Write-Host -f Green "`t`Teams and Channels all created successfully."
        
}
catch {
    Write-host -f Red "`t`Error Connecting" $_.Exception.Message
    <#Do this if a terminating exception happens#>
}
