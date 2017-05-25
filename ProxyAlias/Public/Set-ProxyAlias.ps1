function Set-ProxyAlias {
    [CmdletBinding(DefaultParameterSetName='HashTableByName')]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='ByCommand',ValueFromPipeline=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.CommandInfo]
        $Command,

        [Parameter(Mandatory=$true,ParameterSetName='ByName',Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory=$true,Position=1)]
        [Alias('Alias')]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewName,

        [Parameter()]
        [System.Collections.IDictionary]
        $Property = @{},

        [Parameter(Position=2)]
        [string]
        $PropertyName,

        [Parameter(Position=3)]
        [Alias('Value')]
        [psobject]
        $PropertyValue
    )

    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $Command = Get-Command $Name
    }

    if($PSBoundParameters.ContainsKey('PropertyName')){
        if(-not $PSBoundParameters.ContainsKey('PropertyValue'))
        {
            $PropertyValue = $true
        }
        $Property[$PropertyName] = $PropertyValue
    }

    try {
        $Metadata = [System.Management.Automation.CommandMetadata]::new($Command)
        $ProxyCommand = [System.Management.Automation.ProxyCommand]::Create($Metadata)
        Set-Item -Path "function:global:$NewName" -Value $ProxyCommand -Force
    }
    catch {
        throw $_
    }

    $DefaultValues = $PSCmdlet.SessionState.PSVariable.Get('PSDefaultParameterValues').Value
    foreach($ValuePair in $DefaultValues.Keys |Where-Object {$_ -like "$NewName`:*"}){
        $DefaultValues.Remove($ValuePair)
    }

    foreach($PropertyKey in $Property.Keys){
        $DefaultValues["$NewName`:$PropertyKey"] = $Property[$PropertyKey]
    }
    $PSCmdlet.SessionState.PSVariable.Set('PSDefaultParameterValues',$DefaultValues)
}
