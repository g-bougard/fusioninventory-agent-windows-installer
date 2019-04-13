/*
   ------------------------------------------------------------------------
   FusionInventory Agent Installer for Microsoft Windows
   Copyright (C) 2010-2017 by the FusionInventory Development Team.

   http://www.fusioninventory.org/ http://forge.fusioninventory.org/
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
   @file      .\FusionInventory Agent\Include\MiscFunc.nsh
   @author    Tomas Abad <tabadgp@gmail.com>
   @copyright Copyright (c) 2010-2017 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      https://github.com/fusioninventory/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_MISCFUNC_INCLUDE__
!define __FIAI_MISCFUNC_INCLUDE__


!include FileFunc.nsh
!include WordFunc.nsh
!include "${FIAI_DIR}\Include\CommaUStrFunc.nsh"
!include "${FIAI_DIR}\Include\INIFunc.nsh"
!include "${FIAI_DIR}\Include\FileFunc.nsh"
!include "${FIAI_DIR}\Include\RegFunc.nsh"
!include "${FIAI_DIR}\Include\StrFunc.nsh"
!include "${FIAI_DIR}\Include\WindowsInfo.nsh"
!include "${FIAI_DIR}\Include\WinServicesFunc.nsh"
!include "${FIAI_DIR}\Include\WinTasksFunc.nsh"


; InitGlobalVariables
!macro InitGlobalVariables Un
   Function "${Un}InitGlobalVariables"
      ; Push $R0 onto the stack
      Push $R0

      ; Set compatible target platform architecture
      StrCpy $CompatibleTargetPlatformArchitecture 0

      ; Set tasks network core code installed
      StrCpy $FusionInventoryAgentTaskNetCoreInstalled 1

      ; Get Windows platform architecture
      ${GetWindowsPlatformArchitecture} $R0

      ; Set product installation registry subkey
      ${If} $R0 = 32
         ; Platform 32bits
         StrCpy $PRODUCT_INST_SUBKEY "SOFTWARE\${PRODUCT_INTERNAL_NAME}"
         StrCpy $PRODUCT_UNINST_SUBKEY "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_INTERNAL_NAME}"

         ${If} ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_64}
            ; Platform 32bits / Installer 64bits !!!
            StrCpy $CompatibleTargetPlatformArchitecture 1
         ${EndIf}

         ; Set scope of the registry commands
         SetRegView 32
      ${Else}
         ; Platform 64bits
         ${If} ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
            ; Platform 64bits / Installer 32bits
            StrCpy $PRODUCT_INST_SUBKEY "SOFTWARE\Wow6432Node\${PRODUCT_INTERNAL_NAME}"
            StrCpy $PRODUCT_UNINST_SUBKEY "SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_INTERNAL_NAME}"
         ${Else}
            ; Platform 64bits / Installer 64bits
            StrCpy $PRODUCT_INST_SUBKEY "SOFTWARE\${PRODUCT_INTERNAL_NAME}"
            StrCpy $PRODUCT_UNINST_SUBKEY "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_INTERNAL_NAME}"
         ${EndIf}

         ; Set scope of the registry commands
         SetRegView 64
      ${EndIf}

      ; Pop $R0 off of the stack
      Pop $R0
   FunctionEnd
!macroend

!insertmacro InitGlobalVariables ""
!insertmacro InitGlobalVariables "un."

!define InitGlobalVariables "Call InitGlobalVariables"
!define un.InitGlobalVariables "Call un.InitGlobalVariables"


; InstallFusionInventoryAgent
!define InstallFusionInventoryAgent "!insertmacro InstallFusionInventoryAgent"

!macro InstallFusionInventoryAgent
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\certs"
   CreateDirectory "$R0\docs"
   CreateDirectory "$R0\docs\releases"
   CreateDirectory "$R0\etc"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\HTTP"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Logger"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Target"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Daemon"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Tools"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Tools\Screen"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Tools\Standards"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Tools\Win32"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\XML"
   CreateDirectory "$R0\perl\bin"
   CreateDirectory "$R0\share"
   CreateDirectory "$R0\var"
   CreateDirectory "$R0\logs"

   ; Create $R0\fusioninventory-agent.bat
   FileOpen $R1 "$R0\fusioninventory-agent.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-agent %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Install $R0\docs\releases\agent-{changes,license,readme,thanks}.txt
   ;         $R0\docs\releades\installer-{acknowledgments,changes,contributions,license,readme}.txt
   SetOutPath "$R0\docs\releases"
   File /oname=agent-changes.txt "${FIA_DIR}\Changes"
   File /oname=agent-license.txt "${FIA_DIR}\LICENSE"
   File /oname=agent-readme.txt "${FIA_DIR}\README.md"
   File /oname=agent-readme.txt "${FIA_DIR}\CONTRIB.md"
   File /oname=agent-thanks.txt "${FIA_DIR}\THANKS"
   File /oname=installer-acknowledgments.txt "..\Acknowledgments.txt"
   File /oname=installer-changes.txt "..\Changes.txt"
   File /oname=installer-contributions.txt "..\Contributions.txt"
   File /oname=installer-license.txt "..\License.txt"
   File /oname=installer-readme.txt "..\Readme.txt"
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\agent-changes.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\agent-license.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\agent-readme.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\agent-thanks.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\installer-acknowledgments.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\installer-changes.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\installer-contributions.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\installer-license.txt"'
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s/$$/\r/" "$R0\docs\releases\installer-readme.txt"'
   Delete "$R0\docs\releases\sed*"

   ; Install $R0\etc
   SetOutPath "$R0\etc\"
   File /oname=agent.cfg.sample "${FIA_DIR}\etc\agent.cfg"
   File /oname=inventory-server-plugin.cfg "${FIA_DIR}\etc\inventory-server-plugin.cfg"
   File /oname=server-test-plugin.cfg.sample "${FIA_DIR}\etc\server-test-plugin.cfg"
   File /oname=ssl-server-plugin.cfg "${FIA_DIR}\etc\ssl-server-plugin.cfg"

   ; Install $R0\perl\agent\FusionInventory\Agent.pm
   SetOutPath "$R0\perl\agent\FusionInventory"
   File "${FIA_DIR}\lib\FusionInventory\Agent.pm"

   ; Install $R0\perl\agent\FusionInventory\Agent\*.pm
   ; but not $R0\perl\agent\FusionInventory\Agent\SNMP.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent"
   File /x "SNMP.pm"    \
        "${FIA_DIR}\lib\FusionInventory\Agent\*.pm"

   ; Fix SYSCONFDIR setup as normally done in Makefile under Unix system
   ${WordReplace} "$R0" "\" "\\" "+" $R1
   nsExec::Exec '"$PLUGINSDIR\sed.exe" -i -e "s|=> undef, # SYSCONFDIR.*|=> q/$R1\\etc/,|" "$R0\perl\agent\FusionInventory\Agent\Config.pm"'

   ; Install $R0\perl\agent\FusionInventory\Agent\HTTP\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\HTTP"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\HTTP\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Logger\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Logger"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Logger\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Target\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Target"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Target\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Daemon\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Daemon"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Daemon\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Tools\*.pm
   ; but not $R0\perl\agent\FusionInventory\Agent\Tools\Hardware.pm
   ; and not $R0\perl\agent\FusionInventory\Agent\Tools\SNMP.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Tools"
   File /x "Hardware.pm" /x "SNMP.pm" \
        "${FIA_DIR}\lib\FusionInventory\Agent\Tools\*.pm"

   ; Install $R0\perl\agent\FusionInventory\Agent\Tools\Win32\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Tools\Win32"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Tools\Win32\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Tools\Screen\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Tools\Screen"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Tools\Screen\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Tools\Standards\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Tools\Standards"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Tools\Standards\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\XML\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\XML"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\XML\*.*"

   ; Install $R0\perl\bin\7z.dll
   ;         $R0\perl\bin\7z.exe
   ;         $R0\perl\bin\dmidecode.exe
   ;         $R0\perl\bin\hdparm.exe
   ;         $R0\perl\bin\fusioninventory-agent
   ;         $R0\perl\bin\fusioninventory-win32-service
   ;         $R0\perl\bin\memconf
   SetOutPath "$R0\perl\bin\"
   File "${7ZIP_DIR}\7z.dll"
   File "${7ZIP_DIR}\7z.exe"
   File "${DMIDECODE_DIR}\dmidecode.exe"
   File "${HDPARM_DIR}\hdparm.exe"
   File "${FIA_DIR}\bin\fusioninventory-agent"
   File "${FIA_DIR}\bin\fusioninventory-win32-service"
   File "${FIA_DIR}\bin\fusioninventory-win32-service.rc.sample"

   ; Install $R0\share
   SetOutPath "$R0\share\"
   File /r "${FIA_DIR}\share\*.*"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskCollect
!define InstallFusionInventoryAgentTaskCollect "!insertmacro InstallFusionInventoryAgentTaskCollect"

!macro InstallFusionInventoryAgentTaskCollect
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\Collect"

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\Collect.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\Collect.pm"
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\Collect"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\Collect\Version.pm"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskDeploy
!define InstallFusionInventoryAgentTaskDeploy "!insertmacro InstallFusionInventoryAgentTaskDeploy"

!macro InstallFusionInventoryAgentTaskDeploy
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\Deploy"

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\Deploy.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\Deploy.pm"

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\Deploy\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\Deploy"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Task\Deploy\*.*"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskESX
!define InstallFusionInventoryAgentTaskESX "!insertmacro InstallFusionInventoryAgentTaskESX"

!macro InstallFusionInventoryAgentTaskESX
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\ESX"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\SOAP"
   CreateDirectory "$R0\perl\bin"

   ; Create $R0\fusioninventory-esx.bat
   FileOpen $R1 "$R0\fusioninventory-esx.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-esx %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Install $R0\perl\agent\FusionInventory\Agent\SOAP\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\SOAP"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\SOAP\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\ESX.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\ESX.pm"
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\ESX"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\ESX\Version.pm"

   ; Install $R0\perl\bin\fusioninventory-esx
   SetOutPath "$R0\perl\bin\"
   File "${FIA_DIR}\bin\fusioninventory-esx"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskInventory
!define InstallFusionInventoryAgentTaskInventory "!insertmacro InstallFusionInventoryAgentTaskInventory"

!macro InstallFusionInventoryAgentTaskInventory
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\Inventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\WMI"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\Maintenance"
   CreateDirectory "$R0\perl\bin"

   ; Create $R0\fusioninventory-injector.bat
   FileOpen $R1 "$R0\fusioninventory-injector.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-injector %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Create $R0\fusioninventory-inventory.bat
   FileOpen $R1 "$R0\fusioninventory-inventory.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-inventory %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Create $R0\fusioninventory-wmi.bat
   FileOpen $R1 "$R0\fusioninventory-wmi.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-wmi %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\Inventory.pm
   ;         $R0\perl\agent\FusionInventory\Agent\Task\WMI.pm
   ;         $R0\perl\agent\FusionInventory\Agent\Task\Maintenance.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\Inventory.pm"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\WMI.pm"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\Maintenance.pm"

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\Inventory\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\Inventory"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Task\Inventory\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\WMI\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\WMI"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Task\WMI\*.*"

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\Maintenance\*.*
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\Maintenance"
   File /r "${FIA_DIR}\lib\FusionInventory\Agent\Task\Maintenance\*.*"

   ; Install $R0\perl\bin\fusioninventory-injector
   ;         $R0\perl\bin\fusioninventory-inventory
   ;         $R0\perl\bin\fusioninventory-wmi
   SetOutPath "$R0\perl\bin\"
   File "${FIA_DIR}\bin\fusioninventory-injector"
   File "${FIA_DIR}\bin\fusioninventory-inventory"
   File "${FIA_DIR}\bin\fusioninventory-wmi"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskNetCore
;    Note: This is not a real FusionInventory-Agent task.
;          It is the FusionInventory-Agent shared code by
;          the NetDiscovery and NetInventory tasks.
!define InstallFusionInventoryAgentTaskNetCore "!insertmacro InstallFusionInventoryAgentTaskNetCore"

!macro InstallFusionInventoryAgentTaskNetCore
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Check whether it is already installed
   ${IfNot} $FusionInventoryAgentTaskNetCoreInstalled = 0
      ; Task network core code not installed

      ; Set tasks network core code installed
      StrCpy $FusionInventoryAgentTaskNetCoreInstalled 0

      ; Create directories
      ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
      CreateDirectory "$R0"
      CreateDirectory "$R0\perl"
      CreateDirectory "$R0\perl\agent"
      CreateDirectory "$R0\perl\agent\FusionInventory"
      CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
      CreateDirectory "$R0\perl\agent\FusionInventory\Agent\SNMP"
      CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Tools"
      CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Tools\Hardware"

      ; Install $R0\perl\agent\FusionInventory\Agent\SNMP.pm
      SetOutPath "$R0\perl\agent\FusionInventory\Agent"
      File "${FIA_DIR}\lib\FusionInventory\Agent\SNMP.pm"

      ; Install $R0\perl\agent\FusionInventory\Agent\SNMP\*.*
      SetOutPath "$R0\perl\agent\FusionInventory\Agent\SNMP"
      File /r "${FIA_DIR}\lib\FusionInventory\Agent\SNMP\*.*"

      ; Install $R0\perl\agent\FusionInventory\Agent\Tools\Hardware.pm
      ;         $R0\perl\agent\FusionInventory\Agent\Tools\SNMP.pm
      SetOutPath "$R0\perl\agent\FusionInventory\Agent\Tools"
      File "${FIA_DIR}\lib\FusionInventory\Agent\Tools\Hardware.pm"
      File "${FIA_DIR}\lib\FusionInventory\Agent\Tools\SNMP.pm"

      ; Install $R0\perl\agent\FusionInventory\Agent\Tools\Hardware\*.*
      SetOutPath "$R0\perl\agent\FusionInventory\Agent\Tools\Hardware"
      File /r "${FIA_DIR}\lib\FusionInventory\Agent\Tools\Hardware\*.*"
   ${EndIf}

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskNetDiscovery
!define InstallFusionInventoryAgentTaskNetDiscovery "!insertmacro InstallFusionInventoryAgentTaskNetDiscovery"

!macro InstallFusionInventoryAgentTaskNetDiscovery
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Install InstallFusionInventoryAgentTaskNetCore
   ${InstallFusionInventoryAgentTaskNetCore}

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\NetDiscovery"
   CreateDirectory "$R0\perl\bin"

   ; Create $R0\fusioninventory-netdiscovery.bat
   FileOpen $R1 "$R0\fusioninventory-netdiscovery.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-netdiscovery %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\NetDiscovery.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\NetDiscovery.pm"
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\NetDiscovery"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\NetDiscovery\Version.pm"

   ; Install $R0\perl\bin\fusioninventory-netdiscovery
   SetOutPath "$R0\perl\bin\"
   File "${FIA_DIR}\bin\fusioninventory-netdiscovery"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskNetInventory
!define InstallFusionInventoryAgentTaskNetInventory "!insertmacro InstallFusionInventoryAgentTaskNetInventory"

!macro InstallFusionInventoryAgentTaskNetInventory
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Install InstallFusionInventoryAgentTaskNetCore
   ${InstallFusionInventoryAgentTaskNetCore}

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\NetInventory"
   CreateDirectory "$R0\perl\bin"

   ; Create $R0\fusioninventory-netinventory.bat
   FileOpen $R1 "$R0\fusioninventory-netinventory.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-netinventory %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\NetInventory.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\NetInventory.pm"
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\NetInventory"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\NetInventory\Version.pm"

   ; Install $R0\perl\bin\fusioninventory-netinventory
   SetOutPath "$R0\perl\bin\"
   File "${FIA_DIR}\bin\fusioninventory-netinventory"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallFusionInventoryAgentTaskWakeOnLan
!define InstallFusionInventoryAgentTaskWakeOnLan "!insertmacro InstallFusionInventoryAgentTaskWakeOnLan"

!macro InstallFusionInventoryAgentTaskWakeOnLan
   ; Push $R0 onto the stack
   Push $R0
   Push $R1

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\agent"
   CreateDirectory "$R0\perl\agent\FusionInventory"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task"
   CreateDirectory "$R0\perl\agent\FusionInventory\Agent\Task\WakeOnLan"

   ; Create $R0\fusioninventory-wakeonlan.bat
   FileOpen $R1 "$R0\fusioninventory-wakeonlan.bat" w
   ${FileWriteLine} $R1 "@echo off"
   ${FileWriteLine} $R1 "for %%p in ($\".$\") do pushd $\"%%~fsp$\""
   ${FileWriteLine} $R1 "cd /d $\"%~dp0\perl\bin$\""
   ${FileWriteLine} $R1 "perl.exe fusioninventory-wakeonlan %*"
   ${FileWriteLine} $R1 "popd"
   FileClose $R1

   ; Install $R0\perl\agent\FusionInventory\Agent\Task\WakeOnLan.pm
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\WakeOnLan.pm"
   SetOutPath "$R0\perl\agent\FusionInventory\Agent\Task\WakeOnLan"
   File "${FIA_DIR}\lib\FusionInventory\Agent\Task\WakeOnLan\Version.pm"

   ; Install $R0\perl\bin\fusioninventory-wakeonlan
   SetOutPath "$R0\perl\bin\"
   File "${FIA_DIR}\bin\fusioninventory-wakeonlan"

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; InstallStartMenuFolder
!define InstallStartMenuFolder "!insertmacro InstallStartMenuFolder"

!macro InstallStartMenuFolder
   ; Push $R0, $R1 & $R2 onto the stack
   Push $R0
   Push $R1
   Push $R2

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Set the context of $SMPROGRAMS and other shell folders
   SetShellVarContext all

   ; Create directory
   StrCpy $R0 "$SMPROGRAMS\${PRODUCT_NAME}"
   CreateDirectory "$R0"

   ; Check whether the execution mode is as a Windows service
   ${ReadINIOption} $R1 "${IOS_FINAL}" "${IO_EXECMODE}"
   ${If} "$R1" == "${EXECMODE_SERVICE}"
      ; Create $R0\${PRODUCT_NAME} Status.url
      FileOpen $R1 "$R0\${PRODUCT_NAME} Status.url" w
      ${ReadINIOption} $R2 "${IOS_FINAL}" "${IO_HTTPD-PORT}"
      ${FileWriteLine} $R1 "[DEFAULT]"
      ${FileWriteLine} $R1 "BASEURL=http://localhost:$R2/"
      ${FileWriteLine} $R1 "[{000214A0-0000-0000-C000-000000000046}]"
      ${FileWriteLine} $R1 "Prop3=19,2"
      ${FileWriteLine} $R1 "[InternetShortcut]"
      ${FileWriteLine} $R1 "URL=http://localhost:$R2/"
      ${FileWriteLine} $R1 "IDList="
      ${FileWriteLine} $R1 "IconFile=http://localhost:$R2/favicon.ico"
      ${FileWriteLine} $R1 "IconIndex=1"
      FileClose $R1
   ${EndIf}

   ; Create $R0\FusionInventory Website.url
   FileOpen $R1 "$R0\FusionInventory Website.url" w
   ${FileWriteLine} $R1 "[DEFAULT]"
   ${FileWriteLine} $R1 "BASEURL=http://www.fusioninventory.org/"
   ${FileWriteLine} $R1 "[{000214A0-0000-0000-C000-000000000046}]"
   ${FileWriteLine} $R1 "Prop3=19,2"
   ${FileWriteLine} $R1 "[InternetShortcut]"
   ${FileWriteLine} $R1 "URL=http://www.fusioninventory.org/"
   ${FileWriteLine} $R1 "IDList="
   ${FileWriteLine} $R1 "IconFile=http://www.fusioninventory.org/favicon.ico"
   ${FileWriteLine} $R1 "IconIndex=1"
   FileClose $R1

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R2, $R1 & $R0 off of the stack
   Pop $R2
   Pop $R1
   Pop $R0
!macroend


; InstallStrawberryPerl
!define InstallStrawberryPerl "!insertmacro InstallStrawberryPerl"

!macro InstallStrawberryPerl
   ; Push $R0 onto the stack
   Push $R0

   ; Set mode at which commands print their status
   SetDetailsPrint textonly

   ; Create directories
   ${ReadINIOption} $R0 "${IOS_FINAL}" "${IO_INSTALLDIR}"
   CreateDirectory "$R0"
   CreateDirectory "$R0\perl"
   CreateDirectory "$R0\perl\bin"
   CreateDirectory "$R0\perl\lib"
   CreateDirectory "$R0\perl\site"
   CreateDirectory "$R0\perl\vendor"

   ; Install $R0\perl\bin
   SetOutPath "$R0\perl\bin\"
   File "${STRAWBERRY_DIR}\c\bin\*.dll"
   File "${STRAWBERRY_DIR}\perl\bin\*.dll"
   File "${STRAWBERRY_DIR}\perl\bin\*.exe"

   ; Rename perl.exe as fusioninventory-agent.exe and re-install it
   Rename "perl.exe" "fusioninventory-agent.exe"
   File "${STRAWBERRY_DIR}\perl\bin\perl.exe"

   ; Install $R0\perl\lib
   SetOutPath "$R0\perl\lib\"
   File /r "${STRAWBERRY_DIR}\perl\lib\*.*"

   ; Install $R0\perl\site
   SetOutPath "$R0\perl\site\"
   File /r "${STRAWBERRY_DIR}\perl\site\*.*"

   ; Install $R0\perl\vendor
   SetOutPath "$R0\perl\vendor\"
   File /r "${STRAWBERRY_DIR}\perl\vendor\*.*"

   ; Create $R0\perl\lib\setup.pm
   FileOpen $R1 "$R0\perl\lib\setup.pm" w
   ${FileWriteLine} $R1 "package setup;"
   ${FileWriteLine} $R1 "use strict;"
   ${FileWriteLine} $R1 "use warnings;"
   ${FileWriteLine} $R1 "use base qw(Exporter);"
   ${FileWriteLine} $R1 "our @EXPORT = ('%setup');"
   ${FileWriteLine} $R1 "use lib '$R0/perl/agent';"
   ${FileWriteLine} $R1 "our %setup = ("
   ${FileWriteLine} $R1 "    datadir => '$R0/share',"
   ${FileWriteLine} $R1 "    vardir  => '$R0/var',"
   ${FileWriteLine} $R1 "    libdir  => '$R0/perl/agent',"
   ${FileWriteLine} $R1 ");"
   ${FileWriteLine} $R1 "1;"
   FileClose $R1

   ; Set mode at which commands print their status
   SetDetailsPrint lastused

   ; Pop $R0 off of the stack
   Pop $R0
!macroend


; NormalizeOption
!define NormalizeOption "!insertmacro NormalizeOption"

!macro NormalizeOption ValidValues ValuesToNormalize ResultVar
   Push ${ValidValues}
   Push ${ValuesToNormalize}
   Call NormalizeOption
   Pop ${ResultVar}
!macroend

Function NormalizeOption
   ; $R0 Valid values CommaUStr/Str
   ; $R1 Values to normalize CommaUStr/Str
   ; $R2 Normalized values CommaUStr/Str
   ; $R3 Auxiliary

   ; Note: $R0 is used also output variable

   ; Get parameter
   Exch $R1
   Exch
   Exch $R0
   Exch

   ; Push $R2 & $R3 onto the stack
   Push $R2
   Push $R3

   ; Initialize $R1
   ${AddCommaStrCommaUStr} "" "$R1" $R1

   ; Initialize $R2
   StrCpy $R2 ""

   ; Get values in $R1
   ${GetStrsCommaUStr} "$R1" $R3

   ; Check the number of values
   ${If} $R3 = 0
      ; There aren't values
      Nop
   ${Else}
      ; Normalize loop...
      ${Do}
         ; Get the first valid value
         ${FirstStrCommaUStr} "$R0" $R3
         ; Check the $R3 valid value
         ${If} "$R3" == ""
            ; There aren't more valid values
            ${ExitDo}
         ${Else}
            ; Check whether $R3 is in $R1
            ${If} "$R3" IsInCommaUStr "$R1"
               ; Add $R3 to $R2
               ${AddStrCommaUStr} "$R2" "$R3" $R2
            ${EndIf}
         ${EndIf}

         ; Check the next valid agent task
         ${DelStrCommaUStr} "$R0" "$R3" $R0
      ${Loop}
   ${EndIf}

   ; Copy return value in $R0
   StrCpy $R0 "$R2"

   ; Pop $R3, $R2 & $R1 off of the stack
   Pop $R3
   Pop $R2
   Pop $R1

   ; Exchanges the top element of the stack with $R0
   Exch $R0
FunctionEnd


; NormalizeOptions
!define NormalizeOptions "!insertmacro NormalizeOptions"

!macro NormalizeOptions INISection
   Push ${INISection}
   Call NormalizeOptions
!macroend

Function NormalizeOptions
   ; $R0 INI Section
   ; $R1 Valid values CommaUStr/Str
   ; $R2 Values to normalize CommaUStr/Str
   ; $R3 Normalized values CommaUStr/Str

   ; Get parameter
   Exch $R0

   ; Push $R1, $R2 & $R3 onto the stack
   Push $R1
   Push $R2
   Push $R3

   ; Normalize 'installtasks' option
   ${GetValidTasksCommaUStr} $R1
   ${ReadINIOption} $R2 "$R0" "${IO_INSTALLTASKS}"
   ${NormalizeOption} "$R1" "$R2" $R3
   ${WriteINIOption} "$R0" "${IO_INSTALLTASKS}" "$R3"

   ; Normalize 'no-category' option
   ${GetValidCategoryCommaUStr} $R1
   ${ReadINIOption} $R2 "$R0" "${IO_NO-CATEGORY}"
   ${NormalizeOption} "$R1" "$R2" $R3
   ${WriteINIOption} "$R0" "${IO_NO-CATEGORY}" "$R3"

   ; Normalize 'no-task' option
   ${GetValidTasksCommaUStr} $R1
   ${ReadINIOption} $R2 "$R0" "${IO_NO-TASK}"
   ${NormalizeOption} "$R1" "$R2" $R3
   ${WriteINIOption} "$R0" "${IO_NO-TASK}" "$R3"

   ; Normalize 'task-frequency' option
   ${GetValidWindowsTaskFrequencyCommaUStr} $R1
   ${ReadINIOption} $R2 "$R0" "${IO_TASK-FREQUENCY}"
   ${NormalizeOption} "$R1" "$R2" $R3
   ${WriteINIOption} "$R0" "${IO_TASK-FREQUENCY}" "$R3"

   ; Pop $R3, $R2, $R1 & $R0 off of the stack
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


; PrepareToExit
!define PrepareToExit "!insertmacro PrepareToExit"

!macro PrepareToExit
   ; Sets the output path to $TEMP
   SetOutPath "$TEMP"

   ; Unload registry plugin
   ${registry::Unload}
!macroend


; UninstallCurrentAgent
!define UninstallCurrentAgent "!insertmacro UninstallCurrentAgent"

!macro UninstallCurrentAgent ResultVar
   Call UninstallCurrentAgent
   Pop "${ResultVar}"
!macroend

Function UninstallCurrentAgent
   ; Push $R0, $R1 & $R2 onto the stack
   Push $R0
   Push $R1
   Push $R2

   ; Initialize $R0
   StrCpy $R0 0

   ; Get uninstall string
   ${GetCurrentUninstallString} $R1

   ; Whether the uninstaller exists...
   ${If} "$R1" != ""
      ; Get parent directory
      ${GetParent} "$R1" $R2

      ; Copy the uninstaller to $TEMP
      CopyFiles "$R1" "$TEMP"

      ; Rebuild the uninstaller string
      ${WordReplace} "$R1" "$R2" "$TEMP" "+1" $R1

      ; Erase quotation marks (") from $R2
      ${WordReplace} "$R2" "$\"" "" "+" $R2

      ; Set the output path to $TEMP
      SetOutPath "$TEMP"

      ; Exec the uninstaller...
      ExecWait '"$R1" /S _?=$R2' $R0

      ; Wait a couple of seconds
      Sleep 2000
   ${EndIf}

   ; Pop $R2 & $R1 off of the stack
   Pop $R2
   Pop $R1

   ; Exchanges the top element of the stack with $R0
   Exch $R0
FunctionEnd


!endif
