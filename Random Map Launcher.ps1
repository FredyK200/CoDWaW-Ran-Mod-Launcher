# Call of Duty: World At War Random Mod Launcher
# Written By: Kane Eder



# ==============================================
#                 Functions
# ==============================================

Function Read-File
{
        #Read File Contents
    $file = Get-Content '.\RMLDATA.txt'
    $trash, $global:mods_path, $global:launcher_path, $trash, $mod_array = $file

        #Create Associative Array With Names=>Ratings
    foreach($mod in $mod_array)
    {
        $temp = $mod -split "="
        $global:mods_array[$temp[0]] = $temp[1]        
    }
}

Function Save-File
{
    $global:mods_array[$mod] = ([uint16]$textBox.Text)/10
    Out-File -FilePath "$global:initial_process_path\RMLDATA.txt" -InputObject '# File Path Data'
    Out-File -FilePath "$global:initial_process_path\RMLDATA.txt" -Append -InputObject $global:mods_path 
    Out-File -FilePath "$global:initial_process_path\RMLDATA.txt" -Append -InputObject $global:launcher_path
    Out-File -FilePath "$global:initial_process_path\RMLDATA.txt" -Append -InputObject '# Mod Rating Data'
    foreach($mod in $global:mods_array.Keys | Sort-Object)
    {
        Out-File -FilePath "$global:initial_process_path\RMLDATA.txt" -Append -InputObject ($mod+'='+$global:mods_array[$mod])
    }
}


Function Get-Weighted-Random
{
    #Pick Random Mod From Array, Favoring Higher Rated Mods
    Param ($mods_array)
    if ($mods_array.Count -eq 1)
    {
        Return $mods_array[0]
    }

    $total_weight = 0
    foreach($mod in $mods_array.Keys)
    {
        $total_weight += [float]$mods_array[$mod]
    }

    $random_weight = Get-Random -Minimum 0 -Maximum $total_weight
    $accumulative_weight = 0
    foreach($mod in $mods_array.Keys)
    {
        $accumulative_weight += [float]$mods_array[$mod]

        if($accumulative_weight -ge $random_weight)
        {
            Return ($mod)
        }
    }
}



# ==============================================
#                   Initializing
# ==============================================
$global:mods_path=""
$global:launcher_path=""
$global:initial_process_path=""
$global:mods_array=@{}
$global:initial_process_path = Get-Location

Add-Type -AssemblyName System.Windows.Forms

if(Test-Path "$global:initial_process_path\RMLDATA.txt")
{
    Read-File
}
else
{
        #Get Folder Paths & Mod Names
    $global:mods_path = Read-Host -Prompt ('Path of your WAW mods Folder') 
    $global:launcher_path = Read-Host -Prompt ('Path of your WAW exe') 
    $mod_array = Get-ChildItem -Path $global:mods_path -Name  | sort lastwritetime
    foreach($mod in $mod_array)
    {
        $global:mods_array[$mod] = 1  
    }
    #cls
}

# Launch New Mod
$waw = Get-Process -Name CoDWaW -ErrorAction SilentlyContinue
if($waw)
{
    $waw | Stop-Process -Force
    Sleep 2
}
    #Select Mod And Copy Needed Console Comand To Clipboard
$mod = Get-Weighted-Random $global:mods_array
$modrating = 10 * $global:mods_array[$mod]
Set-Clipboard -Value "/devmap $mod"
    #Launch WAW With Selected Mod
cd $global:launcher_path
$mod_argument = " +set fs_game `"mods/$mod`""
Start-Process -FilePath '.\CoDWaW.exe' -ArgumentList $mod_argument


# ==============================================
#                 GUI / Form
# ==============================================

# Create a new form
$form = New-Object System.Windows.Forms.Form

# Create a label and add it to the form
$label0 = New-Object System.Windows.Forms.Label
$label0.Text = 'Mods Found: ' + $global:mods_array.Count.ToString()
$form.Controls.Add($label0)

# Set the size and location of the label
$label0.Size = New-Object System.Drawing.Size(100,20)
$label0location = (350/2) - ($label0.width/2)
$label0.Location = New-Object System.Drawing.Point($label0location,10)

# Create a label and add it to the form
$label1 = New-Object System.Windows.Forms.Label
$label1.Text = $mod
$form.Controls.Add($label1)

# Set the size and location of the label
$label1.Size = New-Object System.Drawing.Size(200,20)
$label1.Location = New-Object System.Drawing.Point(10,30)

# Create a button and add it to the form
$button1 = New-Object System.Windows.Forms.Button
$button1.Text = "Next Mod"
$form.Controls.Add($button1)

# Set the size and location of the button
$button1.Size = New-Object System.Drawing.Size(100,20)
$button1.Location = New-Object System.Drawing.Point(220,30)

# Add an event handler to the button's Click event
$button1.Add_Click({
         # Launch New Mod
            $waw = Get-Process -Name CoDWaW -ErrorAction SilentlyContinue
            if($waw)
            {
                $waw | Stop-Process -Force
                Sleep 2
            }
                #Select Mod And Copy Needed Console Comand To Clipboard
            $mod = Get-Weighted-Random $global:mods_array
            $modrating = 10 * $global:mods_array[$mod]
            $label1.Text = $mod
            $label2.Text = $modrating.ToString() + " /10 stars"
            Set-Clipboard -Value "/devmap $mod"
                #Launch WAW With Selected Mod
            cd $global:launcher_path
            $mod_argument = " +set fs_game `"mods/$mod`""
            Start-Process -FilePath '.\CoDWaW.exe' -ArgumentList $mod_argument
})

# Create a second label and add it to the form
$label2 = New-Object System.Windows.Forms.Label
$label2.Text = $modrating.ToString() + " /10 stars"
$form.Controls.Add($label2)

# Set the size and location of the second label
$label2.Size = New-Object System.Drawing.Size(200,20)
$label2.Location = New-Object System.Drawing.Point(10, 60)

# Create a second button and add it to the form
$button2 = New-Object System.Windows.Forms.Button
$button2.Text = "Rate Mod"
$form.Controls.Add($button2)

# Set the size and location of the second button
$button2.Size = New-Object System.Drawing.Size(100,20)
$button2.Location = New-Object System.Drawing.Point(220,60)

# Add an event handler to the second button's Click event
$button2.Add_Click({
        #Hide Current Button and Label
        $button2.Hide()
        $label2.Hide()

        #Show New Button and Text Box
        $button3.Show()
        $textBox.Show()

        $form.Refresh()
})


$button3 = New-Object System.Windows.Forms.Button
$button3.Text = "Submit"
$form.Controls.Add($button3)

# Set the size and location of the second button
$button3.Size = New-Object System.Drawing.Size(100,20)
$button3.Location = New-Object System.Drawing.Point(220,60)
$button3.Hide()

# Create a new text box
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Size = New-Object System.Drawing.Size(200,20)
$textBox.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($textBox)
$textBox.Hide()

$button3.Add_Click({
    
        #Update Rating 
        # This doesn't run while the form is running, find a way to fix this
        $form.Invoke(([System.Windows.Forms.MethodInvoker] { Save-File }))

        $label2.Text = $textBox.Text + " /10 stars"
        # Hide button3 and text box
        $button3.Hide()
        $textBox.Hide()
        $textBox.Text = ""

        # Show Label2 and Button2
        $button2.Show()
        $label2.Show()
        $form.Refresh()

})

# Set the size and location of the form
$form.Size = New-Object System.Drawing.Size(350,150)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"

# Show the form
$form.ShowDialog()
