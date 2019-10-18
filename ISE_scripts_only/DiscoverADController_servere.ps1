#*********************************************************************************************************************************************
#Discover Domain Controllers
#*********************************************************************************************************************************************
Import-Module -Name ActiveDirectory

Get-ADForest -Identity ssi.ad | ft GlobalCatalogs

Get-ADForest -Identity dksund.dk | ft GlobalCatalogs

Get-ADForest -Identity sst.dk | ft GlobalCatalogs
