<#
.SYNOPSIS
Start a search job

.DESCRIPTION
Start a search job and waiting for the result fetched

.PARAMETER Session
An instance of SumoAPISession which contains API endpoint and credential

.PARAMETER Query
The query used for the search in string

.PARAMETER Last
A time span for query recent results

.PARAMETER From
Query with a time range start from

.PARAMETER To
Query with a time range end to

.PARAMETER TimeZone
Time zone used for time range query

.PARAMETER Force
Do not confirm before running

.EXAMPLE
Start-SearchJob -Query "_sourceCategory=service ERROR" -Last "00:30:00"
Search all results in last 30 minutes with "ERROR" in "service" category

.INPUTS
Not accepted

.OUTPUTS
PSObject to present search job

.NOTES
You can pre-load the API credential with New-SumoSession cmdlet in script or passing in with Session parameter
This call will wait until done gathering results or hit a failure. See link page for details

.LINK
https://github.com/SumoLogic/sumo-powershell-sdk/blob/ps_gallery/docs/Start-SearchJob.md

.LINK
https://help.sumologic.com/APIs/Search-Job-API/About-the-Search-Job-API
#>

function Start-SearchJob {
  [CmdletBinding(DefaultParameterSetName = "ByLast", SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
  param(
    $Session = $Script:sumoSession,
    [parameter(Position = 0)]
    [string]$Query,
    [parameter(ParameterSetName = "ByLast")]
    [TimeSpan]$Last = [TimeSpan]::FromMinutes(15),
    [parameter(ParameterSetName = "ByTimeRange", Mandatory = $true)]
    [DateTime]$From,
    [parameter(ParameterSetName = "ByTimeRange", Mandatory = $true)]
    [DateTime]$To,
    [parameter(ParameterSetName = "ByTimeRange")]
    [string]$TimeZone = "UTC",
    [switch]$Force
  )
  process {
    if ("ByLast" -eq $PSCmdlet.ParameterSetName) {
      $utcNow = [DateTime]::NoW.ToUniversalTime()
      $From = $utcNow - $Last
      $To = $utcNow
      $TimeZone = "UTC"
    }
    if ($To -le $From) {
      throw "Time range [$From to $To] is illegal"
    }
    if ($Force -or $pscmdlet.ShouldProcess($session)) {
      $job = startSearchJob -Session $Session -Query $Query -From $From -To $To -TimeZone $TimeZone
      if (!$job) {
        throw "Job creation fail"
      }
      $totalMs = ($To - $From).TotalMilliseconds
      $title = "Query [{0}], Gathering Result" -f $Query
      $On = $To
      while ((!$status) -or $status.state -ne "DONE GATHERING RESULTS") {
        $status = invokeSumoRestMethod -session $Session -method Get -function ("search/jobs/" + $job.id)
        if (!$status) {
          throw "Cannot get search job status"
        }
        if ($status.state -eq "FORCE PAUSED") {
          throw "Query is paused by the system"
        }
        if ($status.state -eq "CANCELED") {
          throw "The search job has been canceled"
        }
        if ($status.histogramBuckets) {
          $On = getDotNetDateTime ($status.histogramBuckets[$status.histogramBuckets.Count - 1].startTimestamp)
        }
        $processedMs = ($To - $On).TotalMilliseconds
        $text = "Processed records for last {0} of {1} minutes. Found {2} messages, {3} records" -f [long]($To - $On).TotalMinutes, [long]($To - $From).TotalMinutes, $status.messageCount, $status.recordCount
        Write-Progress -Activity $title -Status $text -PercentComplete ($processedMs / $totalMs * 100)
        Start-Sleep 1
      }
      $job
    }
  }
}
