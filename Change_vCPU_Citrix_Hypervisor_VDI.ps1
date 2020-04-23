##########################################
# Connect to your Citrix Hypervisor Host #
##########################################
# Modify your User and PW here           #

$Xenhost = "yourhost" 
$Username = "root"
$Password = "Servus"

  Try {
        $Session = Connect-XenServer -Url https://$Xenhost -UserName $username -Password $password -NoWarnCertificates -SetDefaultSession
    } Catch [XenAPI.Failure] {
        [string]$PoolMaster = $_.Exception.ErrorDescription[1]  
        Write-Host -ForegroundColor Red "$($Pools.$Pool) is slave, Master was identified as $PoolMaster, trying to connect"
        $Pools.Pool = $PoolMaster
        $Session = Connect-XenServer -url "http://$PoolMaster" -UserName $username -Password $password -NoWarnCertificates -SetDefaultSession
    }

########################################################################################################
# Make the changes to the vCPU Settings on every VDI with State:Halted (PowerOff) in Citrix Hypervisor #
# only powered off VDIs can be modified                                                                #
########################################################################################################

$ListOfVM = @()
$ListOfVM = Get-XenVM | ? {$_.is_a_snapshot -eq $false -and $_.is_a_template -eq $false -and $_.is_control_domain -eq $false -and $_.power_state -eq "Halted" } | % {$_.name_label}

  ForEach ($VM in $ListOfVM)
       {
           Set-XenVM -Name $VM -NameDescription "VDI Business SG"
        Set-XenVM -Name $VM -VCPUsAtStartup 2
        Set-XenVM -Name $VM -VCPUsMax 2
        Set-XenVM -Name $VM -Platform @{ "cores-per-socket" = "2"; hpet = "true"; pae = "true"; vga = "std"; nx = "true"; viridian_time_ref_count = "true"; apic = "true"; viridian_reference_tsc = "true"; viridian = "true"; acpi = "1" }
        Write-Host -ForegroundColor Green "$VM" was updated with new vCPU Settings
       }
