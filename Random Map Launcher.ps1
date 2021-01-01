# Call of Duty: World At War Random Mod Launcher
# Written By: Kane Eder
# ==============================================
$global:mods_path=""
$global:launcher_path=""
$global:initial_process_path=""
$global:mods_array=@{}

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

    #Main
$global:initial_process_path = Get-Location

if(Test-Path "$global:initial_process_path\RMLDATA.txt")
{
    Read-File
}
else
{
        #Get Folder Paths & Mod Names
    $global:mods_path = Read-Host -Prompt ('Path of your WAW mods Folder') 
    $global:launcher_path = Read-Host -Prompt ('Path of your WAW exe') 
    $mods_array = Get-ChildItem -Path $global:mods_path -Name
    foreach($mod in $mods_array)
    {
        $global:mods_array[$mod] = 1      
    }
    cls
}


Write-Host -ForegroundColor Gray -Object (' {{ Mods Found: ' + $global:mods_array.Count + ' }} ')
$wait = 'n'

while($wait -ne 'q')
{
    switch($wait)
    {
            # n - Launch New Mod
        'n'
        {
                #Close Process If Running 
            $waw = Get-Process -Name CoDWaW -ErrorAction SilentlyContinue
            if($waw)
            {
                Write-Host -ForegroundColor Gray -Object ('Closing running instance of CoDWaW..')
                $waw | Stop-Process -Force
                Sleep 2
            }
                #Select Mod And Copy Needed Console Comand To Clipboard
            $mod = Get-Weighted-Random $global:mods_array
            Write-Host -ForegroundColor Red -Object ('Launching Mod: ' + $mod)
            Set-Clipboard -Value "/devmap $mod"
                #Launch WAW With Selected Mod
            cd $global:launcher_path
            $mod_argument = " +set fs_game `"mods/$mod`""
            Start-Process -FilePath '.\CoDWaW.exe' -ArgumentList $mod_argument
        }
            # r - Rate Mod
        'r'
        {
            do
            {
                try
                {
                    [uint16]$rating = Read-Host -Prompt ("Rate $mod (1-10)")
                    if($rating -le 10)
                    {
                        $global:mods_array[$mod] = $rating/10
                        $mod_rated = $true
                        Save-File
                    }
                    else
                    {
                        Write-Host -ForegroundColor Red -Object ('Please enter a number between 1-10')
                    }
                }
                catch
                {
                    Write-Host -ForegroundColor Red -Object ('Please enter a number between 1-10')
                    $mod_rated = $false
                }

            }
            until($mod_rated)
        }
            # default - Do Nothing
        default
        {
            $wait = Write-Host ('unknown command')
        }
    }
    $wait = Read-Host -Prompt ('q-escape, n-launch new mod, r-rate current mod')
}