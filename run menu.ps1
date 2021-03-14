Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, WindowsFormsIntegration

[xml]$XAML_ConnectDialog = Get-Content 'C:\RUFR_PowerShell\UserMenu.xaml' -Encoding UTF8
$XML_Node_Reader_ConnectDialog = (New-Object System.Xml.XmlNodeReader $XAML_ConnectDialog)
$ConnectDialog = [Windows.Markup.XamlReader]::Load($XML_Node_Reader_ConnectDialog)

$Btn_ConnectDialog_Close_Form = $ConnectDialog.FindName('Btn_ConnectDialog_Close_Form')
$Btn_ConnectDialog_Close_Form.Add_Click( {
    $ConnectDialog.Close()
})

$ConnectDialog.Add_Closing( { [System.Windows.Forms.Application]::Exit() }) # {$form.Close()}

# add keyboard indput
[System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($ConnectDialog)

# Running this without $appContext and ::Run would actually cause a really poor response.
$ConnectDialog.Show()

# This makes it pop up
$ConnectDialog.Activate() | Out-Null
#run the form ConnectDialog
$appContext = New-Object System.Windows.Forms.ApplicationContext
[System.Windows.Forms.Application]::Run($appContext)