<#
.SYNOPSIS
    Search
.DESCRIPTION
    Start a search job.
.EXAMPLE
    Start-SearchJob
#>

function Start-SearchJob {
    [CmdletBinding(DefaultParameterSetName="ByLast",SupportsShouldProcess=$true,ConfirmImpact="High")]
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
    [string]$TimeZone = "UTC"
    )
  process{
    if  ("ByLast" -eq $PSCmdlet.ParameterSetName) {
      $utcNow = [DateTime]::NoW.ToUniversalTime()
      $From = $utcNow - $Last
      $To = $utcNow
      $TimeZone = "UTC"
    }
    if ($To -le $From) {
      throw "Time range [$From to $To] is illegal"
    }
    if($pscmdlet.ShouldProcess($session)){
      $job = startSearchJob -Session $Session -Query $Query -From $From -To $To -TimeZone $TimeZone
    }
    if (!$job) {
      throw "Job creation fail"
    }
    $totalMs = ($To - $From).TotalMilliseconds
    $title = “Query [{0}], Gathering Result” -f $Query
    $On = $To
    while ((!$status) -or $status.state -ne "DONE GATHERING RESULTS") {
      $status = invokeSumoRestMethod -session $Session -method Get -function ("search/jobs/" + $job.id)
      if ((!$status) -or $status.state -eq "CANCELLED") {
        throw "Job was cancelled"
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
