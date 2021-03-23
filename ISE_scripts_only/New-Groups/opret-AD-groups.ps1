Import-Module -Name ActiveDirectory 
$System = "dks_Concierge"
$Servicedesknr="N/A"						
$RessNavn="server_klienter_admin"
#$EgoServer="s-mivetest01-t"
#$EgoServer = $env:computername
$EgoDomain=$env:userdnsdomain
$EgoUser=$env:username
$EgoDato=Get-Date -format yyyyMMdd
$gg="$System"+"_g_"+"$RessNavn"+"_u"
$gl=$gg -replace("_g_","_l_")
$gp="OU=T2Groups,OU=Tier2,DC=dksund,DC=dk"
$ggd="Servicekonti og brugere med behov for administration privilegier til $System i $EgoDomain"
$gld="Ressourcegruppe administrator privilegier til $System privilegier i $EgoDomain"
$Ressourceansvarlig = "vara"
$coman="vara,miha"


$gdu=$EgoDato+" "+$EgoUser
$gsd=$Servicedesknr
If ($Ressourceansvarlig.length -gt 0){
	if (@(Get-ADUser -Filter { SamAccountName -eq $Ressourceansvarlig }).Count -gt 0) {
		$a=get-aduser "$Ressourceansvarlig"
		$glm=$a.DistinguishedName
	}else{
		Write-Host "Opret sag til servicedesk at bruger: $Ressourceansvarlig skal oprettes som disablet bruger i domænet: $domUser"
	}
}

NEW-ADGroup –name $gl -samaccountname $gl –groupscope 0 –path "$gp" -Description "$gld"  -ManagedBy "$glm" -GroupCategory 1 -OtherAttributes @{info="$gdu : SD $gsd $gld Meld_IKKE_brugere_ind_i_lokal_gruppen_BRUG_Global_gruppen!"}
NEW-ADGroup –name $gg -samaccountname $gg –groupscope 1 –path "$gp" -Description "$ggd"  -ManagedBy "$glm" -GroupCategory 1 -OtherAttributes @{info="$gdu : SD $gsd Privilegie gruppe for $ggd [co-managers: $coman]"}
Add-ADGroupMember -identity $gl -members $gg 