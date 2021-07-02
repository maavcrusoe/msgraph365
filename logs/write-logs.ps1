#function to create a log folder
function CreateLogFolder {
    $path = "C:\Log\"
    If(!(test-path $path))
    {
        New-Item -ItemType Directory -Force -Path $path
    }
}

#execute this function and create folder
CreateLogFolder

#Set log file
$LogFile = "C:\Log\logginName.txt"

#Function that logs a message to a text file
function LogMessage {
    param([string]$Message) 
    ((Get-Date).ToString() + " - " + $Message) >> $LogFile;
}

#if you want to see logs like tail -f in PowerShell
Get-Content -Path "C:\Log\Contactos.txt" -Wait
