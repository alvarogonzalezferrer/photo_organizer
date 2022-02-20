; Install Photo Organizer - Windows
; for NSIS installer 
;--------------------------------

; The name of the installer
Name "Photo Organizer"

; The file to write
OutFile "photo_organizer_INSTALLER.exe"

; Request application privileges for Windows Vista and higher
RequestExecutionLevel admin

; Build Unicode installer
Unicode True

; The default installation directory
InstallDir $PROGRAMFILES\photo_organizer

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\photo_organizer" "Install_Dir"

;--------------------------------

; Pages

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

;--------------------------------

; The stuff to install
Section "Photo Organizer (required)"

  SectionIn RO
  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  
  ; Put files there
  File "bin\" *.*
  
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\photo_organizer "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\photo_organizer" "DisplayName" "photo_organizer"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\photo_organizer" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\photo_organizer" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\photo_organizer" "NoRepair" 1
  WriteUninstaller "$INSTDIR\uninstall.exe"
  
SectionEnd

; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\photo_organizer"
  CreateShortcut "$SMPROGRAMS\photo_organizer\Uninstall.lnk" "$INSTDIR\uninstall.exe"
  CreateShortcut "$SMPROGRAMS\photo_organizer\photo_organizer.lnk" "$INSTDIR\photo_organizer.exe"
  
  ; desktop
  
  CreateShortcut "$DESKTOP\photo_organizer.lnk" "$INSTDIR\photo_organizer.exe"

SectionEnd

;--------------------------------

; Uninstaller

Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\photo_organizer"
  DeleteRegKey HKLM SOFTWARE\photo_organizer

  ; Remove files and uninstaller
  Delete $INSTDIR\*.*
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\photo_organizer\*.lnk"
  Delete "$DESKTOP\photo_organizer.lnk"

  ; Remove directories
  RMDir "$SMPROGRAMS\photo_organizer"
  RMDir "$INSTDIR"

SectionEnd
