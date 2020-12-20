# Call of Duty: World At War Random Mod Launcher
# Written By: Kane Eder
# ==============================================
if(Test-Path .\file-paths.txt)
{
        #Read File Contents
    $file = New-Object System.IO.StreamReader('.\file-paths.txt')
    $mods_path = $file.ReadLine()
    $launcher_path = $file.ReadLine()
    $file.Dispose()
}
else
{
        #Get Folder Paths / Save To File
    $mods_path = Read-Host -Prompt ('Path of your WAW mods Folder') 
    $launcher_path = Read-Host -Prompt ('Path of your WAW exe') 
    $mods_path | Out-File -FilePath ./file-paths.txt
    $launcher_path | Out-File -FilePath ./file-paths.txt -Append
    cls
}

$mods_array = Get-ChildItem -Path $mods_path -Name
$wait = 'n'

while($wait -ne 'q')
{
    if($wait -eq 'n')
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
        $mod = Get-Random -InputObject $mods_array
        Write-Host -ForegroundColor Red -Object ('Launching Mod: ' + $mod)
        Set-Clipboard -Value "/devmap $mod"
            #Launch WAW With Selected Mod
        cd $launcher_path
        $mod_argument = " +set fs_game `"mods/$mod`""
        Start-Process -FilePath '.\CoDWaW.exe' -ArgumentList $mod_argument

        $wait = Read-Host -Prompt ('q will escape, n will launch new mod')
    }
    else
    {
        $wait = Read-Host -Prompt ('unknown command')
    }
}
