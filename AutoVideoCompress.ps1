#$Script:showWindowAsync = Add-Type -MemberDefinition @"
#[DllImport("user32.dll")]
#public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
#"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
#Function Show-Powershell()
#{
#$null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
#}
#Function Hide-Powershell()
#{
#$null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
#}
#
#Hide-Powershell


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


############################### set env variable for ffmpeg ###################################

$env:Path += ";C:\Program Files\ffmpeg\bin"

############################### Video Path Dialog ###################################

$InputFile = New-Object -TypeName System.Windows.Forms.OpenFileDialog
$InputFile.ShowDialog()

############################### Video Size Dialog ###################################

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Desired Video Size'
$form.Size = New-Object System.Drawing.Size(430,200)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(100,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(400,20)
$label.Text = 'Please enter the maximum size you wish your video to be (in KiloBytes):'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(400,30)
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $DesiredSize = [convert]::ToDecimal($textBox.Text)
}

############################### Video Bitrate Calculation ###################################

$VideoSize = ffprobe -v error -select_streams v:0 -show_entries format=size -of default=noprint_wrappers=1:nokey=1 $InputFile.FileName
$VideoSize = [convert]::ToDecimal($VideoSize)
echo "The current size of the video is : $VideoSize"

$CompressionFactor = $DesiredSize / ($VideoSize / 1024)

$AudioBitrate = ffprobe -v error -select_streams a:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 $InputFile.FileName
echo "The audio bitrate is : $AudioBitrate"
$AudioBitrate = [convert]::ToDecimal($AudioBitrate)

$VideoBitrate = ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 $InputFile.FileName
echo "The video bitrate is : $VideoBitrate"
$VideoBitrate = [convert]::ToDecimal($VideoBitrate)

#$DesiredTotalBitrate = ($DesiredSize * 1024 * 8) / $VideoDuration

$NewVideoBitrate = ($VideoBitrate * $CompressionFactor) * 0.9
$NewAudioBitrate = ($AudioBitrate * $CompressionFactor) * 0.9

echo "New video bitrate is : $NewVideoBitrate"
echo "New audio bitrate is : $NewAudioBitrate"

############################### Video Output Name Dialog ###################################

$OutputFile = New-Object -TypeName System.Windows.Forms.SaveFileDialog
$OutputFile.DefaultExt = ".mp4"
$OutputFile.ShowDialog()

############################### FFMPEG Operation ###################################

ffmpeg -i $InputFile.Filename -b:v $NewVideoBitrate -b:a $NewAudioBitrate $OutputFile.FileName -y
