param(
    [string]$accountName,
    [string]$rgName)

dotnet new blazorwasm -o BlazorDemo.Client -f net5.0
dotnet publish BlazorDemo.Client\BlazorDemo.Client.csproj -c Release -o outcli

$end = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
$start = (Get-Date).ToString("yyyy-MM-dd")
$sas = (az storage container generate-sas -n `$web --account-name $accountName --permissions racwl --expiry $end --start $start --https-only | ConvertFrom-Json)
azcopy_v10 sync outcli\wwwroot "https://$accountName.blob.core.windows.net/`$web?$sas" --delete-destination=true
