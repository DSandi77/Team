Import-Module Sharegate

$excelFile = "C:\Users\dhruv.sandoval\OneDrive - Danaher\Spain\SpainMigrationData.csv"
$logFile = "C:\Users\dhruv.sandoval\OneDrive - Danaher\Spain\migration_log.csv"


# Create an empty array to store migration data
$migrationResults = @()

# Variables to store previous URLs
$prevSrcSiteUrl = ""
$prevDstSiteUrl = ""

Try {
    $migrationData = Import-Csv -Path $excelFile

    # Calculate total number of migrations for the progress bar
    $totalMigrations = $migrationData.Count

    $currentMigration = 1
    foreach ($migrationSite in $migrationData) {
    # Calculate and display the progress bar
            $percentComplete = ($currentMigration / $totalMigrations) * 100
            Write-Progress -Activity "Migrating Sites" -Status "Progress: $currentMigration of $totalMigrations" -PercentComplete $percentComplete 
            $currentMigration++
        try {
            
            Write-Host
            Write-Host
            Write-Host -f Yellow "Migrating: $($migrationSite.'Channel Source')"
            Write-Host   $migrationSite.siteUrl

            # Check if source site URL has changed
            if ($migrationSite.siteUrl -ne $prevSrcSiteUrl) {
                $srcSite = Connect-Site -Url $migrationSite.siteUrl -Browser
                Write-Host -f Green "Connected to Source Site Correctly"
                $prevSrcSiteUrl = $migrationSite.siteUrl 
            }

            Write-Host
            Write-Host   $migrationSite.TargetUrl

            # Check if target site URL has changed
            if ($migrationSite.TargetUrl -ne $prevDstSiteUrl) {
                $dstSite = Connect-Site -Url $migrationSite.TargetUrl -Browser
                $prevDstSiteUrl = $migrationSite.TargetUrl
                Write-Host -f Green "Connected to Destination Site Correctly"
            }

            $srcList = Get-List -Name "Documents" -Site $srcSite
            $dstList = Get-List -Name "Documents" -Site $dstSite
            Write-Host
            Write-Host

            try {
                Write-Host "First try migration...."
                Copy-Content -SourceList $srcList -DestinationList $dstList -SourceFilePath $migrationSite.SourceURL -DestinationFolder $migrationSite.DestinationFolder
                Write-Host -f Green "Successfully Migrated (using TargetTeams):"
                Write-Host $($migrationSite.'Channel Source')

                # Add migration data to the array
                $migrationResults += [PSCustomObject]@{
                    Teams = $migrationSite.'Target Teams'
                    Channel = $migrationSite.TargetTeams
                    ChannelSource = $migrationSite.'Channel Source'
                    SourceURL = $migrationSite.SourceURL
                    TargetURL = $migrationSite.TargetUrl
                    TargetFolder = $migrationSite.DestinationFolder

                    Status = "Success"
                    Error = $_.Exception.Message
                }
            }
            catch {
                # If destination folder doesn't exist, try TargetTeams
                Write-Host -f red $errorMessage = $_.Exception.Message
                Write-Host
                write-host -f Yellow "We are trying to create the requested Folder" $errorMessage = $_.Exception.Message
#                if ( $errorMessage.startswith("Error moving data:")) {
                    try{

                        write-host "Connecting to Site using PNP:"
                        # Connect to PnP Online
                        Connect-PnPOnline -Url $migrationSite.TargetUrl -useweblogin

                        $folderName = $migrationSite.Folder
                        $folderUrl = $migrationSite.DestinationFolder
                        $creationFolder = "Shared Documents/" + $migrationSite.'Target Teams'

                        # Check if the folder already exists
                        write-host $creationFolder
                        $folderExists = Get-PnPFolder -Url $folderUrl -ErrorAction SilentlyContinue

                        if ($folderExists) {
                                Write-Host "Folder '$folderName' already exists in '$folderUrl'."
                            } else {
                                # Create the folder if it doesn't exist
                                Add-PnPFolder -Name $folderName -Folder $creationFolder
                                Write-Host "Folder '$folderName' created in '$folderUrl'."
                            }
                        }
                        catch {
                            Write-Host
                            Write-Host
                            Write-Host -f Red "failed to create Folder: $($_.Exception.Message)"
                            }


                    Write-Host -f Yellow "Retrying with TargetTeams folder..."
                    Copy-Content -SourceList $srcList -DestinationList $dstList -SourceFilePath $migrationSite.SourceURL -DestinationFolder $migrationSite.DestinationFolder
                    Write-Host -f Green "Successfully Migrated (using TargetTeams):"
                    Write-Host $($migrationSite.'Channel Source')

                    # Add migration data to the array
                    $migrationResults += [PSCustomObject]@{
                        
                        Teams = $migrationSite.'Target Teams'
                        Channel = $migrationSite.TargetTeams
                        ChannelSource = $migrationSite.'Channel Source'
                        SourceURL = $migrationSite.SourceURL
                        TargetURL = $migrationSite.TargetUrl
                        TargetFolder = $migrationSite.DestinationFolder
                        #FinalUrl = $contentMigrated.URL
                        Status = "Success"
                        Error = $_.Exception.Message
                    }
#                }
#                else {
#                    # Re-throw the exception if it's not related to the destination folder
#                    throw $_.Exception
#                }
            }

        }
        catch {
            Write-Host
            Write-Host
            Write-Host -f Red "Error moving data: $($_.Exception.Message)"

            # Add migration data to the array
            $migrationResults += [PSCustomObject]@{
                SourceURL = $migrationSite.SourceURL
                TargetURL = $migrationSite.TargetUrl
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }

        

        
    }
    Write-Host
    Write-Host
    Write-Host -F Blue "Exporting report to....."
    Write-Host -f Green $logFile
    # Export the migration data to a CSV file
    $migrationResults | Export-Csv -Path $logFile -NoTypeInformation
}
catch {
    Write-Host -f Red "Error adding user to Team: $($_.Exception.Message)"
}
