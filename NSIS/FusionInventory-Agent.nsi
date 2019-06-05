/*
   ------------------------------------------------------------------------
   FusionInventory Agent Installer for Microsoft Windows
   Copyright (C) 2010-2017 by the FusionInventory Development Team.

   http://www.fusioninventory.org/
   ------------------------------------------------------------------------

   LICENSE

   This file is part of FusionInventory project.

   FusionInventory Agent Installer for Microsoft Windows is free software;
   you can redistribute it and/or modify it under the terms of the GNU
   General Public License as published by the Free Software Foundation;
   either version 2 of the License, or (at your option) any later version.


   FusionInventory Agent Installer for Microsoft Windows is distributed in
   the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
   the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
   PURPOSE. See the GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA,
   or see <http://www.gnu.org/licenses/>.

   ------------------------------------------------------------------------

   @package   FusionInventory Agent Installer for Microsoft Windows
   @file      .\FusionInventory-Agent.nsi
   @author    Tomas Abad <tabadgp@gmail.com>
   @copyright Copyright (c) 2010-2017 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      https://github.com/fusioninventory/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


SetCompressor /FINAL /SOLID lzma


;--------------------------------
; Definitions

; Notes: FusionInventory Agent (FIA)
;        FusionInventory Agent Installer (FIAI)

!define FIAI_RELEASE "${FIA_MAJOR}.${FIA_MINOR}.${FIA_SUB}01"
!define FIAI_DIR ".\FusionInventory-Agent"

; Use MakeNSIS '/D' option for choose the debug mode
;    (Symbol: FIAI_DEBUG_LEVEL)

; Check symbol FIAI_DEBUG_LEVEL
!define FIAI_DEBUG_LEVEL_0 "0"
!define FIAI_DEBUG_LEVEL_1 "1"

!ifdef FIAI_DEBUG_LEVEL
   !if ${FIAI_DEBUG_LEVEL} != ${FIAI_DEBUG_LEVEL_0}
      !if ${FIAI_DEBUG_LEVEL} != ${FIAI_DEBUG_LEVEL_1}
         !undef FIAI_DEBUG_LEVEL
         !define FIAI_DEBUG_LEVEL "${FIAI_DEBUG_LEVEL_0}"
      !endif
   !endif
!else
   !define FIAI_DEBUG_LEVEL "${FIAI_DEBUG_LEVEL_0}"
!endif

; Use MakeNSIS '/D' option for choose the architecture
;    (Symbol: PRODUCT_PLATFORM_ARCHITECTURE)

; Check symbol PRODUCT_PLATFORM_ARCHITECTURE
!define PLATFORM_ARCHITECTURE_32 "x86"
!define PLATFORM_ARCHITECTURE_64 "x64"

!ifdef PRODUCT_PLATFORM_ARCHITECTURE
   !if ${PRODUCT_PLATFORM_ARCHITECTURE} != ${PLATFORM_ARCHITECTURE_32}
      !if ${PRODUCT_PLATFORM_ARCHITECTURE} != ${PLATFORM_ARCHITECTURE_64}
         !error "The symbol 'PRODUCT_PLATFORM_ARCHITECTURE' has been defined with an invalid value!"
      !endif
   !endif
!else
   !error "The symbol 'PRODUCT_PLATFORM_ARCHITECTURE' hasn't been defined!"
!endif

; Use MakeNSIS '/D' option for choose the type of release of the agent
;    (Symbol: PRODUCT_RELEASE_TYPE)

; Check symbol PRODUCT_RELEASE_TYPE
!define RELEASE_TYPE_STABLE "stable"
!define RELEASE_TYPE_CANDIDATE "candidate"
!define RELEASE_TYPE_DEVELOPMENT "development"

!ifdef PRODUCT_RELEASE_TYPE
   !if "${PRODUCT_RELEASE_TYPE}" != "${RELEASE_TYPE_STABLE}"
      !if "${PRODUCT_RELEASE_TYPE}" != "${RELEASE_TYPE_CANDIDATE}"
         !if "${PRODUCT_RELEASE_TYPE}" != "${RELEASE_TYPE_DEVELOPMENT}"
            !error "The symbol 'PRODUCT_RELEASE_TYPE' has been defined with an invalid value!"
         !endif
      !endif
   !endif
!else
   !error "The symbol 'PRODUCT_RELEASE_TYPE' hasn't been defined!"
!endif

; Release of Strawberry Perl Portable Edition Package for FusionInventory Agent
!ifndef STRAWBERRY_RELEASE
   !error "The symbol 'STRAWBERRY_RELEASE' hasn't been defined!"
!endif

; Releases of FusionInventory Agent Tasks
; TODO: We need to better read tasks release version while preparing sources
!define FIA_TASK_COLLECT_RELEASE "2.6"
!define FIA_TASK_DEPLOY_RELEASE "2.8"
!define FIA_TASK_ESX_RELEASE "2.4"
!define FIA_TASK_INVENTORY_RELEASE "1.7"
!define FIA_TASK_NETDISCOVERY_RELEASE "2.9"
!define FIA_TASK_NETINVENTORY_RELEASE "3.3"
!define FIA_TASK_WAKEONLAN_RELEASE "2.2"
!define FIA_TASK_WMI_RELEASE "0.3"
!define FIA_TASK_MAINTENANCE_RELEASE "1.1"

; Release of the product
;    Note: The 'product' is the installer generated
;
;    This is the pattern of the product:
;
;         product = "fusioninventory-agent_windows-" , platform , "_" , version , ".exe"
;
;        platform = "x86" | "x64" ;
;
;         version = sversion
;                 | cversion
;                 | dversion ;
;
;        (* sversion: stable version *)
;
;        sversion = mayor , "." , minor , "." , release , [ "-" , <patch> ]
;                 | commit ;
;
;                 (* commit: the first ten digits only *)
;
;        (* cversion: candidate version *)
;
;        cversion = mayor , "." , minor , "." , release , "-rc" , candidate
;                 | commit , "-rc" , candidate ;
;
;                 (* commit: the first ten digits only *)
;
;        (* dversion: development version *)
;
;        dversion = commit , "-dev" ;
;
;                 (* commit: the first ten digits only *)
;
;
!if "${PRODUCT_RELEASE_TYPE}" == "${RELEASE_TYPE_STABLE}"
   ; Product version for stable releases
   !ifndef FIA_RELEASE
      !error "The symbol 'FIA_RELEASE' hasn't been defined!"
   !endif
   !define PRODUCT_VERSION "${FIA_RELEASE}"

   ; If PRODUCT_VERSION is a commit then
   ;    define the following symbols as empty string
   !define PRODUCT_VERSION_MAJOR "${FIA_MAJOR}"
   !define PRODUCT_VERSION_MINOR "${FIA_MINOR}"
   !define PRODUCT_VERSION_RELEASE "${FIA_SUB}"
   !define PRODUCT_VERSION_PATCH "${FIA_PATCH}"

   ; File version
   ;    for Windows Version Information
   !ifdef FIAI_BUILD
      !define PRODUCT_VERSION_BUILD "${FIAI_BUILD}"
      !define FILE_VERSION "${FIA_MAJOR}.${FIA_MINOR}.${FIA_SUB}.${FIAI_BUILD}"
   !else
      !define FILE_VERSION "${FIA_MAJOR}.${FIA_MINOR}.${FIA_SUB}.${FIA_PATCH}"
   !endif

   ; Bitmaps for stable releases
   !define MUI_HEADERIMAGE_BITMAP_FILE  "${FIAI_DIR}\Contrib\Skins\Default\HeaderRightMUI2.bmp"
   !define MUI_HEADERIMAGE_UNBITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\HeaderRightMUI2.bmp"
   !define MUI_WELCOMEFINISHPAGE_BITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\WelcomeMUI2.bmp"
   !define MUI_UNWELCOMEFINISHPAGE_BITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\WelcomeMUI2.bmp"
!else
   !if "${PRODUCT_RELEASE_TYPE}" == "${RELEASE_TYPE_CANDIDATE}"
      ; Product version for candidate releases
      !ifndef FIA_RELEASE
         !error "The symbol 'FIA_RELEASE' hasn't been defined!"
      !endif
      !define PRODUCT_VERSION "${FIA_RELEASE}"

      ; If PRODUCT_VERSION is a commit then
      ;    define the following symbols as empty string
      !define PRODUCT_VERSION_MAJOR "${FIA_MAJOR}"
      !define PRODUCT_VERSION_MINOR "${FIA_MINOR}"
      !define PRODUCT_VERSION_RELEASE "${FIA_SUB}"
      !define PRODUCT_VERSION_CANDIDATE "${FIA_RC}"

      ; File version
      ;    for Windows Version Information
      !define FILE_VERSION "${FIA_MAJOR}.${FIA_MINOR}.${FIA_SUB}.${FIA_FILERC}"

   ; Bitmaps for stable releases
      ; Bitmaps for candidate releases
      !define MUI_HEADERIMAGE_BITMAP_FILE  "${FIAI_DIR}\Contrib\Skins\Default\HeaderRightMUI2CandidateVersion.bmp"
      !define MUI_HEADERIMAGE_UNBITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\HeaderRightMUI2CandidateVersion.bmp"
      !define MUI_WELCOMEFINISHPAGE_BITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\WelcomeMUI2CandidateVersion.bmp"
      !define MUI_UNWELCOMEFINISHPAGE_BITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\WelcomeMUI2CandidateVersion.bmp"
   !else
      !ifdef FIAI_BUILD
         ; Product version for development releases with build number
         !define PRODUCT_VERSION "${FIA_RELEASE}-develop-${FIAI_BUILD}"
         !define PRODUCT_VERSION_BUILD "${FIAI_BUILD}"

         ; File version
         ;    for Windows Version Information
         !define FILE_VERSION "${FIA_MAJOR}.${FIA_MINOR}.${FIA_SUB}.${FIAI_BUILD}"
      !else
         ; Product version for development releases
         !define PRODUCT_VERSION "${FIA_COMMIT}-dev"

         ; File version
         ;    for Windows Version Information
         ;
         ; If PRODUCT_VERSION is a commit then
         ;    define the following symbols as '0.0.0.0'
         !define FILE_VERSION "0.0.0.0"
      !endif

      ; Bitmaps for development releases
      !define MUI_HEADERIMAGE_BITMAP_FILE  "${FIAI_DIR}\Contrib\Skins\Default\HeaderRightMUI2DevelopmentVersion.bmp"
      !define MUI_HEADERIMAGE_UNBITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\HeaderRightMUI2DevelopmentVersion.bmp"
      !define MUI_WELCOMEFINISHPAGE_BITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\WelcomeMUI2DevelopmentVersion.bmp"
      !define MUI_UNWELCOMEFINISHPAGE_BITMAP_FILE "${FIAI_DIR}\Contrib\Skins\Default\WelcomeMUI2DevelopmentVersion.bmp"
   !endif
!endif

; More information about the product
!define PRODUCT_NAME "FusionInventory Agent"
!define PRODUCT_INTERNAL_NAME "FusionInventory-Agent"
!define PRODUCT_PUBLISHER "FusionInventory Team"
!define PRODUCT_WEB_FOR_SUPPORT "https://github.com/fusioninventory/fusioninventory-agent"
!define PRODUCT_WEB_SITE "http://www.fusioninventory.org"
!define PRODUCT_UNINSTALLER "Uninstall.exe"
!define PRODUCT_INST_ROOT_KEY "HKEY_LOCAL_MACHINE"
!define PRODUCT_UNINST_ROOT_KEY "HKEY_LOCAL_MACHINE"
!define PRODUCT_HELP_FILE "fusioninventory-agent_windows-${PRODUCT_PLATFORM_ARCHITECTURE}_${PRODUCT_VERSION}.rtf"
!define PRODUCT_INSTALLER "fusioninventory-agent_windows-${PRODUCT_PLATFORM_ARCHITECTURE}_${PRODUCT_VERSION}.exe"
!define PRODUCT_WEB_FOR_UPDATES "https://github.com/fusioninventory/fusioninventory-agent/releases"

; Strawberry Perl directory
!define STRAWBERRY_DIR "..\Perl\Strawberry\${STRAWBERRY_RELEASE}\${PRODUCT_PLATFORM_ARCHITECTURE}"

; FusionInventory Agent sources directory
!ifndef FIA_COMMIT
   !error "The symbol 'FIA_COMMIT' hasn't been defined!"
!endif
!define FIA_DIR "${STRAWBERRY_DIR}\cpan\sources\FusionInventory-Agent-${FIA_COMMIT}"

; Tools directories
!define 7ZIP_DIR "..\Tools\7zip\${PRODUCT_PLATFORM_ARCHITECTURE}"
!define DMIDECODE_DIR "..\Tools\dmidecode\${PLATFORM_ARCHITECTURE_32}"
!define HDPARM_DIR "..\Tools\hdparm\${PLATFORM_ARCHITECTURE_32}"
!define SED_DIR "..\Tools\sed\${PLATFORM_ARCHITECTURE_32}"
!define SETACL_DIR "..\Tools\setacl\${PRODUCT_PLATFORM_ARCHITECTURE}"


;--------------------------------
; Compiler

!addplugindir ".\Plugins"


;--------------------------------
; Installer Attributes

BrandingText "${PRODUCT_PUBLISHER}"
Caption "${PRODUCT_NAME} ${PRODUCT_VERSION} (${PRODUCT_PLATFORM_ARCHITECTURE} edition) Setup"
!if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
   InstallDir "$PROGRAMFILES32\${PRODUCT_INTERNAL_NAME}"
!else
   InstallDir "$PROGRAMFILES64\${PRODUCT_INTERNAL_NAME}"
!endif
Name "${PRODUCT_NAME} ${PRODUCT_VERSION} (${PRODUCT_PLATFORM_ARCHITECTURE} edition)"
OutFile ".\${PRODUCT_INSTALLER}"
RequestExecutionLevel admin
ShowInstDetails hide
ShowUninstDetails nevershow
XPStyle on


;--------------------------------
; Global Variables

; Product installation registry subkey
Var PRODUCT_INST_SUBKEY
Var PRODUCT_UNINST_SUBKEY

; Compatible target platform architecture
Var CompatibleTargetPlatformArchitecture

; Tasks network core code installed
Var FusionInventoryAgentTaskNetCoreInstalled


;--------------------------------
; Includes

!include LogicLib.nsh
!include MUI2.nsh
!include WordFunc.nsh
!include "${FIAI_DIR}\Include\CommandLineParser.nsh"
!include "${FIAI_DIR}\Include\CommaUStrFunc.nsh"
!include "${FIAI_DIR}\Include\INIFunc.nsh"
!include "${FIAI_DIR}\Include\LangStrings.nsh"
!include "${FIAI_DIR}\Include\MiscFunc.nsh"
!include "${FIAI_DIR}\Include\PadLock.nsh"
!include "${FIAI_DIR}\Include\RegFunc.nsh"
!include "${FIAI_DIR}\Include\Registry.nsh"
!include "${FIAI_DIR}\Include\SectionFunc.nsh"
!include "${FIAI_DIR}\Include\WinServicesFunc.nsh"
!include "${FIAI_DIR}\Include\WinTasksFunc.nsh"
!include "${FIAI_DIR}\Include\WinFirewallFunc.nsh"
!include "${FIAI_DIR}\Include\CurrentConfig.nsh"


;--------------------------------
; Modern UI 2.0 Settings

; Page header
; The icon for the installer
!define MUI_ICON "${FIAI_DIR}\Contrib\Graphics\Icons\Installer.ico"
; The icon for the uninstaller
!define MUI_UNICON "${FIAI_DIR}\Contrib\Graphics\Icons\Uninstaller.ico"
; Display an image on the header of the page
!define MUI_HEADERIMAGE
; Bitmap image to display on the header of installers pages
!define MUI_HEADERIMAGE_BITMAP  "${MUI_HEADERIMAGE_BITMAP_FILE}"
; Bitmap image to display on the header of uninstaller pages
!define MUI_HEADERIMAGE_UNBITMAP "${MUI_HEADERIMAGE_UNBITMAP_FILE}"
; Display the header image on the right side instead of the left side
!define MUI_HEADERIMAGE_RIGHT

; Installer welcome/finish page
; Bitmap for the Welcome page and the Finish page
!define MUI_WELCOMEFINISHPAGE_BITMAP "${MUI_WELCOMEFINISHPAGE_BITMAP_FILE}"

; Uninstaller welcome/finish page
; Bitmap for the Welcome page and the Finish page
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "${MUI_UNWELCOMEFINISHPAGE_BITMAP_FILE}"

; Components page
; A small description area on the bottom of the page
!define MUI_COMPONENTSPAGE_SMALLDESC

; Installer finish page
; Do not automatically jump to the finish page, to allow the user to check the install log
!define MUI_FINISHPAGE_NOAUTOCLOSE

; Uninstaller finish page
; Do not automatically jump to the finish page, to allow the user to check the uninstall log
!define MUI_UNFINISHPAGE_NOAUTOCLOSE

; Abort warning
; Show a message box with a warning when the user wants to close the installer
!define MUI_ABORTWARNING
; Set the Cancel button as the default button on the message box
!define MUI_ABORTWARNING_CANCEL_DEFAULT

; Uninstaller abort warning
; Show a message box with a warning when the user wants to close the uninstaller
!define MUI_UNABORTWARNING
; Set the Cancel button as the default button on the message box
!define MUI_UNABORTWARNING_CANCEL_DEFAULT


;--------------------------------
; Modern UI 2.0 Page Settings

; Welcome page settings
; Extra space for the title area
!define MUI_WELCOMEPAGE_TITLE_3LINES

; License page settings
; Display a checkbox the user has to check to agree with the license terms
!define MUI_LICENSEPAGE_CHECKBOX

; Finish page settings
; Extra space for the title area
!define MUI_FINISHPAGE_TITLE_3LINES
; Application which the user can select to run using a checkbox
;!define MUI_FINISHPAGE_RUN ""
; Do not check the 'Run program' checkbox by default
;!define MUI_FINISHPAGE_RUN_NOTCHECKED
; File or website which the user can select to view using a checkbox
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\docs\releases\agent-readme.txt"
; Do not check the 'Show Readme' checkbox by default
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
; Text for a link on the which the user can click to view a website or file
!define MUI_FINISHPAGE_LINK "The FusionInventory Team"
; Website or file which the user can select to view using the link
!define MUI_FINISHPAGE_LINK_LOCATION http://fusioninventory.org/


;--------------------------------
; Modern UI 2.0 Custom Fuctions

!define MUI_CUSTOMFUNCTION_ABORT UserAbort


;--------------------------------
; Custom Pages Functions

!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\AdvancedOptionsPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\DebugOptionsPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\ExecutionModePage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\HelpPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\InstallationTypePage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\HTTPServerOptionsPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\MiscelaneousOptionsPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\RemoteTargetsOptionsFirstPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\RemoteTargetsOptionsSecondPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\TargetsPage.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\WindowsTaskOptionsPage.nsh"


;--------------------------------
; Installer Pages

Page custom HelpPage_Show HelpPage_Leave ""
!define MUI_PAGE_CUSTOMFUNCTION_PRE "WelcomePage_Pre"
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE "LicensePage_Pre"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW licshow ; Tell MUI to call a function before the license page is displayed
!insertmacro MUI_PAGE_LICENSE "${FIAI_DIR}\LicenseEnglish.rtf"
Page custom InstallationTypePage_Show InstallationTypePage_Leave ""
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
Page custom TargetsPage_Show TargetsPage_Leave ""
Page custom RemoteTargetsOptionsFirstPage_Show RemoteTargetsOptionsFirstPage_Leave ""
Page custom RemoteTargetsOptionsSecondPage_Show RemoteTargetsOptionsSecondPage_Leave ""
Page custom ExecutionModePage_Show ExecutionModePage_Leave ""
Page custom HTTPServerOptionsPage_Show HTTPServerOptionsPage_Leave ""
Page custom WindowsTaskOptionsPage_Show WindowsTaskOptionsPage_Leave ""
Page custom MiscelaneousOptionsPage_Show MiscelaneousOptionsPage_Leave ""
Page custom AdvancedOptionsPage_Show AdvancedOptionsPage_Leave ""
Page custom DebugOptionsPage_Show DebugOptionsPage_Leave ""
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

Function licshow                             ; Function to be called before the license page is displayed
    ; Check it
    FindWindow $0 "#32770" "" $HWNDPARENT    ; Find the inner dialog
    GetDlgItem $0 $0 0x40A                   ; Find the checkbox control
    SendMessage $0 ${BM_SETCHECK} 1 0        ; Check the checkbox

    ; Enable button
    GetDlgItem $0 $hwndparent 1              ; Find the Install/Next button
    EnableWindow $0 1                        ; Enable the button
FunctionEnd

;--------------------------------
; Modern UI 2.0 Page Settings
;  (For Uninstaller Pages)

; Welcome page settings
; Extra space for the title area
!define MUI_WELCOMEPAGE_TITLE_3LINES

; Finish page settings
; Extra space for the title area
!define MUI_FINISHPAGE_TITLE_3LINES


;--------------------------------
; Modern UI 2.0 Custom Fuctions

!define MUI_CUSTOMFUNCTION_UNABORT un.UserAbort


;--------------------------------
; Custom Pages Functions


;--------------------------------
; Uninstaller Pages

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH


;--------------------------------
; Modern UI 2.0 Language Files
;    (After Pages Always)

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "Spanish"


;--------------------------------
; Reserve Files

!insertmacro MUI_RESERVEFILE_LANGDLL
ReserveFile "${NSISDIR}\Plugins\nsDialogs.dll"
ReserveFile ".\Plugins\EnumINI.dll"
ReserveFile ".\Plugins\GetVersion.dll"
ReserveFile ".\Plugins\registry.dll"
ReserveFile ".\Plugins\SimpleFC.dll"
ReserveFile ".\Plugins\SimpleSC.dll"
ReserveFile "${FIAI_DIR}\INI\Options.ini"
ReserveFile "${FIAI_DIR}\LicenseEnglish.rtf"
ReserveFile "${SED_DIR}\libiconv2.dll"
ReserveFile "${SED_DIR}\libintl3.dll"
ReserveFile "${SED_DIR}\regex2.dll"
ReserveFile "${SED_DIR}\sed.exe"


;--------------------------------
;Version Information

VIProductVersion "${FILE_VERSION}"

VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "Setup ${PRODUCT_NAME} for Microsoft Windows"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${PRODUCT_PUBLISHER} (${PRODUCT_WEB_SITE})"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "${PRODUCT_NAME} is distributed under GNU GPL License"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${PRODUCT_NAME} for Microsoft Windows"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${FILE_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "${PRODUCT_INTERNAL_NAME}"
;VIAddVersionKey /LANG=${LANG_ENGLISH} "OriginalFilename" ""
;VIAddVersionKey /LANG=${LANG_ENGLISH} "PrivateBuild" ""
;VIAddVersionKey /LANG=${LANG_ENGLISH} "SpecialBuild" ""

VIAddVersionKey /LANG=${LANG_FRENCH} "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=${LANG_FRENCH} "Comments" "fSetup ${PRODUCT_NAME} for Microsoft Windows"
VIAddVersionKey /LANG=${LANG_FRENCH} "CompanyName" "${PRODUCT_PUBLISHER}  (${PRODUCT_WEB_SITE})"
VIAddVersionKey /LANG=${LANG_FRENCH} "LegalTrademarks" "f${PRODUCT_NAME} is distributed under GNU GPL License"
VIAddVersionKey /LANG=${LANG_FRENCH} "LegalCopyright" "${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileDescription" "f${PRODUCT_NAME} for Microsoft Windows"
VIAddVersionKey /LANG=${LANG_FRENCH} "FileVersion" "${FILE_VERSION}"
VIAddVersionKey /LANG=${LANG_FRENCH} "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_FRENCH} "InternalName" "${PRODUCT_INTERNAL_NAME}"
;VIAddVersionKey /LANG=${LANG_FRENCH} "OriginalFilename" ""
;VIAddVersionKey /LANG=${LANG_FRENCH} "PrivateBuild" ""
;VIAddVersionKey /LANG=${LANG_FRENCH} "SpecialBuild" ""

VIAddVersionKey /LANG=${LANG_SPANISH} "ProductName" "${PRODUCT_NAME}"
VIAddVersionKey /LANG=${LANG_SPANISH} "Comments" "Instalador de ${PRODUCT_NAME} para Microsoft Windows"
VIAddVersionKey /LANG=${LANG_SPANISH} "CompanyName" "${PRODUCT_PUBLISHER}  (${PRODUCT_WEB_SITE})"
VIAddVersionKey /LANG=${LANG_SPANISH} "LegalTrademarks" "${PRODUCT_NAME} es distribuido bajo licencia GNU GPL"
VIAddVersionKey /LANG=${LANG_SPANISH} "LegalCopyright" "${PRODUCT_PUBLISHER}"
VIAddVersionKey /LANG=${LANG_SPANISH} "FileDescription" "${PRODUCT_NAME} para Microsoft Windows"
VIAddVersionKey /LANG=${LANG_SPANISH} "FileVersion" "${FILE_VERSION}"
VIAddVersionKey /LANG=${LANG_SPANISH} "ProductVersion" "${PRODUCT_VERSION}"
VIAddVersionKey /LANG=${LANG_SPANISH} "InternalName" "${PRODUCT_INTERNAL_NAME}"
;VIAddVersionKey /LANG=${LANG_SPANISH} "OriginalFilename" ""
;VIAddVersionKey /LANG=${LANG_SPANISH} "PrivateBuild" ""
;VIAddVersionKey /LANG=${LANG_SPANISH} "SpecialBuild" ""


;--------------------------------
; Install Types

InstType "$(InstType_Default)"
InstType "$(InstType_Full)"
InstType "$(InstType_Minimal)"


;--------------------------------
; Installer Sections

Section "-Init" SecInit
   ; Debug
   StrCpy $0 "Init"
   DetailPrint "$(Msg_InstallingSection)"

   ${IfNot} ${Silent}
      ; Build the ${IOS_FINAL} section in the Options.ini file
      ${CopyINIOptionSection} "${IOS_GUI}" "${IOS_FINAL}"
   ${EndIf}

   ; Uninstall current agent
   ${UninstallCurrentAgent} $R0
   DetailPrint "Agent Uninstalled with Code: '$R0'"

   ; Remove firewall exceptions (be sure)
   ${RemoveFusionInventoryFirewallExceptions}

   ; Remove Windows service (be sure)
   ${RemoveFusionInventoryWindowsService}

   ; Remove Windows task (be sure)
   ${RemoveFusionInventoryWindowsTask}

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   WriteUninstaller "$R0\${PRODUCT_UNINSTALLER}"

   ; Fix the ${IO_LOGFILE} option if InstallDir is not the default
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_LOGFILE}"
   ${ReadINIOption} $R1 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
      ${WordReplace} "$R0" "$PROGRAMFILES32\${PRODUCT_INTERNAL_NAME}\" "$R1\" "+1" "$R0"
   !else
      ${WordReplace} "$R0" "$PROGRAMFILES64\${PRODUCT_INTERNAL_NAME}\" "$R1\" "+1" "$R0"
   !endif
   ${WriteINIOption} "${IOS_FINAL}" "${IO_LOGFILE}" "$R0"

   !if ${FIAI_DEBUG_LEVEL} != ${FIAI_DEBUG_LEVEL_0}
      DetailPrint "LogFile: '$R0'"
   !endif

SectionEnd

Section "-StrawberryPerl" SecStrawberryPerl
   ; Debug
   StrCpy $0 "StrawberryPerl"
   DetailPrint "$(Msg_InstallingSection)"

   ; Install Strawberry Perl
   ${InstallStrawberryPerl}
SectionEnd

Section "-FusionInventoryAgent" SecFusionInventoryAgent
   ; Debug
   StrCpy $0 "FusionInventoryAgent"
   DetailPrint "$(Msg_InstallingSection)"

   ; Install FusionInventory Agent
   ${InstallFusionInventoryAgent}
SectionEnd

SectionGroup /e "$(SectionGroup_FusionInventoryAgentTasks)" SecGrpFusionInventoryAgentTasks
   Section /o "Collect" SecCollect
      SectionIn 2

      ; Debug
      SectionGetText ${SecCollect} $0
      DetailPrint "$(Msg_InstallingSection)"

      ; Install FusionInventory Agent Task Collect
      ${InstallFusionInventoryAgentTaskCollect}
   SectionEnd

   Section /o "Deploy" SecDeploy
      SectionIn 2

      ; Debug
      SectionGetText ${SecDeploy} $0
      DetailPrint "$(Msg_InstallingSection)"

      ; Install FusionInventory Agent Task Deploy
      ${InstallFusionInventoryAgentTaskDeploy}
   SectionEnd

   Section /o "ESX" SecESX
      SectionIn 2

      ; Debug
      SectionGetText ${SecESX} $0
      DetailPrint "$(Msg_InstallingSection)"

      ; Install FusionInventory Agent Task ESX
      ${InstallFusionInventoryAgentTaskESX}
   SectionEnd

   Section "Inventory" SecInventory
      SectionIn 1 2 3 RO

      ; Debug
      SectionGetText ${SecInventory} $0
      DetailPrint "$(Msg_InstallingSection)"

      ; Install FusionInventory Agent Task Inventory
      ${InstallFusionInventoryAgentTaskInventory}
   SectionEnd

   Section /o "NetDiscovery" SecNetDiscovery
      SectionIn 2

      ; Debug
      SectionGetText ${SecNetDiscovery} $0
      DetailPrint "$(Msg_InstallingSection)"

      ; Install FusionInventory Agent Task NetDiscovery
      ${InstallFusionInventoryAgentTaskNetDiscovery}
   SectionEnd

   Section /o "NetInventory" SecNetInventory
      SectionIn 2

      ; Debug
      SectionGetText ${SecNetInventory} $0
      DetailPrint "$(Msg_InstallingSection)"

      ; Install FusionInventory Agent Task NetInventory
      ${InstallFusionInventoryAgentTaskNetInventory}
   SectionEnd

   Section /o "WakeOnLan" SecWakeOnLan
      SectionIn 2

      ; Debug
      SectionGetText ${SecWakeOnLan} $0
      DetailPrint "$(Msg_InstallingSection)"

      ; Install FusionInventory Agent Task WakeOnLan
      ${InstallFusionInventoryAgentTaskWakeOnLan}
   SectionEnd
SectionGroupEnd

Section "-End" SecEnd
   ; Debug
   StrCpy $0 "End"
   DetailPrint "$(Msg_InstallingSection)"

   ; AddUninstallInformation
   ${AddUninstallInformation}

   ; WriteConfigurationOptions
   ${WriteConfigurationOptions}

   ; Install Windows service
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_EXECMODE}"
   ${If} "$R0" == "${EXECMODE_SERVICE}"
      ${InstallFusionInventoryWindowsService}
   ${EndIf}

   ; Install Windows task
   ${If} "$R0" == "${EXECMODE_TASK}"
      ${AddFusionInventoryWindowsTask}
   ${EndIf}

   ; Install Start Menu folder
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_NO-START-MENU}"
   ${If} $R0 = 0
      ${InstallStartMenuFolder}
   ${EndIf}

   ; Add Firewall exceptions
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_ADD-FIREWALL-EXCEPTION}"
   ${If} $R0 = 1
      ${AddFusionInventoryFirewallException}
   ${EndIf}
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
   !insertmacro MUI_DESCRIPTION_TEXT ${SecCollect} "$(SecCollect_Description)"
   !insertmacro MUI_DESCRIPTION_TEXT ${SecDeploy} "$(SecDeploy_Description)"
   !insertmacro MUI_DESCRIPTION_TEXT ${SecESX} "$(SecESX_Description)"
   !insertmacro MUI_DESCRIPTION_TEXT ${SecInventory} "$(SecInventory_Description)"
   !insertmacro MUI_DESCRIPTION_TEXT ${SecNetDiscovery} "$(SecNetDiscovery_Description)"
   !insertmacro MUI_DESCRIPTION_TEXT ${SecNetInventory} "$(SecNetInventory_Description)"
   !insertmacro MUI_DESCRIPTION_TEXT ${SecWakeOnLan} "$(SecWakeOnLan_Description)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END


;--------------------------------
; Uninstall Types


;--------------------------------
; Uninstaller Sections

Section "-un.Init"
   ReadRegStr $R0 "${PRODUCT_UNINST_ROOT_KEY}" "$PRODUCT_UNINST_SUBKEY" "InstallLocation"

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Delete Start Menu folder
   SetShellVarContext all
   RMDir /r "$SMPROGRAMS\${PRODUCT_NAME}"

   ; Remove firewall exceptions
   ${RemoveFusionInventoryFirewallExceptions}

   ; Remove Windows service
   ${RemoveFusionInventoryWindowsService}

   ; Remove Windows task
   ${RemoveFusionInventoryWindowsTask}

   ; Delete file $R0\fusioninventory-*.bat
   Delete "$R0\fusioninventory-*.bat"

   ; Delete logfile
   ReadRegStr $R1 "${PRODUCT_INST_ROOT_KEY}" "$PRODUCT_INST_SUBKEY" "${IO_LOGFILE}"
   Delete "$R1"

   ; Delete file $R0\${PRODUCT_UNINSTALLER}
   Delete "$R0\${PRODUCT_UNINSTALLER}"

   ; Delete directory $R0\certs (whether is empty)
   RMDir "$R0\certs"

   !if ${FIAI_DEBUG_LEVEL} != ${FIAI_DEBUG_LEVEL_0}
      ; Delete directory $R0\debug
      RMDir /r "$R0\debug"
   !endif

   ; Delete directory $R0\docs
   RMDir /r "$R0\docs"

   ; Delete directory $R0\etc
   RMDir /r "$R0\etc"

   ; Delete directory $R0\logs
   RMDir /r "$R0\logs"

   ; Delete directory $R0\perl
   RMDir /r "$R0\perl"

   ; Delete directory $R0\share
   RMDir /r "$R0\share"

   ; Delete directory $R0\var
   RMDir /r "$R0\var"

   ; Delete directory $R0 (whether is empty)
   RMDir "$R0"

   ; un.EraseConfigurationOptions
   ${un.EraseConfigurationOptions}

   ; un.EraseUninstallInformation
   ${un.EraseUninstallInformation}
SectionEnd


;--------------------------------
; Callback Installer Functions

Function .onInit
   ; Push $R0 onto the stack
   Push $R0

   ; ClosePadLock
   ${ClosePadLock}

   ; Set default language
   ;StrCpy $LANGUAGE ${LANG_ENGLISH}
   ;StrCpy $LANGUAGE ${LANG_FRENCH}
   ;StrCpy $LANGUAGE ${LANG_SPANISH}

   ; Language selection dialog
   ;!define MUI_LANGDLL_ALWAYSSHOW
   !insertmacro MUI_LANGDLL_DISPLAY

   ; Initializes the plugins directory
   InitPluginsDir

   ; Extract file Options.ini
   SetOutPath "$PLUGINSDIR"
   File "${FIAI_DIR}\INI\Options.ini"

   ; Extract files ${SED_DIR}\libiconv2.dll
   ;               ${SED_DIR}\libintl3.dll
   ;               ${SED_DIR}\regex2.dll
   ;               ${SED_DIR}\sed.exe
   SetOutPath "$PLUGINSDIR"
   File "${SED_DIR}\libiconv2.dll"
   File "${SED_DIR}\libintl3.dll"
   File "${SED_DIR}\regex2.dll"
   File "${SED_DIR}\sed.exe"

   ; Set current install type
   SetCurInstType 0

   ; Set sections number
   ${SetSectionsNumber} ${SecEnd}

   ; Initialize default options
   ${InitINIOptionSectionDefault}

   ; Initialize global variables
   ${InitGlobalVariables}

   ; Check for compatible target platform architecture
   ${IfNot} $CompatibleTargetPlatformArchitecture = 0
      ; Platform 32bits / Installer 64bits !!!
      MessageBox MB_OK|MB_ICONSTOP "$(Msg_IncompatibleTargetPlatformArchitecture)" /SD IDOK
      Abort
   ${EndIf}

   ; GetCommandLineOptions
   ${GetCommandLineOptions}

   ; Check for silent installation mode
   ${If} ${Silent}
      ; Silent installation mode

      ; Check for command line syntax error
      ${IfNot} ${CommandLineSyntaxError}
         ; Check for help
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_HELP}"
         ${If} $R0 = 1
            ; Display help and exit
            Call ShowHelpFile
            ${PrepareToExit}
            Abort
         ${Else}
            Call .onInitSilentMode
         ${EndIf}
      ${Else}
         MessageBox MB_OK|MB_ICONSTOP "Command line error: $LastCommandLineError"
         Abort
      ${EndIf}
   ${Else}
      ; Visual installation mode

      ; Check for command line syntax error
      ${IfNot} ${CommandLineSyntaxError}
         Call .onInitVisualMode
      ${Else}
         MessageBox MB_OK|MB_ICONSTOP "Command line error: $LastCommandLineError"
      ${EndIf}
   ${EndIf}

   ; Pop $R0 off of the stack
   Pop $R0
FunctionEnd


Function .onInstSuccess
   !if ${FIAI_DEBUG_LEVEL} != ${FIAI_DEBUG_LEVEL_0}
      ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
      CreateDirectory "$R0\debug\"
      CopyFiles "${INI_OPTIONS_FILE}" "$R0\debug\"
      CopyFiles "$PLUGINSDIR\CommandLineParser.log" "$R0\debug\"
   !endif

   ; Check runnow option
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_RUNNOW}"
   ${If} $R0 = 1
      ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
      ExecShell "" '"$R0\fusioninventory-agent.bat"' '--wait=5 --delaytime=10' SW_HIDE
   ${EndIf}

   ; Prepare to exit
   ${PrepareToExit}
FunctionEnd


Function .onInstFailed
   !if ${FIAI_DEBUG_LEVEL} != ${FIAI_DEBUG_LEVEL_0}
      ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
      CreateDirectory "$R0\debug\"
      CopyFiles "${INI_OPTIONS_FILE}" "$R0\debug\"
      CopyFiles "$PLUGINSDIR\CommandLineParser.log" "$R0\debug\"
   !endif

   ; Prepare to exit
   ${PrepareToExit}
FunctionEnd


Function UserAbort
   ; Prepare to exit
   ${PrepareToExit}
FunctionEnd


;--------------------------------
; Page Callback Installer Functions

Function LicensePage_Pre
   ; Pushes $R0 onto the stack
   Push $R0

   ${ReadINIOption} $R0 "${IOS_GUI}" "${IO_ACCEPTLICENSE}"
   ${If} "$R0" == "1"
      ; The license has been accepted previously by the client.
      ; Skip this page
      Pop $R0
      Abort
   ${EndIf}

   ; Pop $R0 off of the stack
   Pop $R0
FunctionEnd


Function WelcomePage_Pre
   ; Push $R0 onto the stack
   Push $R0

   ; Hide and disable the button 'Back'
   GetDlgItem $R0 $HWNDParent 3
   ShowWindow $R0 ${SW_HIDE}
   EnableWindow $R0 0

   ; Pop $R0 off of the stack
   Pop $R0
FunctionEnd


;--------------------------------
; Callback Uninstaller Functions

Function un.onInit
   ; ClosePadLock
   ${un.ClosePadLock}

   ; Set default language
   ;StrCpy $LANGUAGE ${LANG_ENGLISH}
   ;StrCpy $LANGUAGE ${LANG_FRENCH}
   ;StrCpy $LANGUAGE ${LANG_SPANISH}

   ; Language selection dialog
   ;!define MUI_LANGDLL_ALWAYSSHOW
   !insertmacro MUI_LANGDLL_DISPLAY

   ;; Initializes the plugins directory
   ;InitPluginsDir

   ;; Extract file Options.ini
   ;SetOutPath "$PLUGINSDIR"
   ;File "${FIAI_DIR}\INI\Options.ini"

   ; Initialize global variables
   ${un.InitGlobalVariables}
FunctionEnd


Function un.onUninstFailed
   ; Prepare to exit
   ${PrepareToExit}
FunctionEnd


Function un.onUninstSuccess
   ; Prepare to exit
   ${PrepareToExit}
FunctionEnd


Function un.UserAbort
   ; Prepare to exit
   ${PrepareToExit}
FunctionEnd


;--------------------------------
; Page Callback Uninstaller Functions


;--------------------------------
; Functions

Function .onInitSilentMode
   ; Push $R0 & $R1 onto the stack
   Push $R0
   Push $R1

   ; Has the user accepted the license?
   ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_ACCEPTLICENSE}"
   ${If} $R0 = 0
   ${OrIf} "$R0" == ""
      ; He must accept the license in silent mode
      Abort
   ${EndIf}

   ; Is FusionInventory Agent installed?
   ${If} ${FusionInventoryAgentIsInstalled}
      ; The agent is already installed

      ; What type of installation is requested?
      ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_INSTALLTYPE}"

      ${If} "$R0" == "${INSTALLTYPE_FROMSCRATCH}"
         ; Install the agent from scratch

         ; Build the ${IOS_FINAL} section in the Options.ini file
         ${CopyINIOptionSection} "${IOS_DEFAULT}" "${IOS_FINAL}"
         ${UpdateINIOptionSection} "${IOS_FINAL}" "${IOS_COMMANDLINE}"

         ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_EXECMODE}"
         ${If} "$R0" == "${EXECMODE_CURRENT}"
            ${WriteINIOption} "${IOS_FINAL}" "${IO_EXECMODE}" "${EXECMODE_SERVICE}"
            ${WriteINIOption} "${IOS_FINAL}" "${IO_SERVICE-START-TYPE}" "${SERVICE_STARTTYPE_AUTO}"
            ${WriteINIOption} "${IOS_FINAL}" "${IO_SERVICE-STATUS}" "${SERVICE_STATUS_RUNNING}"
         ${EndIf}

         ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLTASKS}"
         ${Select} "$R0"
            ${Case} "${INSTALLTASK_MINIMAL}"
               ; Install the minimal tasks.
               ${GetInstallTasksMinimalCommaUStr} $R0
            ${Case} "${INSTALLTASK_DEFAULT}"
               ; Install default tasks.
               ${GetInstallTasksDefaultCommaUStr} $R0
            ${Case} "${INSTALLTASK_FULL}"
               ; Install all tasks.
               ${GetInstallTasksFullCommaUStr} $R0
         ${EndSelect}
         ${GetInstallTasksMinimalCommaUStr} $R1
         ${AddCommaStrCommaUStr} "$R0" "$R1" $R0
         ${If} "${TASK_NETDISCOVERY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETINVENTORY}" $R0
         ${EndIf}
         ${If} "${TASK_NETINVENTORY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETDISCOVERY}" $R0
         ${EndIf}
         ${WriteINIOption} "${IOS_FINAL}" "${IO_INSTALLTASKS}" "$R0"

         ; Normalize options
         ${NormalizeOptions} "${IOS_FINAL}"

         ; Synchronize NSIS sections with 'installtasks' option
         Push "${IOS_FINAL}"
         Call SyncNSISSectionsWithInstallTasksOption
      ${Else}
         ; Install the agent from current configuration

         ; Build the ${IOS_FINAL} section in the Options.ini file
         ${InitINIOptionSectionCurrentConfig}
         ${CopyINIOptionSection} "${IOS_DEFAULT}" "${IOS_FINAL}"
         ${UpdateINIOptionSection} "${IOS_FINAL}" "${IOS_CURRENTCONFIG}"
         ${UpdateINIOptionSection} "${IOS_FINAL}" "${IOS_COMMANDLINE}"

         ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLTASKS}"
         ${Select} "$R0"
            ${Case} "${INSTALLTASK_MINIMAL}"
               ; Install the minimal tasks.
               ${GetInstallTasksMinimalCommaUStr} $R0
            ${Case} "${INSTALLTASK_DEFAULT}"
               ; Install default tasks.
               ${GetInstallTasksDefaultCommaUStr} $R0
            ${Case} "${INSTALLTASK_FULL}"
               ; Install all tasks.
               ${GetInstallTasksFullCommaUStr} $R0
         ${EndSelect}
         ${GetInstallTasksMinimalCommaUStr} $R1
         ${AddCommaStrCommaUStr} "$R0" "$R1" $R0
         ${If} "${TASK_NETDISCOVERY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETINVENTORY}" $R0
         ${EndIf}
         ${If} "${TASK_NETINVENTORY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETDISCOVERY}" $R0
         ${EndIf}
         ${WriteINIOption} "${IOS_FINAL}" "${IO_INSTALLTASKS}" "$R0"

         ; Normalize options
         ${NormalizeOptions} "${IOS_FINAL}"

         ; Synchronize NSIS sections with 'installtasks' option
         Push "${IOS_FINAL}"
         Call SyncNSISSectionsWithInstallTasksOption

         ; Some options could have been overwritten. Fixing them...

         ; Fixing the ${IO_CA-CERT-DIR} option
         ;    With sense in Windows platform x64 architecture when you
         ;    swap the x86 package by the x64 package, or vice versa
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_CA-CERT-DIR}"
         ${If} "$R0" == ""
            ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_CA-CERT-DIR}"
            !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
               ${WordReplace} "$R0" "$PROGRAMFILES64\" "$PROGRAMFILES32\" "+1" "$R0"
            !else
               ${WordReplace} "$R0" "$PROGRAMFILES32\" "$PROGRAMFILES64\" "+1" "$R0"
            !endif
            ${WriteINIOption} "${IOS_FINAL}" "${IO_CA-CERT-DIR}" "$R0"
         ${EndIf}

         ; Fixing the ${IO_CA-CERT-FILE} option
         ;    With sense in Windows platform x64 architecture when you
         ;    swap the x86 package by the x64 package, or vice versa
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_CA-CERT-FILE}"
         ${If} "$R0" == ""
            ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_CA-CERT-FILE}"
            !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
               ${WordReplace} "$R0" "$PROGRAMFILES64\" "$PROGRAMFILES32\" "+1" "$R0"
            !else
               ${WordReplace} "$R0" "$PROGRAMFILES32\" "$PROGRAMFILES64\" "+1" "$R0"
            !endif
            ${WriteINIOption} "${IOS_FINAL}" "${IO_CA-CERT-FILE}" "$R0"
         ${EndIf}

         ; Fixing the ${IO_EXECMODE} option
         ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_EXECMODE}"
         ${If} "$R0" == "${EXECMODE_CURRENT}"
            ${ReadINIOption} $R0 "${IOS_CURRENTCONFIG}" "${IO_EXECMODE}"
            ${WriteINIOption} "${IOS_FINAL}" "${IO_EXECMODE}" "$R0"
         ${EndIf}

         ; Fixing the ${IO_SERVICE-START-TYPE} and ${IO_SERVICE-STATUS} options
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_EXECMODE}"
         ${If} "$R0" == "${EXECMODE_SERVICE}"
            ${WriteINIOption} "${IOS_FINAL}" "${IO_SERVICE-START-TYPE}" "${SERVICE_STARTTYPE_AUTO}"
            ${WriteINIOption} "${IOS_FINAL}" "${IO_SERVICE-STATUS}" "${SERVICE_STATUS_RUNNING}"
         ${EndIf}

         ; Fixing the ${IO_LOGFILE} option
         ;    With sense in Windows platform x64 architecture when you
         ;    swap the x86 package by the x64 package, or vice versa
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_LOGFILE}"
         ${If} "$R0" == ""
            ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_LOGFILE}"
            !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
               ${WordReplace} "$R0" "$PROGRAMFILES64\" "$PROGRAMFILES32\" "+1" "$R0"
            !else
               ${WordReplace} "$R0" "$PROGRAMFILES32\" "$PROGRAMFILES64\" "+1" "$R0"
            !endif
            ${WriteINIOption} "${IOS_FINAL}" "${IO_LOGFILE}" "$R0"
         ${EndIf}
      ${EndIf}
   ${Else}
      ; The agent is not installed yet

      ; Build the ${IOS_FINAL} section in the Options.ini file
      ${CopyINIOptionSection} "${IOS_DEFAULT}" "${IOS_FINAL}"
      ${UpdateINIOptionSection} "${IOS_FINAL}" "${IOS_COMMANDLINE}"
      ${WriteINIOption} "${IOS_FINAL}" "${IO_INSTALLTYPE}" "${INSTALLTYPE_FROMSCRATCH}"

      ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_EXECMODE}"
      ${If} "$R0" == "${EXECMODE_CURRENT}"
         ${WriteINIOption} "${IOS_FINAL}" "${IO_EXECMODE}" "${EXECMODE_SERVICE}"
         ${WriteINIOption} "${IOS_FINAL}" "${IO_SERVICE-START-TYPE}" "${SERVICE_STARTTYPE_AUTO}"
         ${WriteINIOption} "${IOS_FINAL}" "${IO_SERVICE-STATUS}" "${SERVICE_STATUS_RUNNING}"
      ${EndIf}

      ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLTASKS}"
      ${Select} "$R0"
         ${Case} "${INSTALLTASK_MINIMAL}"
            ; Install the minimal tasks.
            ${GetInstallTasksMinimalCommaUStr} $R0
         ${Case} "${INSTALLTASK_DEFAULT}"
            ; Install default tasks.
            ${GetInstallTasksDefaultCommaUStr} $R0
         ${Case} "${INSTALLTASK_FULL}"
            ; Install all tasks.
            ${GetInstallTasksFullCommaUStr} $R0
      ${EndSelect}
      ${GetInstallTasksMinimalCommaUStr} $R1
      ${AddCommaStrCommaUStr} "$R0" "$R1" $R0
      ${If} "${TASK_NETDISCOVERY}" IsInCommaUStr "$R0"
         ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
         ${AddStrCommaUStr} "$R0" "${TASK_NETINVENTORY}" $R0
      ${EndIf}
      ${If} "${TASK_NETINVENTORY}" IsInCommaUStr "$R0"
         ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
         ${AddStrCommaUStr} "$R0" "${TASK_NETDISCOVERY}" $R0
      ${EndIf}
      ${WriteINIOption} "${IOS_FINAL}" "${IO_INSTALLTASKS}" "$R0"

      ; Normalize options
      ${NormalizeOptions} "${IOS_FINAL}"

      ; Synchronize NSIS sections with 'installtasks' option
      Push "${IOS_FINAL}"
      Call SyncNSISSectionsWithInstallTasksOption
   ${EndIf}

   ; Pop $R1 & $R0 off of the stack
   Pop $R1
   Pop $R0
FunctionEnd


Function .onInitVisualMode
   ; Push $R0 & $R1 onto the stack
   Push $R0
   Push $R1

   ; Is FusionInventory Agent installed?
   ${If} ${FusionInventoryAgentIsInstalled}
      ; The agent is already installed

      ; Note: Whether you change this block of code, please, remember also to do the necessary changes
      ;       into function InstallationTypePage_Leave in ${FIAI_DIR}\Contrib\ModernUI2\Pages\InstallationTypePage.nsh

      ; What type of installation is requested?
      ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_INSTALLTYPE}"

      ${If} "$R0" == "${INSTALLTYPE_FROMSCRATCH}"
         ; Install the agent from scratch

         ; Build the ${IOS_DEFAULTGUI} section in the Options.ini file
         ${CopyINIOptionSection} "${IOS_DEFAULT}" "${IOS_DEFAULTGUI}"
         ${UpdateINIOptionSection} "${IOS_DEFAULTGUI}" "${IOS_COMMANDLINE}"

         ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_EXECMODE}"
         ${If} "$R0" == "${EXECMODE_CURRENT}"
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_EXECMODE}" "${EXECMODE_SERVICE}"
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_SERVICE-START-TYPE}" "${SERVICE_STARTTYPE_AUTO}"
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_SERVICE-STATUS}" "${SERVICE_STATUS_RUNNING}"
         ${EndIf}

         ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_INSTALLTASKS}"
         ${Select} "$R0"
            ${Case} "${INSTALLTASK_MINIMAL}"
               ; Install the minimal tasks.
               ${GetInstallTasksMinimalCommaUStr} $R0
            ${Case} "${INSTALLTASK_DEFAULT}"
               ; Install default tasks.
               ${GetInstallTasksDefaultCommaUStr} $R0
            ${Case} "${INSTALLTASK_FULL}"
               ; Install all tasks.
               ${GetInstallTasksFullCommaUStr} $R0
         ${EndSelect}
         ${GetInstallTasksMinimalCommaUStr} $R1
         ${AddCommaStrCommaUStr} "$R0" "$R1" $R0
         ${If} "${TASK_NETDISCOVERY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETINVENTORY}" $R0
         ${EndIf}
         ${If} "${TASK_NETINVENTORY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETDISCOVERY}" $R0
         ${EndIf}
         ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_INSTALLTASKS}" "$R0"

         ; Normalize options
         ${NormalizeOptions} "${IOS_DEFAULTGUI}"

         ; Synchronize NSIS sections with 'installtasks' option
         Push "${IOS_DEFAULTGUI}"
         Call SyncNSISSectionsWithInstallTasksOption

         ; Unset "quick install" when installing from scratch
         ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_QUICK-INSTALL}" "0"
      ${Else}
         ; Install the agent from current configuration

         ; Build the ${IOS_DEFAULTGUI} section in the Options.ini file
         ${InitINIOptionSectionCurrentConfig}
         ${CopyINIOptionSection} "${IOS_DEFAULT}" "${IOS_DEFAULTGUI}"
         ${UpdateINIOptionSection} "${IOS_DEFAULTGUI}" "${IOS_CURRENTCONFIG}"
         ${UpdateINIOptionSection} "${IOS_DEFAULTGUI}" "${IOS_COMMANDLINE}"

         ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_INSTALLTASKS}"
         ${Select} "$R0"
            ${Case} "${INSTALLTASK_MINIMAL}"
               ; Install the minimal tasks.
               ${GetInstallTasksMinimalCommaUStr} $R0
            ${Case} "${INSTALLTASK_DEFAULT}"
               ; Install default tasks.
               ${GetInstallTasksDefaultCommaUStr} $R0
            ${Case} "${INSTALLTASK_FULL}"
               ; Install all tasks.
               ${GetInstallTasksFullCommaUStr} $R0
         ${EndSelect}
         ${GetInstallTasksMinimalCommaUStr} $R1
         ${AddCommaStrCommaUStr} "$R0" "$R1" $R0
         ${If} "${TASK_NETDISCOVERY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETINVENTORY}" $R0
         ${EndIf}
         ${If} "${TASK_NETINVENTORY}" IsInCommaUStr "$R0"
            ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
            ${AddStrCommaUStr} "$R0" "${TASK_NETDISCOVERY}" $R0
         ${EndIf}
         ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_INSTALLTASKS}" "$R0"

         ; Normalize options
         ${NormalizeOptions} "${IOS_DEFAULTGUI}"

         ; Synchronize NSIS sections with 'installtasks' option
         Push "${IOS_DEFAULTGUI}"
         Call SyncNSISSectionsWithInstallTasksOption

         ; Some options could have been overwritten. Fixing them...

         ; Fixing the ${IO_CA-CERT-DIR} option
         ;    With sense in Windows platform x64 architecture when you
         ;    swap the x86 package by the x64 package, or vice versa
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_CA-CERT-DIR}"
         ${If} "$R0" == ""
            ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_CA-CERT-DIR}"
            !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
               ${WordReplace} "$R0" "$PROGRAMFILES64\" "$PROGRAMFILES32\" "+1" "$R0"
            !else
               ${WordReplace} "$R0" "$PROGRAMFILES32\" "$PROGRAMFILES64\" "+1" "$R0"
            !endif
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_CA-CERT-DIR}" "$R0"
         ${EndIf}

         ; Fixing the ${IO_CA-CERT-FILE} option
         ;    With sense in Windows platform x64 architecture when you
         ;    swap the x86 package by the x64 package, or vice versa
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_CA-CERT-FILE}"
         ${If} "$R0" == ""
            ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_CA-CERT-FILE}"
            !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
               ${WordReplace} "$R0" "$PROGRAMFILES64\" "$PROGRAMFILES32\" "+1" "$R0"
            !else
               ${WordReplace} "$R0" "$PROGRAMFILES32\" "$PROGRAMFILES64\" "+1" "$R0"
            !endif
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_CA-CERT-FILE}" "$R0"
         ${EndIf}

         ; Fixing the ${IO_EXECMODE} option
         ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_EXECMODE}"
         ${If} "$R0" == "${EXECMODE_CURRENT}"
            ${ReadINIOption} $R0 "${IOS_CURRENTCONFIG}" "${IO_EXECMODE}"
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_EXECMODE}" "$R0"
         ${EndIf}

         ; Fixing the ${IO_SERVICE-START-TYPE} and ${IO_SERVICE-STATUS} options
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_EXECMODE}"
         ${If} "$R0" == "${EXECMODE_SERVICE}"
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_SERVICE-START-TYPE}" "${SERVICE_STARTTYPE_AUTO}"
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_SERVICE-STATUS}" "${SERVICE_STATUS_RUNNING}"
         ${EndIf}

         ; Fixing the ${IO_LOGFILE} option
         ;    With sense in Windows platform x64 architecture when you
         ;    swap the x86 package by the x64 package, or vice versa
         ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_LOGFILE}"
         ${If} "$R0" == ""
            ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_LOGFILE}"
            !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
               ${WordReplace} "$R0" "$PROGRAMFILES64\" "$PROGRAMFILES32\" "+1" "$R0"
            !else
               ${WordReplace} "$R0" "$PROGRAMFILES32\" "$PROGRAMFILES64\" "+1" "$R0"
            !endif
            ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_LOGFILE}" "$R0"
         ${EndIf}
      ${EndIf}
   ${Else}
      ; The agent is not installed yet

      ; Build the ${IOS_DEFAULTGUI} section in the Options.ini file
      ${CopyINIOptionSection} "${IOS_DEFAULT}" "${IOS_DEFAULTGUI}"
      ${UpdateINIOptionSection} "${IOS_DEFAULTGUI}" "${IOS_COMMANDLINE}"
      ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_INSTALLTYPE}" "${INSTALLTYPE_FROMSCRATCH}"

      ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_EXECMODE}"
      ${If} "$R0" == "${EXECMODE_CURRENT}"
         ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_EXECMODE}" "${EXECMODE_SERVICE}"
         ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_SERVICE-START-TYPE}" "${SERVICE_STARTTYPE_AUTO}"
         ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_SERVICE-STATUS}" "${SERVICE_STATUS_RUNNING}"
      ${EndIf}

      ${ReadINIOption} $R0 "${IOS_DEFAULTGUI}" "${IO_INSTALLTASKS}"
      ${Select} "$R0"
         ${Case} "${INSTALLTASK_MINIMAL}"
            ; Install the minimal tasks.
            ${GetInstallTasksMinimalCommaUStr} $R0
         ${Case} "${INSTALLTASK_DEFAULT}"
            ; Install default tasks.
            ${GetInstallTasksDefaultCommaUStr} $R0
         ${Case} "${INSTALLTASK_FULL}"
            ; Install all tasks.
            ${GetInstallTasksFullCommaUStr} $R0
      ${EndSelect}
      ${GetInstallTasksMinimalCommaUStr} $R1
      ${AddCommaStrCommaUStr} "$R0" "$R1" $R0
      ${If} "${TASK_NETDISCOVERY}" IsInCommaUStr "$R0"
         ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
         ${AddStrCommaUStr} "$R0" "${TASK_NETINVENTORY}" $R0
      ${EndIf}
      ${If} "${TASK_NETINVENTORY}" IsInCommaUStr "$R0"
         ; Agent tasks ${TASK_NETINVENTORY} & ${TASK_NETDISCOVERY} are inter-dependent
         ${AddStrCommaUStr} "$R0" "${TASK_NETDISCOVERY}" $R0
      ${EndIf}
      ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_INSTALLTASKS}" "$R0"

      ; Normalize options
      ${NormalizeOptions} "${IOS_DEFAULTGUI}"

      ; Synchronize NSIS sections with 'installtasks' option
      Push "${IOS_DEFAULTGUI}"
      Call SyncNSISSectionsWithInstallTasksOption

      ; Unset "quick install" when installing from scratch
      ${WriteINIOption} "${IOS_DEFAULTGUI}" "${IO_QUICK-INSTALL}" "0"
   ${EndIf}

   ; Build the ${IOS_GUI} section in the Options.ini file
   ${CopyINIOptionSection} "${IOS_DEFAULTGUI}" "${IOS_GUI}"

   ; Pop $R1 & $R0 off of the stack
   Pop $R1
   Pop $R0
FunctionEnd


Function .onSelChange
   ; $R0 Saved selected flags of sections
   ; $R1 Current selected flags of sections
   ; $R2 Number of sections
   ; $R3 Sections changed ($R0 xor $R1)
   ; $R4 Sections iterator
   ; $R5 Auxiliary
   ; $R6 Agent tasks to install

   ; Push $R0, $R1, $R2, $R3, $R4, $R5 & $R6 onto the stack
   Push $R0
   Push $R1
   Push $R2
   Push $R3
   Push $R4
   Push $R5
   Push $R6

   ; Get the current install type
   GetCurInstType $R5
   ${If} $R5 <> ${NSIS_MAX_INST_TYPES}
      ; A pre-defined install type has been selected.
      ; It is assumed that the pre-defined install types
      ; are correctly defined. Nothing to do.
      Nop
   ${Else}
      ; A custom set of sections has been selected.
      ; Only one section has changed. Which one?

      ; Get saved selected flags of sections
      ${GetSavedSelectedFlagsOfSections} $R0

      ; Get current selected flags of sections
      ${GetCurrentSelectedFlagsOfSections} $R1

      ; Get number of sections
      ${GetSectionsNumber} $R2

      ; Operation XOR between $R0 & $R1
      IntOp $R3 $R0 ^ $R1

      ; Search for the section changed
      ${For} $R4 0 $R2
         IntOp $R5 $R3 & 0x1
         ${If} $R5 = 1
            ; Section $R4 has changed
            ${ExitFor}
         ${Else}
            IntOp $R1 $R1 >> 1
            IntOp $R3 $R3 >> 1
         ${EndIf}
      ${Next}

      ; According to the section changed
      ${Select} $R4
         ${Case} ${SecNetDiscovery}
            ; Sections ${SecNetDiscovery} & ${SecNetInventory} are inter-dependent
            IntOp $R5 $R1 & 0x1
            ${If} $R5 = 1
               ; The section has been selected
               ${SelectSection} ${SecNetInventory}
            ${Else}
               ; The section has been unselected
               ${UnselectSection} ${SecNetInventory}
            ${EndIf}

         ${Case} ${SecNetInventory}
            ; Sections ${SecNetDiscovery} & ${SecNetInventory} are inter-dependent
            IntOp $R5 $R1 & 0x1
            ${If} $R5 = 1
               ; The section has been selected
               ${SelectSection} ${SecNetDiscovery}
            ${Else}
               ; The section has been unselected
               ${UnselectSection} ${SecNetDiscovery}
            ${EndIf}

         ${CaseElse}
            Nop
      ${EndSelect}
   ${EndIf}

   ; Save the current selected flags of sections
   ${SaveCurrentSelectedFlagsOfSections}

   ; Initialize $R6
   StrCpy $R6 ""

   ; Synchronization loop for agent tasks to install...
   ${For} $R4 0 $R2
      ${If} ${SectionIsSelected} $R4
         ; The section $R4 is selected
         ; According to $R4...
         ${Select} $R4
            ${Case} ${SecCollect}
               ; Section ${SecCollect} selected
               ${AddStrCommaUStr} "$R6" "${TASK_COLLECT}" $R6
            ${Case} ${SecDeploy}
               ; Section ${SecDeploy} selected
               ${AddStrCommaUStr} "$R6" "${TASK_DEPLOY}" $R6
            ${Case} ${SecESX}
               ; Section ${SecESX} selected
               ${AddStrCommaUStr} "$R6" "${TASK_ESX}" $R6
            ${Case} ${SecInventory}
               ; Section ${SecInventory} selected
               ${AddStrCommaUStr} "$R6" "${TASK_INVENTORY}" $R6
            ${Case} ${SecNetDiscovery}
               ; Section ${SetNetDiscovery} selected
               ${AddStrCommaUStr} "$R6" "${TASK_NETDISCOVERY}" $R6
            ${Case} ${SecNetInventory}
               ; Section ${SecNetInventory} selected
               ${AddStrCommaUStr} "$R6" "${TASK_NETINVENTORY}" $R6
            ${Case} ${SecWakeOnLan}
               ; Section ${SecWakeOnLan} selected
               ${AddStrCommaUStr} "$R6" "${TASK_WAKEONLAN}" $R6
         ${EndSelect}
      ${EndIf}
   ${Next}

   ; Update ${IO_INSTALLTASKS} option
   ${WriteINIOption} "${IOS_GUI}" "${IO_INSTALLTASKS}" "$R6"

   ; Normalize options
   ${NormalizeOptions} "${IOS_GUI}"

   ; Pop $R6, $R5, $R4, $R3, $R2, $R1 & $R0 off of the stack
   Pop $R6
   Pop $R5
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


Function .onVerifyInstDir

   ; Just save set $INSTDIR ${IO_INSTALLDIR} option in ${IOS_GUI}
   ${WriteINIOption} "${IOS_GUI}" "${IO_INSTALLDIR}" "$INSTDIR"

FunctionEnd


; SyncNSISSectionsWithInstallTasksOption
Function SyncNSISSectionsWithInstallTasksOption
   ; $R0 INISection
   ; $R1 Agent tasks to install
   ; $R2 Auxiliary

   ; Get parameter
   Exch $R0

   ; Push $R1 & $R2 onto the stack
   Push $R1
   Push $R2

   ; Unselect all sections
   ${UnselectAllSections}

   ; Get agent tasks to install
   ${ReadINIOption} $R1 "$R0" "${IO_INSTALLTASKS}"

   ; Synchronization loop
   ${Do}
      ; Get the first agent task
      ${FirstStrCommaUStr} "$R1" $R2

      ; According to $R2...
      ${Select} "$R2"
         ${Case} ""
            ; There are no more agent tasks
            ${ExitDo}
         ${Case} "${TASK_COLLECT}"
            ; Select ${SecCollect} section
            ${SelectSection} ${SecCollect}
         ${Case} "${TASK_DEPLOY}"
            ; Select ${SecDeploy} section
            ${SelectSection} ${SecDeploy}
         ${Case} "${TASK_ESX}"
            ; Select ${SecESX} section
            ${SelectSection} ${SecESX}
         ${Case} "${TASK_INVENTORY}"
            ; Select ${SecInventory} section
            ${SelectSection} ${SecInventory}
         ${Case} "${TASK_NETDISCOVERY}"
            ; Select ${SecNetDiscovery} section
            ${SelectSection} ${SecNetDiscovery}
         ${Case} "${TASK_NETINVENTORY}"
            ; Select ${SecNetInventory} section
            ${SelectSection} ${SecNetInventory}
         ${Case} "${TASK_WAKEONLAN}"
            ; Select ${SecWakeOnLan} section
            ${SelectSection} ${SecWakeOnLan}
      ${EndSelect}

      ; Get the next agent task to install
      ${DelStrCommaUStr} "$R1" "$R2" $R1
   ${Loop}

   ; Save the current selected flags of sections
   ${SaveCurrentSelectedFlagsOfSections}

   ; Pop $R2, $R1 & $R0 off of the stack
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd
