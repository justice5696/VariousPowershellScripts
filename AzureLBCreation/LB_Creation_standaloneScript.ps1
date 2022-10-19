#usage <scriptName>.ps1 -inifile <pathtoini>

param([string]$iniFile = "uag.ini")


######################################################################################################################
#############################################  Functions  ############################################################

#funtion to import an Ini file. 
function ImportIni {
    param ($file)

    $ini = @{}
    switch -regex -file $file
    {
            "^\s*#" {
                continue
            }
            "^\[(.+)\]$" {
                $section = $matches[1]
                $ini[$section] = @{}
            }
            "([A-Za-z0-9#_]+)=(.+)" {
                $name,$value = $matches[1..2]
                $ini[$section][$name] = $value.Trim()
            }
    }
    return $ini
}


# Function to write an error message in red with black background
function WriteErrorString {
    param ($string)
    write-host $string -foregroundcolor red -backgroundcolor black
}
   
function LoginToSubscription
{
    param ($sub)
    # log into the subscription given in the ini file
    Connect-AzureRmAccount -Subscription $sub
}
function CreateLB
{
    # Source https://docs.microsoft.com/en-us/powershell/module/azurerm.network/new-azurermloadbalancer?view=azurermps-6.13.0
    Param ($settings)

    #must first create a new Public IP for the Load Balancer
    $publicIpName = $settings.General.name + '-LB-PIP'
    $publicip = New-AzureRmPublicIpAddress -ResourceGroupName $settings.Azure.LBPublicIPresourceGroup -Name $publicIpName -Location $settings.Azure.location -AllocationMethod "Static"

    #must create the load balancer front end configuration
    $frontendname = $settings.General.name + '-LB-FE'
    $frontend = New-AzureRmLoadBalancerFrontendIpConfig -Name $frontendname -PublicIpAddress $publicip

    #must create the load balancer backend config
    $backendname = $settings.General.name + '-LB-BE-Pool'
    $backendAddressPool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backendname
    #NEED TO ADD THE UAG ETH 0 TO THE BACKEND POOL

    #the different health probes that will be built for this LB: there is an additional option: "-ProbeCount 2" not sure if we need or what it shold be
    $probe_favicon = New-AzureRmLoadBalancerProbeConfig -Name "HealthProbe_Favicon" -Protocol "HTTPS" -Port 443 -IntervalInSeconds 31 -RequestPath "/favicon.ico" -ProbeCount 2
    $probe_TCP8443 = New-AzureRmLoadBalancerProbeConfig -Name "HealthProbe_TCP8443" -Protocol "TCP" -Port 8443 -IntervalInSeconds 31 -ProbeCount 2
    
 
    #Must build out the different LB rules
    $lbrule_TCP443_name =  $settings.General.name + '-TCP443-Rule'
    $lbrule_UDP443_name = $settings.General.name + '-UDP443-Rule'
    $lbrule_TCP8443_name = $settings.General.name + '-TCP8443-Rule'
    $lbrule_UDP8443_name = $settings.General.name + '-UDP8443-Rule'
    

    #######################################################################
    

    #build the actual LB object
    $lb_name = 'aa-ets-' + $settings.General.name + '-vdi-lb'
    $lb = New-AzureRmLoadBalancer -Name $lb_name -ResourceGroupName $settings.Azure.LoadBalancerResourceGroup -Location $settings.Azure.location -FrontendIpConfiguration $frontend -BackendAddressPool $backendAddressPool 
    Write-Host "Lb is $($lb)"
    
    #add the load balancer probes to the existing LB
    $addprobe = Add-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name "HealthProbe_Favicon" -Protocol "HTTPS" -Port 443 -IntervalInSeconds 31 -RequestPath "/favicon.ico" -ProbeCount 2
    Write-Host "Probe1 is $($addprobe)"
    $addprobe = Add-AzureRmLoadBalancerProbeConfig -LoadBalancer $lb -Name "HealthProbe_TCP8443" -Protocol "TCP" -Port 8443 -IntervalInSeconds 31 -ProbeCount 2
    Write-Host "Probe2 is $($addprobe)"
    
    #add the load balancer rules to the existing LB
    $addrule = Add-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb -Name $lbrule_TCP443_name -FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe_favicon -Protocol "Tcp" -FrontendPort 443 -BackendPort 443 -IdleTimeoutInMinutes 10 -LoadDistribution SourceIP
    Write-Host "Rule1 is $($addrule)"
    $addrule = Add-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb -Name $lbrule_UDP443_name -FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe_favicon -Protocol "UDP" -FrontendPort 443 -BackendPort 443 -LoadDistribution SourceIP
    Write-Host "Rule2 is $($addrule)"
    $addrule = Add-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb -Name $lbrule_TCP8443_name -FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe_favicon -Protocol "Tcp" -FrontendPort 8443 -BackendPort 8443 -IdleTimeoutInMinutes 5 -LoadDistribution SourceIP
    Write-Host "Rule3 is $($addrule)"
    $addrule = Add-AzureRmLoadBalancerRuleConfig -LoadBalancer $lb -Name $lbrule_UDP8443_name -FrontendIPConfiguration $frontend -BackendAddressPool $backendAddressPool -Probe $probe_favicon -Protocol "UDP" -FrontendPort 8443 -BackendPort 8443 -LoadDistribution SourceIP
    Write-Host "Rule4 is $($addrule)"

    Get-AzureRmLoadBalancer -Name $lb_name -ResourceGroupName $settings.Azure.LoadBalancerResourceGroup
    Write-Host "Lb is $(Get-AzureRmLoadBalancer -Name $lb_name -ResourceGroupName $settings.Azure.LoadBalancerResourceGroup)"
}

function AddVMsToLB
{

}

######################################################################################################################
#############################################  Script ################################################################

#Not currently needed
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir  = Split-Path -Parent $ScriptPath


# Disables the warnings about using Azure RM even though it will be deprecated.
Set-Item -Path Env:\SuppressAzureRmModulesRetiringWarning -Value $true


# Check that the required Azure PowerShell modules are installed
if (-not (Get-Module -ListAvailable -Name "AzureRM.Compute")) {
    WriteErrorString "Error: Powershell module AzureRM.Compute not found. Run the command 'Install-Module -Name AzureRM -Force' and retry"
    Exit
}

if (-not (Get-Module -ListAvailable -Name "AzureRM.Storage")) {
    WriteErrorString "Error: Powershell module AzureRM.Storage not found. Run the command 'Install-Module -Name AzureRM -Force' and retry"
    Exit
}

if (-not (Get-Module -ListAvailable -Name "AzureRM.Profile")) {
    WriteErrorString "Error: Powershell module AzureRM.Profile not found. Run the command 'Install-Module -Name AzureRM -Force' and retry"
    Exit
}

Write-host "Unified Access Gateway (UAG) virtual appliance Microsoft Azure deployment script"

if (!(Test-path $iniFile)) {
    WriteErrorString "Error: Configuration file ($iniFile) not found."
    WriteErrorString "Usage: <scriptName>.ps1 -inifile <pathtoini>"
    Exit
}

#create a settings dictionary containing all values from the INI
$settings = ImportIni $iniFile

LoginToSubscription $settings.Azure.subscriptionID

$Lb = CreateLB $settings
Write-Host "Made it past the CreateLB Function "
if(!$Lb)
{
    Write-Host "LB Creation Failed. Ending Script."
    Exit
}