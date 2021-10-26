#kb4504722
Get-ChildItem -Path "$env:SystemRoot\System32" -Name "*4504722*" -Recurse -Force
Get-ChildItem -Path "$env:SystemRoot\SysWOW64" -Name "*4504722*" -Recurse -Force


Get-ChildItem -Path "$env:SystemRoot\System32" -Include "*4504722*" -Recurse -Force
Get-ChildItem -Path "$env:SystemRoot\SysWOW64" -Include "*4504722*" -Recurse -Force
#msiexec /package {product_code} /uninstall "full_path_to_.msp_file" /qb

Get-ChildItem -Path "$env:SystemRoot\SysWOW64" -Include "*.msp*" -Recurse -Force

# Gives a list of all Microsoft Updates sorted by KB number/HotfixID

# By Tom Arbuthnot. Lyncdup.com

 

$wu = new-object -com “Microsoft.Update.Searcher”

 

$totalupdates = $wu.GetTotalHistoryCount()

 

$all = $wu.QueryHistory(0,$totalupdates)

 

# Define a new array to gather output

 $OutputCollection=  @()

             

Foreach ($update in $all)

    {

    $string = $update.title

 

    $Regex = “KB\d*”

    $KB = $string | Select-String -Pattern $regex | Select-Object { $_.Matches }

 

     $output = New-Object -TypeName PSobject

     $output | add-member NoteProperty “HotFixID” -value $KB.‘ $_.Matches ‘.Value

     $output | add-member NoteProperty “Title” -value $string

     $OutputCollection += $output

 

    }

 

# Oupput the collection sorted and formatted:

$OutputCollection | Sort-Object HotFixID | Format-Table -AutoSize

Write-Host “$($OutputCollection.Count) Updates Found”

 

# If you want to output the collection as an object, just remove the two lines above and replace them with “$OutputCollection”

 

# credit/thanks:

# http://blogs.technet.com/b/tmintner/archive/2006/07/07/440729.aspx

# http://www.gfi.com/blog/windows-powershell-extracting-strings-using-regular-expressions/