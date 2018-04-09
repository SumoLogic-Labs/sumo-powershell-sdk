<#
.SYNOPSIS
    Collector
.DESCRIPTION
    Get collector/s details.
.EXAMPLE
    Get-Collector
#>

function Get-Collector {
    [CmdletBinding(DefaultParameterSetName = "ById")]
    param(
    $Session = $Script:sumoSession,
    [parameter(ParameterSetName = "ById", Position = 0)]
    [long]$Id,
    [parameter(ParameterSetName = "ByName")]
    [string]$NamePattern,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Offset,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Limit
    )
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "ById" {
                if (-not ($Id)) {
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors").collectors
                } else {
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$Id").collector
                }
            }
            "ByName" {
                $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors").collectors | Where-Object { $_.name -match [regex]$NamePattern }
            }
            "ByPage" {
                $body = @{
                    'offset' = $Offset
                    'limit' = $Limit
                }
                $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors" -content $body).collectors
            }
        }
        $ret
    }
}
