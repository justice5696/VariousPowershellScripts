# Powershell Form Creation: https://docs.microsoft.com/en-us/powershell/scripting/samples/selecting-items-from-a-list-box?view=powershell-7.1
# Blog on configuring multi-languages: https://veucaddict.com/blog/changing-the-windows-display-language-with-vmware-dem-a-user-friendly-way/#comments
# Link to the Powershell Command used for a particular language: https://veucaddict.com/wp-content/uploads/2020/01/set-win-language-in-sv_SE.txt
# Microsoft Region Codes: https://docs.microsoft.com/nl-nl/windows/win32/intl/table-of-geographical-locations?redirectedfrom=MSDN
# Adding Display and Keyboard Languages: https://www.maketecheasier.com/add-remove-language-packs-windows10/
# Microsoft Language Codes: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/available-language-packs-for-windows?view=windows-11

#------------[Initialisations]------------
# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$GuiWidth = 400
$GuiHeight = 250
$MarginOffset = 20
$ButtonWidth = ($GuiWidth/6)
$ButtonHeight = ($ButtonWidth/3)

#---------------[Form]-------------------

#form object
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Keyboard Language Selector'
$form.Name = 'Keyboard Language Selector'
$form.Size = New-Object System.Drawing.Size($GuiWidth,$GuiHeight)
$form.ClientSize = $form.Size
$form.StartPosition = 'CenterScreen'

#create icon for the form
$iconBase64 = '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'
$iconBytes = [Convert]::FromBase64String($iconBase64)
# initialize a Memory stream holding the bytes
$stream = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
$form.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))

#Prevent a horizontal scrollbar from showing up on form
$form.HorizontalScroll.Maximum = 0
$form.AutoScroll = $true
$form.VerticalScroll.Visible = $false
$form.AutoScroll = $true



# title object of form
$title = New-Object System.Windows.Forms.Label
$title.Location = New-Object System.Drawing.Point($MarginOffset,$MarginOffset)
$title.Size = New-Object System.Drawing.Size(($GuiWidth-$MarginOffset),40)
$title.AutoSize = $false
$title.Text = "Please select an input language for your keyboard. Current language is:"
$title.Font = 'Microsoft Sans Serif,12'
$form.Controls.Add($title)

$CurrentLanguage = (Get-WinUserLanguageList)[0].LocalizedName
$CurrentLangLabel = New-Object System.Windows.Forms.Label
$CurrentLangLabel.Location = New-Object System.Drawing.Point($MarginOffset,($title.Location.Y + $title.height))
$CurrentLangLabel.Size = New-Object System.Drawing.Size(($GuiWidth-$MarginOffset),40)
$CurrentLangLabel.Text = $CurrentLanguage
$CurrentLangLabel.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($CurrentLangLabel)

#description of form
$Description = New-Object system.Windows.Forms.Label
$Description.text = "The language selected will be used as the input language for your keyboard.  Please click 'OK' after selecting a language."
$Description.AutoSize = $false
$Description.Size = New-Object System.Drawing.Size(($GuiWidth-$MarginOffset),40)
$Description.location = New-Object System.Drawing.Point($MarginOffset,($CurrentLangLabel.Location.Y + $CurrentLangLabel.height))
$Description.Font = 'Microsoft Sans Serif,10'
$form.Controls.Add($Description)

#dropdown box
$Combobox = New-Object system.Windows.Forms.ComboBox
$Combobox.text = ""
$ComboBox.Size = New-Object System.Drawing.Size(($GuiWidth/2),40)
$Combobox.ClientSize = $Combobox.Size
$Combobox.Location = New-Object System.Drawing.Point($MarginOffset,($Description.Location.Y + $Description.height + 10))
# Add the items in the dropdown list
@('Chinese (Simplified)','Chinese (Traditional)','English (US)','Hindi','Japanese','Korean','Spanish (Latin America)') | ForEach-Object {[void] $Combobox.Items.Add($_)}
$Combobox.SelectedIndex = 0
$Combobox.Font = 'Microsoft Sans Serif,12'
$form.Controls.Add($Combobox)



$okButton = New-Object System.Windows.Forms.Button
$okButton.Width = $ButtonWidth
$okButton.Height = $ButtonHeight
$okButton.Location = New-Object System.Drawing.Point((($GuiWidth-(2*$ButtonWidth))-$MarginOffset),(($GuiHeight - $ButtonHeight) - $MarginOffset))
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Width = $ButtonWidth
$CancelButton.Height = $ButtonHeight
$cancelButton.Location = New-Object System.Drawing.Point((($GuiWidth-$ButtonWidth)-($MarginOffset/2)),(($GuiHeight - $ButtonHeight) - $MarginOffset))
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)


$form.Topmost = $true



#------------[Functions]------------

function ChangeToEnglishUS
{

    New-WinUserLanguageList en-US
    Set-WinUserLanguageList en-US -Force
    #Set-WinSystemLocale en-US
    #Set-Culture en-US
    #Set-TimeZone -Id "W. Europe Standard Time"
    #Set-WinHomeLocation -GeoId 0xf4
    write-output 'User pressed English'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    #Add-Type -AssemblyName PresentationFramework
    #$msgBoxInput = [System.Windows.MessageBox]::Show('Do you want to logoff, so the display language change to English (US)?
    #Do not forget to save your work before logoff!','WARNING','YesNo','Warning')
    #switch ($msgBoxInput) 
    #{
	#    'Yes' {Logoff}
	#    'No' {Exit}
    #}

}

