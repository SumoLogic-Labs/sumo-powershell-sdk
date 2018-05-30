# For manually trigger App Veyor build on specific branch with commit
param(
  $token,
  $branch = "master",
  $commit = $null
)

$headers = @{
  "Authorization" = "Bearer $token"
  "Content-type"  = "application/json"
}

$body = @{
  "accountName" = "bin3377"
  "projectSlug" = "sumo-powershell-sdk"
  "branch"      = $branch
}
if ($commit) {
  $body["commitId"] = $commit
}

Invoke-RestMethod -Uri 'https://ci.appveyor.com/api/builds' -Headers $headers  -Body ($body | ConvertTo-Json) -Method POST