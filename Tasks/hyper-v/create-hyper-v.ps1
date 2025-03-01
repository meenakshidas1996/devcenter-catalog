
$blobUrl = "https://linuxinvestigation.blob.core.windows.net/jess-and-meena/image-builder-user.vhdx"

if (-Not (Test-Path "C:\tmp")) {
    mkdir C:\tmp
}
$outputPath = "C:\tmp\linux-image.vhdx"

# To speed up downloading (still takes about ~6 min to download the file)
$ProgressPreference = 'SilentlyContinue'

# Download the file
Invoke-WebRequest -Uri $blobUrl -OutFile $outputPath

Write-Host "File downloaded successfully to $outputPath"

$imagePath = "C:\tmp\linux-image.vhdx"
$vmName = "linux-devbox"                         
$memoryStartupBytes = 4096MB                    
$switchName = "Default Switch"                

# Verify the image file exists
if (!(Test-Path -Path $imagePath)) {
    Write-Error "Image file not found at $imagePath. Please check the path."
    exit
}

# Create the VM. For a VHDX file intended for UEFI boot, a Generation 2 VM is used.
New-VM -Name $vmName -MemoryStartupBytes $memoryStartupBytes -Generation 2 -SwitchName $switchName

# Attach the downloaded VHD/VHDX file to the VM's SCSI Controller
Add-VMHardDiskDrive -VMName $vmName -Path $imagePath

# Optionally, set the attached VHD as the first boot device
Set-VMFirmware -VMName $vmName -FirstBootDevice (Get-VMHardDiskDrive -VMName $vmName)

# Disabling Secure boot
Set-VMFirmware -VMName $VmName -EnableSecureBoot Off

# Start the VM
Start-VM -Name $vmName

Write-Host "Hyper-V VM '$vmName' has been created and started successfully."