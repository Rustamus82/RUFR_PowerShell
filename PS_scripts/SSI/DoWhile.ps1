do
{
      Show-Menu
      $input = Read-Host "Vælg en af muligheder, (husk at logge på først)"
      #$WorkingDir = Convert-Path . replacing with: $PSScriptRoot
      switch ($input)
      {
            
            'bae' {
                 cls
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_BAE.ps1"
		  }
            'jomh' {
                 cls
	         & "$PSScriptRoot\Logins\Login_SSI_SST_exch2010_DKSUND_Exchange365_JOMH.ps1"
		  }

	      'q' {
                 return
            }
      }
      pause
 }
 until ($input -eq 'q')