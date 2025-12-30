#NoEnv
#SingleInstance Force
#Persistent
Menu, Tray, NoStandard

prevent = 0
peroid = 5000
argc = %0%
if (argc >= 1) {
    peroid = %1%
}
initmenu()
gosub updatemenu
Return

initmenu()
{
    Menu, Tray, DeleteAll
    Menu, Tray, Add, 阻止自动睡眠, TogglePrevent
    Menu, Tray, Add
    Menu, Tray, Add, 显示隐藏的项目, ToggleHidden
    Menu, Tray, Default, 阻止自动睡眠
    Menu, Tray, Add, 显示系统文件, ToggleSuperHidden
    Menu, Tray, Add
    Menu, Tray, Add, 退出, quit
}

updatemenu:
    SetTimer, updatemenu, Off
    RegRead Value, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
    if (Value = 1) {
        Menu, Tray, Check, 显示隐藏的项目
        Menu, Tray, enable, 显示系统文件
        RegRead Value, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden
        if (Value = 1) {
			Menu, Tray, Check, 显示系统文件
            Menu, Tray, Tip, 显示隐藏的项目，显示系统文件
			if (prevent = 0) {
				Menu, Tray, Icon, imageres.dll , 249
			}
        } else {
        	Menu, Tray, UnCheck, 显示系统文件
            Menu, Tray, Tip, 显示隐藏的项目
			if (prevent = 0) {
				Menu, Tray, Icon, imageres.dll , 251
			}
        }
    } else {
        Menu, Tray, UnCheck, 显示隐藏的项目
        Menu, Tray, disable, 显示系统文件
        Menu, Tray, Tip, 不显示隐藏的项目
		if (prevent = 0) {
			Menu, Tray, Icon, imageres.dll , 250
		}
    }
    if (prevent = 1) {
		Menu, Tray, Check, 阻止自动睡眠
		Menu, Tray, Icon, imageres.dll , 281
    } else {
    	Menu, Tray, UnCheck, 阻止自动睡眠
    }
    SetTimer, updatemenu, %peroid%
return

TogglePrevent:
    if (prevent = 0) {
		DllCall("SetThreadExecutionState", "UInt", 0x80000003)
		prevent = 1
    } else {
    	DllCall("SetThreadExecutionState", "UInt", 0x80000000)
    	prevent = 0
    }
    Gosub, updatemenu
Return

ToggleHidden:
    RegRead, Value, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
    if (Value = 1) {
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
    } else {
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
    }
	Effect()
    Gosub, updatemenu
Return

ToggleSuperHidden:
    RegRead, Value, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden
    if (Value = 1) {
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden, 0
    } else {
        RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden, 1
    }
	Effect()
    Gosub, updatemenu
Return

Effect()
{
	WinGet, id, List, ahk_class CabinetWClass
	Loop, %id%
	{
	id := id%A_Index%
	PostMessage, 0x111, 0x1A220,,, ahk_id %id%
	}
	WinGet, id, ID, ahk_class Progman
	PostMessage, 0x111, 0x1A220,,, ahk_id %id%
}

quit:
    DllCall("SetThreadExecutionState", "UInt", 0x80000000)
    ExitApp
return