function ChangeToChineseSimplified
{

    New-WinUserLanguageList zh-CN
    Set-WinUserLanguageList zh-CN -Force
    #Set-WinSystemLocale zh-CN
    #Set-Culture zh-CN
    #Set-TimeZone -Id "W. Europe Standard Time"
    #Set-WinHomeLocation -GeoId 0x2d
    write-output 'User pressed Simplified Chinese'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    #Add-Type -AssemblyName PresentationFramework
    #$msgBoxInput = [System.Windows.MessageBox]::Show('Do you want to logoff, so the display language change to Simplified Chinese?
    #Do not forget to save your work before logoff!','WARNING','YesNo','Warning')
    #switch ($msgBoxInput) 
    #{
	#    'Yes' {Logoff}
	#    'No' {Exit}
    #}
}

function ChangeToChineseTraditional
{
	# Need fourther clarification on the region settings
	New-WinUserLanguageList zh-TW
    Set-WinUserLanguageList zh-TW -Force
    #Set-WinSystemLocale zh-TW
    #Set-Culture zh-TW
    #Set-TimeZone -Id "W. Europe Standard Time"
    #Set-WinHomeLocation -GeoId 0x2d
    write-output 'User pressed Traditional Chinese'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    #Add-Type -AssemblyName PresentationFramework
    #$msgBoxInput = [System.Windows.MessageBox]::Show('Do you want to logoff, so the display language change to Traditional Chinese?
    #Do not forget to save your work before logoff!','WARNING','YesNo','Warning')
    #switch ($msgBoxInput) 
    #{
	#    'Yes' {Logoff}
	#    'No' {Exit}
    #}
}

function ChangeToKorean
{
    New-WinUserLanguageList ko-KR
    Set-WinUserLanguageList ko-KR -Force
    #Set-WinSystemLocale ko-KR
    #Set-Culture ko-KR
    #Set-TimeZone -Id "W. Europe Standard Time"
    #Set-WinHomeLocation -GeoId 0x86
    write-output 'User pressed Korean'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    #Add-Type -AssemblyName PresentationFramework
    #$msgBoxInput = [System.Windows.MessageBox]::Show('Do you want to logoff, so the display language change to Korean?
    #Do not forget to save your work before logoff!','WARNING','YesNo','Warning')
    #switch ($msgBoxInput) 
    #{
	#    'Yes' {Logoff}
	#    'No' {Exit}
    #}
}

function ChangeToJapanese
{
	New-WinUserLanguageList ja-JP
    Set-WinUserLanguageList ja-JP -Force
    #Set-WinSystemLocale ja-JP
    #Set-Culture ja-JP
    #Set-TimeZone -Id "W. Europe Standard Time"
    #Set-WinHomeLocation -GeoId 0x7a
    write-output 'User pressed Japanese'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    #Add-Type -AssemblyName PresentationFramework
    #$msgBoxInput = [System.Windows.MessageBox]::Show('Do you want to logoff, so the display language change to Japanese?
    #Do not forget to save your work before logoff!','WARNING','YesNo','Warning')
    #switch ($msgBoxInput) 
    #{
	#    'Yes' {Logoff}
	#    'No' {Exit}
    #}
}

function ChangeToSpanishLA
{
	#setting to spanish Mexico
	New-WinUserLanguageList es-LA
    Set-WinUserLanguageList es-LA -Force
    #Set-WinSystemLocale es-MX
    #Set-Culture es-MX
    #Set-TimeZone -Id "W. Europe Standard Time"
    #Set-WinHomeLocation -GeoId 0x9a55d41
    write-output 'User pressed Spanish (Latin America)'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    #Add-Type -AssemblyName PresentationFramework
    #$msgBoxInput = [System.Windows.MessageBox]::Show('Do you want to logoff, so the display language change to Spanish?
    #Do not forget to save your work before logoff!','WARNING','YesNo','Warning')
    #switch ($msgBoxInput) 
    #{
	#    'Yes' {Logoff}
	#    'No' {Exit}
    #}
}

function ChangeToHindi
{
	New-WinUserLanguageList hi-IN
    Set-WinUserLanguageList hi-IN -Force
    #Set-WinSystemLocale hi-IN
    #Set-Culture hi-IN
    #Set-TimeZone -Id "W. Europe Standard Time"
    #Set-WinHomeLocation -GeoId 0x71
    write-output 'User pressed Hindi'

    #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    #Add-Type -AssemblyName PresentationFramework
    #$msgBoxInput = [System.Windows.MessageBox]::Show('Do you want to logoff, so the display language change to Hindi?
    #Do not forget to save your work before logoff!','WARNING','YesNo','Warning')
    #switch ($msgBoxInput) 
    #{
	#    'Yes' {Logoff}
	#    'No' {Exit}
    #}
}





#------------[Show form]------------

#result = Ok or Cancel
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $Combobox.SelectedItem
    Write-Output $x

    Switch($x)
    {
     'English (US)'              {ChangeToEnglishUS}
     'Spanish (Latin America)'   {ChangeToSpanishLA}
     'Japanese'                  {ChangeToJapanese}
     'Chinese (Simplified)'      {ChangeToChineseSimplified}
     'Korean'                    {ChangeToKorean}
     'Chinese (Traditional)'     {ChangeToChineseTraditional}
     'Hindi'                     {ChangeToHindi}
     Default                     {write-output 'You selected NOTHING!!!'}
    }
}

#This is true whether the user presses cancel or clicks X
if ($result –eq [System.Windows.Forms.DialogResult]::Cancel)
{
    write-output 'User pressed cancel'
}


$stream.Dispose()
$form.Dispose()