# ignoring specific accounts, adapt on your needs or comment out

$ignoredUsers = @(
    'accountId1',
    'accountId2'
)

if ($env:username -in $ignoredUsers){ exit }

try
{
    $ZscalerApp = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq "Zscaler" }
}
catch
{
    $body = @{
        "hostname" = $env:computername;
        "username" = $env:username;
        "version" = "NA";
        "Zscaler_status" = "error getting Zscaler info";
    }
}

if($null -ne $ZscalerApp)
{
    $ZscalerAppVersion = $ZscalerApp.DisplayVersion

    # starting a Sleep to try to prevent script triggering before Zscaler is loaded and report false positives
    Start-Sleep -Seconds 180

    try
    {
        $ZscalerAppTunnelStatus = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Zscaler\App" -Name "ZWS_State" -ErrorAction Stop).ZWS_State

        $body = @{
            "hostname" = $env:computername;
            "username" = $env:username;
            "version" = [string]$ZscalerAppVersion;
            "Zscaler_status" = $ZscalerAppTunnelStatus;
        }
    }
    catch
    {
        $body = @{
            "hostname" = $env:computername;
            "username" = $env:username;
            "version" = [string]$ZscalerAppVersion;
            "Zscaler_status" = "error getting tunnel status";
        }
    }
    
}
else
{
    $body = @{
        "hostname" = $env:computername;
        "username" = $env:username;
        "version" = "NA";
        "Zscaler_status" = "Zscaler not installed or old version";
    }
}

Invoke-RestMethod -Method 'Post' -Uri 'URL generated from Power Automate Flow' -Body ($body|ConvertTo-Json) -ContentType "application/json"