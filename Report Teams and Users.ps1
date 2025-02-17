# Connect to Microsoft Teams
# Connect-MicrosoftTeams

# Path to the CSV file containing the list of Team URLs
$teamsFile = "C:\Users\dhruv.sandoval\Danaher\CEP Kaizens EMEA - 1. Prework\Amy - United Kingdom\migration_TeamsIds.csv"

# Import the list of Team URLs
$AllTeamsInOrg = Import-Csv -Path $teamsFile

#Set the filename and location
$exportLocation = "C:\Users\dhruv.sandoval\Danaher\CEP Kaizens EMEA - 1. Prework\Amy - United Kingdom\teams_users_with_access.csv"
$Path = $exportLocation

$TeamReport = @()
foreach($team in $AllTeamsInOrg) {
    try {

   
        #Connect to Teams
        #$UserCredential = Get-Credential
        #Connect-MicrosoftTeams -Credential $UserCredential

        # Create variable of all Groups IDs
        #$AllTeamsInOrg = $Team.TeamId
        
        
            
            #Get all Users in Team
                $users = Get-TeamUser -GroupId $team.TeamId
                $teamChannels = Get-TeamAllChannel -GroupId $team.TeamId

                try {
                    foreach($teamChannel in $teamChannels){
                        $teamName = Get-Team -GroupId $team.TeamId 
                        Get-TeamChannelUser -GroupId $team.TeamId -DisplayName $teamChannel.DisplayName
                        ForEach($user in $users) {
            
                            # Create an object to hold all values
                            $teamReportObject = New-Object PSObject -Property @{
                                TeamName = $teamName.DisplayName
                                GroupID = $team.TeamId
                                ChannelName = $teamChannel.DisplayName
                                ChannelId = $teamChannel.Id
                                User = $user.Name
                                Email = $user.User
                                Role =  $user.Role
                            }
                            # Add to the report
                        $TeamReport += $teamReportObject
        
                            
                        }
                        

                    }
                }
                catch {
                    Write-Host -f Red "Error in channel '$teamId': $($_.Exception.Message)"
                }
                
            #get details for each user
                
            
        

    }
    catch {
        Write-Host -f Red "Error '$teamId': $($_.Exception.Message)"
    }
    

}
#export csv file 
$TeamReport | select 'TeamName', 'GroupID', 'ChannelName', 'ChannelId', 'User', 'Email', 'Role' | Export-CSV $Path -NoTypeInformation
Write-Host  "Report exported to $($Path)"  



