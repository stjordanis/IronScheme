; Script generated by the HM NIS Edit Script Wizard.

; HM NIS Edit Wizard helper defines
!define PRODUCT_NAME "IronScheme"
!define PRODUCT_VERSION "1.0-beta4"
!define PRODUCT_PUBLISHER "leppie"
!define PRODUCT_WEB_SITE "http://ironscheme.codeplex.com"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\IronScheme.Console.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

SetCompressor /SOLID lzma
XPStyle on

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "IronScheme-${PRODUCT_VERSION}-setup.exe"
InstallDir "$PROGRAMFILES\IronScheme"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails show
ShowUnInstDetails show

!include "MUI2.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_ICON "..\..\..\ironscheme.ico"
!define MUI_UNICON "..\..\..\ironscheme.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "..\..\..\header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\..\..\welcome.bmp"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES
; Finish page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"



; MUI end ------

!define BASE_URL http://download.microsoft.com/download
!define URL_DOTNET "http://download.microsoft.com/download/0/8/c/08c19fa4-4c4f-4ffb-9d6c-150906578c9e/NetFx20SP1_x86.exe"

LangString DESC_SHORTDOTNET ${LANG_ENGLISH} ".Net Framework 2.0 SP1"
LangString DESC_LONGDOTNET ${LANG_ENGLISH} "Microsoft .Net Framework 2.0 SP1"
LangString DESC_DOTNET_DECISION ${LANG_ENGLISH} "$(DESC_SHORTDOTNET) is required.$\nIt is strongly \
  advised that you install$\n$(DESC_SHORTDOTNET) before continuing.$\nIf you choose to continue, \
  you will need to connect$\nto the internet before proceeding.$\nWould you like to continue with \
  the installation?"
LangString SEC_DOTNET ${LANG_ENGLISH} "$(DESC_SHORTDOTNET) "
LangString DESC_INSTALLING ${LANG_ENGLISH} "Installing"
LangString DESC_DOWNLOADING1 ${LANG_ENGLISH} "Downloading"
LangString DESC_DOWNLOADFAILED ${LANG_ENGLISH} "Download Failed:"
LangString ERROR_DOTNET_DUPLICATE_INSTANCE ${LANG_ENGLISH} "The $(DESC_SHORTDOTNET) Installer is \
  already running."
LangString ERROR_NOT_ADMINISTRATOR ${LANG_ENGLISH} "$(DESC_000022)"
LangString ERROR_INVALID_PLATFORM ${LANG_ENGLISH} "$(DESC_000023)"
LangString DESC_DOTNET_TIMEOUT ${LANG_ENGLISH} "The installation of the $(DESC_SHORTDOTNET) \
  has timed out."
LangString ERROR_DOTNET_INVALID_PATH ${LANG_ENGLISH} "The $(DESC_SHORTDOTNET) Installation$\n\
  was not found in the following location:$\n"
LangString ERROR_DOTNET_FATAL ${LANG_ENGLISH} "A fatal error occurred during the installation$\n\
  of the $(DESC_SHORTDOTNET)."
LangString FAILED_DOTNET_INSTALL ${LANG_ENGLISH} "The installation of $(PRODUCT_NAME) will$\n\
  continue. However, it may not function properly$\nuntil $(DESC_SHORTDOTNET)$\nis installed."

Var NETPATH

; IsDotNETInstalled
;
; Usage:
;   Call IsDotNETInstalled
;   Pop $0
;   StrCmp $0 1 found.NETFramework no.NETFramework

Function IsDotNETInstalled
   Push $0
   Push $1
   Push $2
   Push $3
   Push $4

   ReadRegStr $4 HKEY_LOCAL_MACHINE \
     "Software\Microsoft\.NETFramework" "InstallRoot"
   # remove trailing back slash
   Push $4
   Exch $EXEDIR
   Exch $EXEDIR
   Pop $4
   # if the root directory doesn't exist .NET is not installed
   IfFileExists $4 0 noDotNET

   StrCpy $0 0

   EnumStart:

     EnumRegKey $2 HKEY_LOCAL_MACHINE \
       "Software\Microsoft\.NETFramework\Policy"  $0
     IntOp $0 $0 + 1
     StrCmp $2 "" noDotNET

     StrCpy $1 0

     EnumPolicy:

       EnumRegValue $3 HKEY_LOCAL_MACHINE \
         "Software\Microsoft\.NETFramework\Policy\$2" $1
       IntOp $1 $1 + 1
        StrCmp $3 "" EnumStart
         IfFileExists "$4\v2.0.$3" foundDotNET EnumPolicy

   noDotNET:
     DetailPrint ".NET 2.0 not detected."
     StrCpy $0 0
     Goto done

   foundDotNET:
     DetailPrint ".NET 2.0 detected @ $4\v2.0.$3."
     StrCpy $0 "$4\v2.0.$3"

   done:
     Pop $4
     Pop $3
     Pop $2
     Pop $1
     Exch $0
