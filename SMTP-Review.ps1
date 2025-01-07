<#
    .SYNOPSIS
    SMTP-Review.ps1

    .DESCRIPTION
    Script is intended to help determine servers that are using an Exchange server to connect and send email.
    This is especially pertinent in a decommission scenario, where the logs are to be checked to ensure that
    all SMTP traffic has been moved to the correct endpoint.

    .NOTES
    updated by: Simbu
    .CHANGELOG
    V1.00, 04/05/2021 - Initial version
    V2.00, 03/28/2023 - Rewrite script to retrieve results faster
#>

# Clears the host console to make it easier to read output
Clear-Host

# Sets the path to the directory containing the log files to be processed
$logFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\SmtpReceive\*.log"

# Sets the path to the output file that will contain the unique IP addresses
$Output = "C:\temp\IPAddresses.txt"

# Gets a list of the log files in the specified directory
$logFiles = Get-ChildItem $logFilePath

# Gets the number of log files to be processed
$count = $logFiles.Count

# Initializes an array to store the unique IP addresses
$ips = foreach ($log in $logFiles) {

    # Displays progress information
    $percentComplete = [int](($logFiles.IndexOf($log) + 1) / $count * 100)
    $status = "Processing $($log.FullName) - $percentComplete% complete ($($logFiles.IndexOf($log)+1) of $count)"
    Write-Progress -Activity "Collecting Log details" -Status $status -PercentComplete $percentComplete

    # Displays the name of the log file being processed
    Write-Host "Processing Log File $($log.FullName)" -ForegroundColor Magenta

    # Reads the content of the log file, skipping the first five lines
    $fileContent = Get-Content $log | Select-Object -Skip 5

    # Loops through each line in the log file
    foreach ($line in $fileContent) {

        # Extracts the IP address from the socket information in the log line
        $socket = $line.Split(',')[5]
        $ip = $socket.Split(':')[0]

        # Adds the IP address to the $ips array
        $ip
    }
}

# Displays progress information
Write-Progress -Activity "Processing IP Addresses" -Status "This can take time"

# Removes duplicate IP addresses from the $ips array and sorts them alphabetically
$uniqueIps = $ips | Select-Object -Unique | Sort-Object

# Displays the list of unique IP addresses on the console
Write-Host "List of IP addresses:" -ForegroundColor Cyan
$uniqueIps

# Writes the list of unique IP addresses to the output file
$uniqueIps | Out-File $Output