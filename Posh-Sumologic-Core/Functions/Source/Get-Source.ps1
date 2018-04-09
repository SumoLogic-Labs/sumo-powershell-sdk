<#
.SYNOPSIS
    Source
.DESCRIPTION
    Get sources.
.EXAMPLE
    Get-Source
#>

function Get-Source {
    [CmdletBinding(DefaultParameterSetName = "ById")]
    param(
    $Session = $Script:sumoSession,
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [alias('id')]
    [long]$CollectorId,
    [parameter(ParameterSetName = "ById", Position = 0)]
    [long]$SourceId,
    [parameter(ParameterSetName = "ByName")]
    [string]$NamePattern,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Offset,
    [parameter(ParameterSetName = "ByPage", Mandatory = $true)]
    [int]$Limit
    )
    process {
        foreach ($cid in $CollectorId) {
            switch ($PSCmdlet.ParameterSetName) {
                "ById" {
                   if (-not ($SourceId)) {
                        $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources").sources
                    } else {
                        $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources/$SourceId").source
                    }
                }
                "ByName" {
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources").sources | Where-Object { $_.name -match [regex]$NamePattern }
                }
                "ByPage" {
                    $body = @{
                        'offset' = $Offset
                        'limit' = $Limit
                    }
                    $ret = (invokeSumoRestMethod -session $Session -method Get -function "collectors/$cid/sources" -content $body).sources
                }

            }
            if ($ret) {
                $ret | ForEach-Object {
                    Add-Member -InputObject $_ -MemberType NoteProperty -Name collectorId -Value $cid
                }
            }
            $ret
        }
    }
}