FunctionEnd

InstType "Full"
InstType "Minimal"

Section -$(SEC_DOTNET) SECDOTNET
SectionIn 1 2 RO

Goto Start

AbortInstall:
Abort

Start:
Call IsDotNETInstalled
Pop $NETPATH
StrCmp $NETPATH 0 PromptDownload Install

PromptDownload:

MessageBox MB_ICONEXCLAMATION|MB_YESNO|MB_DEFBUTTON2 "$(DESC_DOTNET_DECISION)" /SD IDNO IDYES DownloadNET IDNO AbortInstall

DownloadNET:

nsisdl::download /TIMEOUT=60000 "${URL_DOTNET}" "$TEMP\NetFx20SP1_x86.exe"
Pop $0
StrCmp "$0" "success" InstallNET AbortInstall

InstallNET:
Exec '"$TEMP\NetFx20SP1_x86.exe" /q:a /c:"install.exe /qb"'

Install:

SectionEnd

Section "IronScheme ${PRODUCT_VERSION}" SEC01
SectionIn 1 2 RO
  SetOutPath "$INSTDIR"
  
  DetailPrint "Removing previous native images (if any)..."
  nsExec::ExecToStack '"$NETPATH\ngen.exe" uninstall "$INSTDIR\ironscheme.boot.dll"'

  CreateDirectory "$SMPROGRAMS\IronScheme"

  CreateShortCut "$SMPROGRAMS\IronScheme\IronScheme.lnk" "$INSTDIR\IronScheme.Console.exe"
  CreateShortCut "$DESKTOP\IronScheme.lnk" "$INSTDIR\IronScheme.Console.exe"

	File "IronScheme.Console.exe"
	File "IronScheme.Console.exe.config"
	
	File "IronScheme.dll"
	File "IronScheme.Remoting.dll"
	File "IronScheme.Closures.dll"
	File "IronScheme.Web.Runtime.dll"
	
	File "ironscheme.boot.dll"
	File "Microsoft.Scripting.dll"
	
	File "build-options.ss"
	File "system-libraries.ss"
	File "init.ss"
	File "compile-system-libraries.ss"
	
	File "..\..\..\IronScheme.WebServer\bin\Release\IronScheme.WebServer.exe"
	File "..\..\..\IronScheme.WebServer\bin\Release\IronScheme.WebServer.exe.config"
	
	File ..\..\..\tools\IronScheme.VisualStudio.dll
	File ..\..\..\tools\RegPkg.exe
	File ..\..\..\tools\RegPkg.exe.config
	
	File "ironscheme-buildscript.ss"

	SetOutPath "$INSTDIR\examples"
	File /r examples\*.ss
	
	SetOutPath "$INSTDIR\docs"
	File /r docs\*.txt
	
	SetOutPath "$INSTDIR\ironscheme"
	File /r ironscheme\*.ss
	
	SetOutPath "$INSTDIR\lib"
	File /r lib\*.ss
	File /r lib\*.sls
	
	SetOutPath "$INSTDIR\build"
	File /r build\*.ss
	
	SetOutPath "$INSTDIR\psyntax"
	File psyntax\*.ss
	
	SetOutPath "$INSTDIR\srfi"
	File /r srfi\*.ss
	File /r srfi\*.sps
	File /r srfi\*.sls
	File /r srfi\*.scm
	File srfi\COPYING
	File srfi\README
	;File /r srfi\*.fasl
	
	SetOutPath "$INSTDIR\websample"
	File ..\..\..\IronScheme.Web\test.ss
	File ..\..\..\IronScheme.Web\test2.ss
	File ..\..\..\IronScheme.Web\web.config
	File ..\..\..\IronScheme.Web\web.routes
	
	SetOutPath "$INSTDIR\websample\controllers"
	File /r ..\..\..\IronScheme.Web\controllers\*.sls
	
	SetOutPath "$INSTDIR\websample\views"
	File /r ..\..\..\IronScheme.Web\views\*.sls
	
	SetOutPath "$INSTDIR\websample\models"
	File /r ..\..\..\IronScheme.Web\models\*.sls
	
	SetOutPath "$INSTDIR\websample\styles"
	File /r ..\..\..\IronScheme.Web\styles\*.css
	
	SetOutPath "$INSTDIR\websample\data"
	File "placeholder.txt"
	
	SetOutPath "$INSTDIR\tests"
	File /r tests\*.*
	
