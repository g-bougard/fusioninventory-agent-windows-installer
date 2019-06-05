/*
   ------------------------------------------------------------------------
   FusionInventory Agent Installer for Microsoft Windows
   Copyright (C) 2010-2013 by the FusionInventory Development Team.

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
   @file      .\FusionInventory Agent\Include\INIFunc.nsh
   @author    Tomas Abad <tabadgp@gmail.com>
   @copyright Copyright (c) 2010-2013 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_INIFUNC_INCLUDE__
!define __FIAI_INIFUNC_INCLUDE__


!include LogicLib.nsh
!include "${FIAI_DIR}\Include\CommaUStrFunc.nsh"
!include "${FIAI_DIR}\Include\Registry.nsh"


; Define INI options file
!define INI_OPTIONS_FILE "$PLUGINSDIR\Options.ini"


; Define INI options sections
!define IOS_DEFAULT "Default"
!define IOS_COMMANDLINE "CommandLine"
!define IOS_CURRENTCONFIG "CurrentConfig"
!define IOS_DEFAULTGUI "DefaultGUI"
!define IOS_GUI "GUI"
!define IOS_FINAL "Final"


; Define INI options
!define IO_ACCEPTLICENSE "acceptlicense"
!define IO_ADD-FIREWALL-EXCEPTION "add-firewall-exception"
!define IO_BACKEND-COLLECT-TIMEOUT "backend-collect-timeout"
!define IO_CA-CERT-DIR "ca-cert-dir"
!define IO_CA-CERT-FILE "ca-cert-file"
!define IO_CA-CERT-URI "ca-cert-uri"
!define IO_CONF-RELOAD-INTERVAL "conf-reload-interval"
!define IO_DEBUG "debug"
!define IO_DELAYTIME "delaytime"
!define IO_EXECMODE "execmode"
!define IO_HELP "help"
!define IO_HTML "html"
!define IO_HTTPD-IP "httpd-ip"
!define IO_HTTPD-PORT "httpd-port"
!define IO_HTTPD-TRUST "httpd-trust"
!define IO_INSTALLDIR "installdir"
!define IO_INSTALLTASKS "installtasks"
!define IO_INSTALLTYPE "installtype"
!define IO_LOCAL "local"
!define IO_LOGFILE "logfile"
!define IO_LOGFILE-MAXSIZE "logfile-maxsize"
!define IO_LOGGER "logger"
!define IO_NO-CATEGORY "no-category"
!define IO_NO-HTTPD "no-httpd"
!define IO_NO-P2P "no-p2p"
!define IO_NO-SSL-CHECK "no-ssl-check"
!define IO_NO-START-MENU "no-start-menu"
!define IO_NO-TASK "no-task"
!define IO_PASSWORD "password"
!define IO_PROXY "proxy"
!define IO_QUICK-INSTALL "quick-install"
!define IO_RUNNOW "runnow"
!define IO_SCAN-HOMEDIRS "scan-homedirs"
!define IO_SCAN-PROFILES "scan-profiles"
!define IO_SERVER "server"
!define IO_SERVICE-START-TYPE "service-start-type"
!define IO_SERVICE-STATUS "service-status"
!define IO_SILENTMODE "silentmode"
!define IO_TAG "tag"
!define IO_TASKS "tasks"
!define IO_TASK-DAILY-MODIFIER "task-daily-modifier"
!define IO_TASK-FREQUENCY "task-frequency"
!define IO_TASK-HOURLY-MODIFIER "task-hourly-modifier"
!define IO_TASK-MINUTE-MODIFIER "task-minute-modifier"
!define IO_TIMEOUT "timeout"
!define IO_USER "user"


; Define INI deprecated options
!define IO_D "D"
!define IO_DAEMON-NO-FORK "daemon-no-fork"
!define IO_INFO "info"
!define IO_NO-INVENTORY "no-inventory"
!define IO_NO-NETDISCOVERY "no-netdiscovery"
!define IO_NO-PRINTER "no-printer"
!define IO_NO-OCSDEPLOY "no-ocsdeploy"
!define IO_NO-SNMPQUERY "no-snmpquery"
!define IO_NO-SOCKET "no-socket"
!define IO_NO-SOFTWARE "no-software"
!define IO_NO-WAKEONLAN "no-wakeonlan"
!define IO_REALM "realm"
!define IO_RPC-IP "rpc-ip"
!define IO_RPC-PORT "rpc-port"
!define IO_RPC-TRUST-LOCALHOST "rpc-trust-localhost"


; Define INI options values
!define CATEGORY_ANTIVIRUS "antivirus"
!define CATEGORY_BATTERY "battery"
!define CATEGORY_CONTROLLER "controller"
!define CATEGORY_CPU "cpu"
!define CATEGORY_DRIVE "drive"
!define CATEGORY_ENVIRONMENT "environment"
!define CATEGORY_INPUT "input"
!define CATEGORY_LICENSE-INFO "licenseinfo"
!define CATEGORY_LOCAL-GROUP "local_group"
!define CATEGORY_LOCAL-USER "local_user"
!define CATEGORY_LVM "lvm"
!define CATEGORY_MEMORY "memory"
!define CATEGORY_MODEM "modem"
!define CATEGORY_MONITOR "monitor"
!define CATEGORY_NETWORK "network"
!define CATEGORY_PORT "port"
!define CATEGORY_PRINTER "printer"
!define CATEGORY_PROCESS "process"
!define CATEGORY_REMOTE-MGMT "remote_mgmt"
!define CATEGORY_SLOT "slot"
!define CATEGORY_SOFTWARE "software"
!define CATEGORY_SOUND "sound"
!define CATEGORY_STORAGE "storage"
!define CATEGORY_USB "usb"
!define CATEGORY_USER "user"
!define CATEGORY_VIDEO "video"
!define CATEGORY_VIRTUAL-MACHINE "virtualmachine"

!define EXECMODE_SERVICE "Service"
!define EXECMODE_TASK "Task"
!define EXECMODE_MANUAL "Manual"
!define EXECMODE_CURRENT "Current"

!define FREQUENCY_MINUTE "Minute"
!define FREQUENCY_HOURLY "Hourly"
!define FREQUENCY_DAILY "Daily"

!define INSTALLTASK_COLLECT "Collect"
!define INSTALLTASK_DEFAULT "Default"
!define INSTALLTASK_DEPLOY "Deploy"
!define INSTALLTASK_ESX "ESX"
!define INSTALLTASK_FULL "Full"
!define INSTALLTASK_INVENTORY "Inventory"
!define INSTALLTASK_MINIMAL "Minimal"
!define INSTALLTASK_NETDISCOVERY "NetDiscovery"
!define INSTALLTASK_NETINVENTORY "NetInventory"
!define INSTALLTASK_WAKEONLAN "WakeOnLan"

!define INSTALLTYPE_FROMCURRENTCONFIG "from-current-config"
!define INSTALLTYPE_FROMSCRATCH "from-scratch"

!define LOGGER_FILE "File"
!define LOGGER_STDERR "Stderr"

!define TASK_COLLECT "${INSTALLTASK_COLLECT}"
!define TASK_DEPLOY "${INSTALLTASK_DEPLOY}"
!define TASK_ESX "${INSTALLTASK_ESX}"
!define TASK_INVENTORY "${INSTALLTASK_INVENTORY}"
!define TASK_NETDISCOVERY "${INSTALLTASK_NETDISCOVERY}"
!define TASK_NETINVENTORY "${INSTALLTASK_NETINVENTORY}"
!define TASK_OCSDEPLOY "OCSDeploy"
!define TASK_SNMPQUERY "SNMPQuery"
!define TASK_WAKEONLAN "${INSTALLTASK_WAKEONLAN}"

!define SERVICE_STARTTYPE_BOOT 0
!define SERVICE_STARTTYPE_SYSTEM 1
!define SERVICE_STARTTYPE_AUTO 2
!define SERVICE_STARTTYPE_DEMAND 3
!define SERVICE_STARTTYPE_DISABLED 4

!define SERVICE_STATUS_STOPPED 1
!define SERVICE_STATUS_START_PENDING 2
!define SERVICE_STATUS_STOP_PENDING 3
!define SERVICE_STATUS_RUNNING 4
!define SERVICE_STATUS_CONTINUE_PENDING 5
!define SERVICE_STATUS_PAUSE_PENDING 6
!define SERVICE_STATUS_PAUSED 7


; GetInstallTasksMinimalCommaUStr
!define GetInstallTasksMinimalCommaUStr "!insertmacro GetInstallTasksMinimalCommaUStr"

!macro GetInstallTasksMinimalCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${TASK_INVENTORY}" ${ResultVar}
!macroend


; GetInstallTasksDefaultCommaUStr
!define GetInstallTasksDefaultCommaUStr "!insertmacro GetInstallTasksDefaultCommaUStr"

!macro GetInstallTasksDefaultCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${TASK_INVENTORY}" ${ResultVar}
!macroend


; GetInstallTasksFullCommaUStr
!define GetInstallTasksFullCommaUStr "!insertmacro GetInstallTasksFullCommaUStr"

!macro GetInstallTasksFullCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${TASK_COLLECT}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${TASK_DEPLOY}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${TASK_ESX}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${TASK_INVENTORY}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${TASK_NETDISCOVERY}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${TASK_NETINVENTORY}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${TASK_WAKEONLAN}" ${ResultVar}
!macroend


; GetValidExecmodeCommaUStr
!define GetValidExecmodeCommaUStr "!insertmacro GetValidExecmodeCommaUStr"

!macro GetValidExecmodeCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${EXECMODE_SERVICE}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${EXECMODE_TASK}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${EXECMODE_MANUAL}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${EXECMODE_CURRENT}" ${ResultVar}
!macroend


; GetValidInstalltypeCommaUStr
!define GetValidInstalltypeCommaUStr "!insertmacro GetValidInstalltypeCommaUStr"

!macro GetValidInstalltypeCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${INSTALLTYPE_FROMCURRENTCONFIG}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${INSTALLTYPE_FROMSCRATCH}" ${ResultVar}
!macroend


; GetValidLoggerCommaUStr
!define GetValidLoggerCommaUStr "!insertmacro GetValidLoggerCommaUStr"

!macro GetValidLoggerCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${LOGGER_FILE}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${LOGGER_STDERR}" ${ResultVar}
!macroend


; GetValidCategoryCommaUStr
!define GetValidCategoryCommaUStr "!insertmacro GetValidCategoryCommaUStr"

!macro GetValidCategoryCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_ANTIVIRUS}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_BATTERY}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_CONTROLLER}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_CPU}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_DRIVE}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_ENVIRONMENT}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_INPUT}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_LICENSE-INFO}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_LOCAL-GROUP}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_LOCAL-USER}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_LVM}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_MEMORY}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_MODEM}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_MONITOR}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_NETWORK}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_PORT}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_PRINTER}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_PROCESS}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_REMOTE-MGMT}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_SLOT}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_SOFTWARE}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_SOUND}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_STORAGE}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_USB}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_USER}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_VIDEO}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${CATEGORY_VIRTUAL-MACHINE}" ${ResultVar}
!macroend


; GetValidTasksCommaUStr
!define GetValidTasksCommaUStr "!insertmacro GetInstallTasksFullCommaUStr"


; GetValidWindowsTaskMinuteModifierCommaUStr
!define GetValidWindowsTaskMinuteModifierCommaUStr "!insertmacro GetValidWindowsTaskMinuteModifierCommaUStr"

!macro GetValidWindowsTaskMinuteModifierCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "15" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "20" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "30" ${ResultVar}
!macroend


; GetValidWindowsTaskFrequencyCommaUStr
!define GetValidWindowsTaskFrequencyCommaUStr "!insertmacro GetValidWindowsTaskFrequencyCommaUStr"

!macro GetValidWindowsTaskFrequencyCommaUStr ResultVar
   StrCpy ${ResultVar} ""
   ${AddStrCommaUStr} ${ResultVar} "${FREQUENCY_MINUTE}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${FREQUENCY_HOURLY}" ${ResultVar}
   ${AddStrCommaUStr} ${ResultVar} "${FREQUENCY_DAILY}" ${ResultVar}
!macroend


; ReadINIOption
!define ReadINIOption "!insertmacro ReadINIOption"

!macro ReadINIOption ResultVar INISection INIOption
   ReadINIStr ${ResultVar} "${INI_OPTIONS_FILE}" "${INISection}" "${INIOption}"
!macroend


; WriteINIOption
!define WriteINIOption "!insertmacro WriteINIOption"

!macro WriteINIOption INISection INIOption INIValue
   WriteINIStr "${INI_OPTIONS_FILE}" "${INISection}" "${INIOption}" "${INIValue}"
!macroend


; DeleteINIOptionSection
!define DeleteINIOptionSection "!insertmacro DeleteINIOptionSection"

!macro DeleteINIOptionSection INISection
   DeleteINISec "${INI_OPTIONS_FILE}" "${INISection}"
!macroend


; InitINIOptionsSectionDefault
!define InitINIOptionSectionDefault "Call InitINIOptionSectionDefault"

Function InitINIOptionSectionDefault
   ; Push $R0 onto the stack
   Push $R0

   ; Set default section
   StrCpy $R0 "${IOS_DEFAULT}"

   ; Delete section
   ${DeleteINIOptionSection} "$R0"

   ; Write default options values
   ${WriteINIOption} "$R0" "${IO_ACCEPTLICENSE}" "0"
   ${WriteINIOption} "$R0" "${IO_ADD-FIREWALL-EXCEPTION}" "1"
   ${WriteINIOption} "$R0" "${IO_BACKEND-COLLECT-TIMEOUT}" "180"
   ${WriteINIOption} "$R0" "${IO_CA-CERT-DIR}" ""
   ${WriteINIOption} "$R0" "${IO_CA-CERT-FILE}" ""
   ${WriteINIOption} "$R0" "${IO_CA-CERT-URI}" ""
   ${WriteINIOption} "$R0" "${IO_CONF-RELOAD-INTERVAL}" "0"
   ${WriteINIOption} "$R0" "${IO_DEBUG}" "0"
   ${WriteINIOption} "$R0" "${IO_DELAYTIME}" "3600"
   ${WriteINIOption} "$R0" "${IO_EXECMODE}" "${EXECMODE_CURRENT}"
   ${WriteINIOption} "$R0" "${IO_HELP}" "0"
   ${WriteINIOption} "$R0" "${IO_HTML}" "0"
   ${WriteINIOption} "$R0" "${IO_HTTPD-IP}" "0.0.0.0"
   ${WriteINIOption} "$R0" "${IO_HTTPD-PORT}" "62354"
   ${WriteINIOption} "$R0" "${IO_HTTPD-TRUST}" "127.0.0.1/32"
   !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
      ${WriteINIOption} "$R0" "${IO_INSTALLDIR}" "$PROGRAMFILES32\${PRODUCT_INTERNAL_NAME}"
   !else
      ${WriteINIOption} "$R0" "${IO_INSTALLDIR}" "$PROGRAMFILES64\${PRODUCT_INTERNAL_NAME}"
   !endif
   ${WriteINIOption} "$R0" "${IO_INSTALLTASKS}" "${INSTALLTASK_DEFAULT}"
   ${WriteINIOption} "$R0" "${IO_INSTALLTYPE}" "${INSTALLTYPE_FROMCURRENTCONFIG}"
   ${WriteINIOption} "$R0" "${IO_LOCAL}" ""
   !if ${PRODUCT_PLATFORM_ARCHITECTURE} == ${PLATFORM_ARCHITECTURE_32}
      ${WriteINIOption} "$R0" "${IO_LOGFILE}" "$PROGRAMFILES32\${PRODUCT_INTERNAL_NAME}\logs\fusioninventory-agent.log"
   !else
      ${WriteINIOption} "$R0" "${IO_LOGFILE}" "$PROGRAMFILES64\${PRODUCT_INTERNAL_NAME}\logs\fusioninventory-agent.log"
   !endif
   ${WriteINIOption} "$R0" "${IO_LOGFILE-MAXSIZE}" "16"
   ${WriteINIOption} "$R0" "${IO_LOGGER}" "${LOGGER_FILE}"
   ${WriteINIOption} "$R0" "${IO_NO-CATEGORY}" ""
   ${WriteINIOption} "$R0" "${IO_NO-HTTPD}" "0"
   ${WriteINIOption} "$R0" "${IO_NO-P2P}" "0"
   ${WriteINIOption} "$R0" "${IO_NO-SSL-CHECK}" "0"
   ${WriteINIOption} "$R0" "${IO_NO-START-MENU}" "0"
   ${WriteINIOption} "$R0" "${IO_NO-TASK}" ""
   ${WriteINIOption} "$R0" "${IO_PASSWORD}" ""
   ${WriteINIOption} "$R0" "${IO_PROXY}" ""
   ${WriteINIOption} "$R0" "${IO_QUICK-INSTALL}" "1"
   ${WriteINIOption} "$R0" "${IO_RUNNOW}" "0"
   ${WriteINIOption} "$R0" "${IO_SCAN-HOMEDIRS}" "0"
   ${WriteINIOption} "$R0" "${IO_SCAN-PROFILES}" "0"
   ${WriteINIOption} "$R0" "${IO_SERVER}" ""
   ${WriteINIOption} "$R0" "${IO_SERVICE-START-TYPE}" "${SERVICE_STARTTYPE_AUTO}"
   ${WriteINIOption} "$R0" "${IO_SERVICE-STATUS}" "${SERVICE_STATUS_RUNNING}"
   ${WriteINIOption} "$R0" "${IO_SILENTMODE}" "0"
   ${WriteINIOption} "$R0" "${IO_TAG}" ""
   ${WriteINIOption} "$R0" "${IO_TASKS}" ""
   ${WriteINIOption} "$R0" "${IO_TASK-DAILY-MODIFIER}" "1"
   ${WriteINIOption} "$R0" "${IO_TASK-FREQUENCY}" "${FREQUENCY_HOURLY}"
   ${WriteINIOption} "$R0" "${IO_TASK-HOURLY-MODIFIER}" "1"
   ${WriteINIOption} "$R0" "${IO_TASK-MINUTE-MODIFIER}" "15"
   ${WriteINIOption} "$R0" "${IO_TIMEOUT}" "180"
   ${WriteINIOption} "$R0" "${IO_USER}" ""

   ; Pop $R0 off of the stack
   Pop $R0
FunctionEnd


; CopyINIOptionSection
!define CopyINIOptionSection "!insertmacro CopyINIOptionSection"

!macro CopyINIOptionSection INISectionSource INISectionTarget
   Push "${INISectionSource}"
   Push "${INISectionTarget}"
   Call CopyINIOptionSection
!macroend

Function CopyINIOptionSection
   ; $R0 Source Section
   ; $R1 Target Section
   ; $R2 Option
   ; $R3 Value
   ; $R4 Auxiliary

   ; Get parameters
   Exch $R1
   Exch
   Exch $R0
   Exch

   ; Push $R2, $R3 & $R4 onto the stack
   Push $R2
   Push $R3
   Push $R4

   ; Clear errors
   ClearErrors

   ; If source section exist...
   EnumINI::SectionExist "${INI_OPTIONS_FILE}" "$R0"
   Pop $R4
   ${If} $R4 = 1
      ; Source section exists

      ; Check target section name
      ${If} "$R1" == "${IOS_DEFAULTGUI}"
      ${OrIf} "$R1" == "${IOS_GUI}"
      ${OrIf} "$R1" == "${IOS_FINAL}"
         ; Valid target section name

         ; Delete target section whether it exists
         EnumINI::SectionExist "${INI_OPTIONS_FILE}" "$R1"
         Pop $R4
         ${If} $R4 = 1
            ${DeleteINIOptionSection} "$R1"
         ${EndIf}

         ; First copy loop (reverse sort)
         EnumINI::Section "${INI_OPTIONS_FILE}" "$R0"
         Pop $R4

         ${DoWhile} $R4 > 0
            Pop $R2
            ${ReadINIOption} $R3 "$R0" "$R2"
            ${WriteINIOption} "Reverse-$R1" "$R2" "$R3"
            IntOp $R4 $R4 - 1
         ${Loop}

         ; Second copy loop (original sort)
         EnumINI::Section "${INI_OPTIONS_FILE}" "Reverse-$R1"
         Pop $R4

         ${DoWhile} $R4 > 0
            Pop $R2
            ${ReadINIOption} $R3 "Reverse-$R1" "$R2"
            ${WriteINIOption} "$R1" "$R2" "$R3"
            IntOp $R4 $R4 - 1
         ${Loop}

         ; Delete auxiliary section "Reverse-$R1"
         ${DeleteINIOptionSection} "Reverse-$R1"
      ${Else}
         ; Invalid target section name

         ; Set the error flag
         SetErrors
      ${EndIf}
   ${Else}
      ; Source section doesn't exists

      ; Set the error flag
      SetErrors
   ${EndIf}

   ; Pop $R4, $R3, $R2, $R1 & $R0 off of the stack
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


; UpdateINIOptionSection
!define UpdateINIOptionSection "!insertmacro UpdateINIOptionSection"

!macro UpdateINIOptionSection INISectionToUpdate INISectionFromWhichToUpdate
   Push "${INISectionToUpdate}"
   Push "${INISectionFromWhichToUpdate}"
   Call UpdateINIOptionSection
!macroend

Function UpdateINIOptionSection
   ; $R0 Section to update
   ; $R1 Section from which to update
   ; $R2 Option
   ; $R3 Value
   ; $R4 Auxiliary

   ; Get parameters
   Exch $R1
   Exch
   Exch $R0
   Exch

   ; Push $R2, $R3 & $R4 onto the stack
   Push $R2
   Push $R3
   Push $R4

   ; Clear errors
   ClearErrors

   ; If section to update exist...
   EnumINI::SectionExist "${INI_OPTIONS_FILE}" "$R0"
   Pop $R4
   ${If} $R4 = 1
      ; Section to update exists

      ; If section from whitch to update exist...
      EnumINI::SectionExist "${INI_OPTIONS_FILE}" "$R1"
      Pop $R4
      ${If} $R4 = 1
         ; Section from whitch to update exists

         ; Update loop
         EnumINI::Section "${INI_OPTIONS_FILE}" "$R1"
         Pop $R4

         ${DoWhile} $R4 > 0
            Pop $R2
            ${ReadINIOption} $R3 "$R1" "$R2"
            ${WriteINIOption} "$R0" "$R2" "$R3"
            IntOp $R4 $R4 - 1
         ${Loop}

         ; Check for dependence option values
         ; ToDo
      ${Else}
         ; Section from whitch to update doesn't exist

         ; Set the error flag
         SetErrors
      ${EndIf}
   ${Else}
      ; Section to update doesn't exist

      ; Set the error flag
      SetErrors
   ${EndIf}

   ; Pop $R4, $R3, $R2, $R1 & $R0 off of the stack
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


!endif
