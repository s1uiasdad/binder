function Get-CommandPath {
    if ($MyInvocation.MyCommand.Path) {
        # Nếu $MyInvocation.MyCommand.Path có giá trị, trả về giá trị của nó
        return $MyInvocation.MyCommand.Path
    } else {
        # Nếu $MyInvocation.MyCommand.Path không có giá trị, lấy đường dẫn của tiến trình hiện tại
        $path = (Get-Process -Id $PID).Path
        return $path
    }
}

# Gọi hàm và lưu kết quả vào biến
$path = Get-CommandPath

# In giá trị của biến $path
Write-Output $path