SectionEnd


Section -AdditionalIcons
  CreateShortCut "$SMPROGRAMS\IronScheme\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

Section -Post
  SetOutPath "$INSTDIR"
  DetailPrint "Generating native images..."
  nsExec::ExecToStack '"$NETPATH\ngen.exe" install "$INSTDIR\ironscheme.boot.dll"'
  DetailPrint "Compiling system libraries..."
  nsExec::ExecToStack '"$INSTDIR\IronScheme.Console.exe" "$INSTDIR\compile-system-libraries.ss"'
  DetailPrint "Creating symbolic links..."
  SetOutPath "$INSTDIR\websample"
  nsExec::ExecToStack 'cmd /c mkdir bin'
  SetOutPath "$INSTDIR\websample\bin"
  ; this will probably fail on non-Vista
  nsExec::ExecToStack 'cmd /c mklink IronScheme.dll "$INSTDIR\IronScheme.dll"'
  nsExec::ExecToStack 'cmd /c mklink IronScheme.Closures.dll "$INSTDIR\IronScheme.Closures.dll"'
  nsExec::ExecToStack 'cmd /c mklink ironscheme.boot.dll "$INSTDIR\ironscheme.boot.dll"'
  nsExec::ExecToStack 'cmd /c mklink Microsoft.Scripting.dll "$INSTDIR\Microsoft.Scripting.dll"'
  nsExec::ExecToStack 'cmd /c mklink IronScheme.Web.Runtime.dll "$INSTDIR\IronScheme.Web.Runtime.dll"'
  nsExec::ExecToStack 'cmd /c mklink /d ironscheme "$INSTDIR\ironscheme"'
  nsExec::ExecToStack 'cmd /c mklink /d srfi "$INSTDIR\srfi"'
  nsExec::ExecToStack 'cmd /c mklink /d lib "$INSTDIR\lib"'
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\IronScheme.Console.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\IronScheme.Console.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.IsDotNETInstalled
   Push $0
   Push $1
   Push $2
   Push $3
   Push $4

   ReadRegStr $4 HKEY_LOCAL_MACHINE \
     "Software\Microsoft\.NETFramework" "InstallRoot"
   # remove trailing back slash
   Push $4
   Exch $EXEDIR
   Exch $EXEDIR
   Pop $4
   # if the root directory doesn't exist .NET is not installed
   IfFileExists $4 0 noDotNET

   StrCpy $0 0

   EnumStart:

     EnumRegKey $2 HKEY_LOCAL_MACHINE \
       "Software\Microsoft\.NETFramework\Policy"  $0
     IntOp $0 $0 + 1
     StrCmp $2 "" noDotNET

     StrCpy $1 0

     EnumPolicy:

       EnumRegValue $3 HKEY_LOCAL_MACHINE \
         "Software\Microsoft\.NETFramework\Policy\$2" $1
       IntOp $1 $1 + 1
        StrCmp $3 "" EnumStart
         IfFileExists "$4\v2.0.$3" foundDotNET EnumPolicy

   noDotNET:
     StrCpy $0 0
     Goto done

   foundDotNET:
     StrCpy $0 "$4\v2.0.$3"

   done:
     Pop $4
     Pop $3
     Pop $2
     Pop $1
     Exch $0
FunctionEnd

Function un.onUninstSuccess
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Function un.onInit
  MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
  Abort
FunctionEnd

Section Uninstall
  Call un.IsDotNETInstalled
  Pop $NETPATH

  DetailPrint "Removing native images..."
  nsExec::ExecToStack '"$NETPATH\ngen.exe" uninstall "$INSTDIR\ironscheme.boot.dll"'
  
  Delete "$DESKTOP\IronScheme.lnk"
	
  RMDir /r "$SMPROGRAMS\IronScheme"
  RMDir /r "$INSTDIR"

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
