'
' mihaiush, 20061002
'
'    Modified Barry W. Alder 2013/09/24
'      changed code so that an error is reported if no disks are found with the /x flag
'      and an error is reported if the disk specified in the /d flag is not found
'
Set args = WScript.Arguments.Named

If (not args.Exists("w")) or (not args.Exists("c")) or args.Exists("h") Then
	WScript.Echo
	WScript.Echo "Usage: check_disk.vbs /w:INTEGER /c:INTEGER [/p] [/d:DRIVE_LIST | /x:DRIVE_LIST] [/u:UNITS] [/h]"
	WScript.Echo "	/w: warning limit"
	WScript.Echo "	/c: critical limit"
	WScript.Echo "	/p: limits in %, otherwise in UNITS"
	WScript.Echo "	/d: included drives list"
	WScript.Echo "	/x: excluded drives list"
	WScript.Echo "	/u: B | kB | MB | GB, default MB"
	WScript.Echo "	/h: this help"
	WScript.Echo
	WScript.Echo "	check_disk.vbs /w:15 /c:5 /p /d:CDE /u:kB - result will be displayed in kB, limits are in percents"
	WScript.Echo "	check_disk.vbs /w:500 /c:250 - result will be displayed in MB, limits are in MB, all fixed drives"
	WScript.Echo
	WScript.Quit 3
End If

If args.Exists("u") Then
	u=args.Item("u")
	If u<>"B" and u<>"kB" and u<>"MB" and u<>"GB" Then
		WScript.Echo
		WScript.Echo "Units must be one of B, kB, MB, GB"
		WScript.Echo
		WScript.Quit 3	
	End If
Else
	u="MB"
End If

Select Case u
	Case "B"
		uLabel=""
		uVal=1
	Case "kB"
		uLabel="kB"
		uVal=1024
	Case "MB"
		uLabel="MB"
		uVal=1024*1024
	Case "GB"
		uLabel="GB"
		uVal=1024*1024*1024
End Select

w=1*args.Item("w")
c=1*args.Item("c")
p=args.Exists("p")

If w<c Then
	WScript.Echo
	WScript.Echo "Warning limit must be greater than critical limit"
	WScript.Echo
	WScript.Quit 3
End If

Set objFSO=CreateObject("Scripting.FileSystemObject")
Set colDrives=objFSO.Drives

outCode=3

For Each objDrive in colDrives

	If DriveSelected(objDrive) Then

		outCode=0
		outText=" - free space:"
 		disk=objDrive.DriveLetter
 		freeSpace=objDrive.FreeSpace
 		size=objDrive.TotalSize
 		If outCode=0 Then
 				If p Then
 					If 100*freeSpace/size<w Then
 						outCode=1
 					End If 
 				Else
 					If freeSpace/uVal<w Then
 						outCode=1
 					End If
 				End If
 		End If
 		If outCode=1 Then
 				If p Then
 					If 100*freeSpace/size<c Then
 						outCode=2
 					End If 
 				Else
 					If freeSpace/uVal<c Then
 						outCode=2
 					End If
 				End If
 		End If
 		outText=outText & " " & disk & " " & Round(freeSpace/uVal) & uLabel & " (" & Round(100*freeSpace/size) & "%);"
 	End If
Next

Select Case outCode
	Case 0
		outText="DISK OK" & outText
	Case 1
		outText="DISK WARNING" & outText
	Case 2
		outText="DISK CRITICAL" & outText
	Case 3
		outCode = 2
		outText = "ERROR! No disk found"
End Select

WScript.Echo outText
WScript.Quit outCode

Function DriveSelected(d)
	DriveSelected=false

	If d.DriveType <> 2 Then
	    Exit Function
	End If

	If args.Exists("d") Then
		If InStr(UCase(args.Item("d")),d.DriveLetter)>0 Then
			DriveSelected=true
		End If
	ElseIf args.Exists("x") Then
		If InStr(UCase(args.Item("x")),d.DriveLetter)>0 Then
			DriveSelected=false
		ElseIf d.DriveType=2 Then
			DriveSelected=true
		End If
	End If
End Function
