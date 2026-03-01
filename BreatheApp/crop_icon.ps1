Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile("d:\Flutter-AntiGravity\BreatheApp\assets\icons\app_icon.jpg")
$bmp = New-Object System.Drawing.Bitmap 896, 896
$g = [System.Drawing.Graphics]::FromImage($bmp)
$rectSource = New-Object System.Drawing.Rectangle 352, 0, 896, 896
$rectDest = New-Object System.Drawing.Rectangle 0, 0, 896, 896
$g.DrawImage($img, $rectDest, $rectSource, [System.Drawing.GraphicsUnit]::Pixel)
$bmp.Save("d:\Flutter-AntiGravity\BreatheApp\assets\icons\app_icon_square.jpg", [System.Drawing.Imaging.ImageFormat]::Jpeg)
$g.Dispose()
$bmp.Dispose()
$img.Dispose()
Write-Host "Success!"
