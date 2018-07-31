# Change Log

## 1.1.2 - 7/31/2018

- Fix #18 - Start-SearchJob

## 1.1.1 - 6/7/2018

- Using environment variable `SUMOLOGIC_API_ENDPOINT` to override endpoint URL
- Document and unit test update

## 1.1.0 - 5/30/2018

- Document update
- Integration deployment to PowerShell Gallery

## 1.0.3 - 5/10/2018

- Support over 1000 collectors in Get-Collector
- Integrate to App Veyor

## 1.0.2 - 4/25/2018

- Generate online help documents

## 1.0.1 - 4/25/2018

- Documents update for Inputs/Outputs annotation

## 1.0.0 - 4/23/2018

- Refactory for releasing on PowerShell Gallery (with PowerShell Core 6.0+)
- Add cmdlets for collector upgrade management
- Reorganization - every exported cmdlets in a single file with help doc annotation
- Add unit tests in Pester (run with `Invoke-Pester src/test`)
- Remove `-Deployment` parameter from `New-SumoSession` cmdlet. It will automatically redirect to correct deployment based on the access id/key
- Change `-AccessKey` parameter in `New-SumoSession` to `-AccessKeyAsSecureString` for passing PowerShell Gallery check