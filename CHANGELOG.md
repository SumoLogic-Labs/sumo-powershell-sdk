## 0.9.0
 - Initial public release

## 1.0.0
 - Refactory for releasing on PowerShell Gallery (move all source code into `src`)
 - Add cmdlets for collector upgrade
 - Reorganization: every exported cmdlets in a file with help doc annotation
 - Add unit tests in Pester
 - Remove `-Deployment` parameter from `New-SumoSession` cmdlet. It will automatically redirect to correct deployment based on the access id/key
