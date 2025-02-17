Import-Module Sharegate
$excelFile = "C:\Users\dhruv.sandoval\OneDrive - Danaher\Italy - CEP EMEA Main Hub Test\ItalyMigrationData.csv"

Try {
    $migrationData = Import-Csv -Path $excelFile

    foreach($migrationSite in $migrationData){
        try{
            $srcSite = Connect-Site -Url $migrationSite.SourceUrl -Browser
            $dstSite = Connect-Site -Url $migrationSite.TargetUrl -Browser
            $srcList = Get-List -Name "Documents" -Site $srcSite
            $dstList = Get-List -Name "Documents" -Site $dstSite
            #Copy-Content -SourceList $srcList -DestinationList $dstList -ExcelFilePath "c:\Users\myUser\Desktop\myExcelFile.xslx"

            Copy-Content -SourceList $srcList -DestinationList $dstList -SourceFilePath $migrationSite.SourceURL -DestinationFolder $migrationSite.DestinationFolder

        }
        catch {
            Write-host -f Red "Error moving data" $_.Exception.Message



        }
    }
    
}
catch {
    Write-host -f Red "Error adding user to Team:" $_.Exception.Message
    <#Do this if a terminating exception happens#>
}



