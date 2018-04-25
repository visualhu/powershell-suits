Add-Type -AssemblyName System.IO.Compression.FileSystem
Import-Module WebAdministration
$WebPath=[environment]::CurrentDirectory + "\demo";
Write-Host "demo will install to $WebPath"
Write-Host "After installation, you can visit the site with http://localhost:8080"
Write-Host "Installation started. Press Ctrl+C to stop."
 
Write-Host "Checking IIS status..."
$iis = Get-Service W3SVC -ErrorAction Ignore
if($iis){
    if($iis.Status -eq "Running") {
        Write-Host "IIS Service is running"
    }
    else {
        Write-Host "IIS Service is not running"
    }
}
else {
    Write-Host "Checking IIS failed, please make sure IIS is ready."   
}
$aspNetCoreModule = Get-WebGlobalModule -Name AspNetCoreModule -ErrorAction Ignore
if($aspNetCoreModule)
{
    Write-Host "IIS ASPNetCoreModule is ready:"
    Write-Host $aspNetCoreModule.Name $aspNetCoreModule.Image
}
else
{
    Write-Host "Downloading DotNetCore.WindowsHosting."
    if(Test-Path -Path "DotNetCore.WindowsHosting.exe")
    {
        Remove-Item -Path "DotNetCore.WindowsHosting.exe" -Force
    }
    Invoke-WebRequest -Uri "https://aka.ms/dotnetcore.2.0.0-windowshosting" -OutFile "DotNetCore.WindowsHosting.exe"
     
    Write-Host "Installing DotNetCore.WindowsHosting."
    Start-Process "DotNetCore.WindowsHosting.exe" -Wait
    if(Test-Path -Path "DotNetCore.WindowsHosting.exe")
    {
        Remove-Item -Path "DotNetCore.WindowsHosting.exe" -Force
    }
}
 
Write-Host "Downloading demo application package."
if(Test-Path -Path "demo.zip")
{
    Remove-Item -Path "demo.zip" -Force
}
Invoke-WebRequest -Uri "./src.zip" -OutFile "demo.zip"
 
Write-Host "Unzip demo application package."
if(Test-Path "demo")
{
    Remove-Item -Path "demo" -Force -Recurse
}
[System.IO.Compression.ZipFile]::ExtractToDirectory("demo.zip" ,"demo")
 
Write-Host "Setting up IIS."
if(!(Test-Path IIS:\AppPools\demo))
{
    New-Item -path IIS:\AppPools\demo
}
Set-ItemProperty -Path IIS:\AppPools\demo -Name managedRuntimeVersion -Value ''
if(Test-Path IIS:\Sites\demo)
{
    Remove-Website demo
}
New-Website -name demo -PhysicalPath $WebPath -ApplicationPool demo -Port 8080
Invoke-Expression "net stop was /y"
Invoke-Expression "net start w3svc"
Invoke-Expression "cmd.exe /C start http://localhost:8080"
if(Test-Path -Path "demo.zip")
{
    Remove-Item -Path "demo.zip" -Force
}
Write-Host "demo installed successfully."