# Define the directory to search. You can change this to any directory you want.
$searchDirectory = "\\filer\ca_unicenter$"

# Define the search term.
$searchTerm = "Rust@m"

# Initialize a counter for the results.
$resultCount = 0

# Get all .ps1, .cmd, and .bat files recursively.
$files = Get-ChildItem -Path $searchDirectory -Recurse -Include *.ps1, *.cmd, *.bat

# Loop through each file and check if it contains the search term.
foreach ($file in $files) {
    # Read the file content.
    $content = Get-Content -Path $file.FullName

    # Check if the content contains the search term.
    if ($content -match $searchTerm) {
        # Increment the result count.
        $resultCount++

        # Output the file path.
        Write-Output "Match found in: $($file.FullName)"
    }
}

# Display the total count of matching files.
Write-Output "`nTotal number of files containing '$searchTerm': $resultCount"

Write-Output "`nTotal number of files containing '$searchTerm': $resultCount" |out-file .\amountofpackageandscripts.txt
