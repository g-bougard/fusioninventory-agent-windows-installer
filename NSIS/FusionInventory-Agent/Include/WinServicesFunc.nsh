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
   @file      .\FusionInventory Agent\Include\WinServicesFunc.nsh
   @author    Tomas Abad <tabadgp@gmail.com>
   @copyright Copyright (c) 2010-2017 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      https://github.com/fusioninventory/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_WINSERVICESFUNC_INCLUDE__
!define __FIAI_WINSERVICESFUNC_INCLUDE__


!include LogicLib.nsh
!include "${FIAI_DIR}\Include\INIFunc.nsh"
!include "${FIAI_DIR}\Include\WindowsInfo.nsh"
!include "${FIAI_DIR}\Include\WinServicesFuncLangStrings.nsh"


; Define timeout (in seconds) for Start, Stop, Pause, Continue and Restart operations
!define SERVICE_CHANGE_STATE_TIMEOUT 90


; FusionInventoryAgentServiceIsInstalled
!macro _FusionInventoryAgentServiceIsInstalled _a _b _t _f
   !insertmacro _LOGICLIB_TEMP
   SimpleSC::ExistsService "${PRODUCT_INTERNAL_NAME}"
   Pop $_LOGICLIB_TEMP
   !insertmacro _= $_LOGICLIB_TEMP 0 `${_t}` `${_f}`
!macroend

!define FusionInventoryAgentServiceIsInstalled `"" FusionInventoryAgentServiceIsInstalled ""`


; GetFusionInventoryWindowsServiceStartType
!define GetFusionInventoryWindowsServiceStartType "!insertmacro GetFusionInventoryWindowsServiceStartType"

!macro GetFusionInventoryWindowsServiceStartType ResultVar
   Push $R0
   SimpleSC::GetServiceStartType "${PRODUCT_INTERNAL_NAME}"
   Pop $R0
   Pop ${ResultVar}
   ${If} $R0 = 0
      Nop
   ${Else}
      StrCpy ${ResultVar} ""
   ${EndIf}
   Pop $R0
!macroend


; GetFusionInventoryWindowsServiceStatus
!define GetFusionInventoryWindowsServiceStatus "!insertmacro GetFusionInventoryWindowsServiceStatus"

!macro GetFusionInventoryWindowsServiceStatus ResultVar
   Push $R0
   SimpleSC::GetServiceStatus "${PRODUCT_INTERNAL_NAME}"
   Pop $R0
   Pop ${ResultVar}
   ${If} $R0 = 0
      Nop
   ${Else}
      StrCpy ${ResultVar} ""
   ${EndIf}
   Pop $R0
!macroend


; InstallFusionInventoryWindowsService
!define InstallFusionInventoryWindowsService "Call InstallFusionInventoryWindowsService"

Function InstallFusionInventoryWindowsService
   ; $R0 Section from which to read
   ; $R1 Install directory
   ; $R2 Service status / start type
   ; $R3 Return code
   ; $R4 The ${IO_LOCAL} target
   ; $R5 The ${IO_SERVER} target

   ; Push $R0, $R1, $R2, $R3, $R4 & $R5 onto the stack
   Push $R0
   Push $R1
   Push $R2
   Push $R3
   Push $R4
   Push $R5

   ; Set the section from which to read
   StrCpy $R0 "${IOS_FINAL}"

   ; Get install directory
   ${ReadINIOption} $R1 "$R0" "${IO_INSTALLDIR}"

   ; Install the service
   SimpleSC::InstallService \
      "${PRODUCT_INTERNAL_NAME}" "${PRODUCT_NAME}" "16" "${SERVICE_STARTTYPE_DEMAND}" \
      `"$R1\perl\bin\fusioninventory-agent.exe" -I"$R1\perl\agent" -I"$R1\perl\lib" -I"$R1\perl\site\lib" -I"$R1\perl\vendor\lib" "$R1\perl\bin\fusioninventory-win32-service"` \
      "" "" ""
   Pop $R3

   ; Set service description
   ;    only whether the system is higher than Windows NT
   ${If} ${AtLeastWin2000}
      SimpleSC::SetServiceDescription "${PRODUCT_INTERNAL_NAME}" "$(InstallFusionInventoryWindowsService_Description)"
      Pop $R3
   ${EndIf}

   ; Set service status
   ${ReadINIOption} $R2 "$R0" "${IO_SERVICE-STATUS}"
   ${If} $R2 = ${SERVICE_STATUS_RUNNING}
   ${OrIf} $R2 = ${SERVICE_STATUS_START_PENDING}
   ${OrIf} $R2 = ${SERVICE_STATUS_CONTINUE_PENDING}
      ; Start service, but only whether there is a target defined

      ; Get ${IO_LOCAL} and ${IO_SERVER} target definitions
      ${ReadINIOption} $R4 "$R0" "${IO_LOCAL}"
      ${ReadINIOption} $R5 "$R0" "${IO_SERVER}"

      ; Check target definitions
      ${If} "$R4" != ""
      ${OrIf} "$R5" != ""
         ; At least there is a target defined, start service
         SimpleSC::StartService "${PRODUCT_INTERNAL_NAME}" "" "${SERVICE_CHANGE_STATE_TIMEOUT}"
         Pop $R3
      ${EndIf}
   ${ElseIf} $R2 = ${SERVICE_STATUS_STOPPED}
   ${OrIf} $R2 = ${SERVICE_STATUS_STOP_PENDING}
   ${OrIf} $R2 = ${SERVICE_STATUS_PAUSED}
   ${OrIf} $R2 = ${SERVICE_STATUS_PAUSE_PENDING}
      ; Stop service
      SimpleSC::StopService "${PRODUCT_INTERNAL_NAME}" "1" "${SERVICE_CHANGE_STATE_TIMEOUT}"
      Pop $R3
   ${EndIf}

   ; Set service start type
   ${ReadINIOption} $R2 "$R0" "${IO_SERVICE-START-TYPE}"
   SimpleSC::SetServiceStartType "${PRODUCT_INTERNAL_NAME}" "$R2"
   Pop $R3

   ; Pop $R5, $R4, $R3, $R2, $R1 & $R0 off of the stack
   Pop $R5
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


; RemoveFusionInventoryWindowsService
!define RemoveFusionInventoryWindowsService "!insertmacro RemoveFusionInventoryWindowsService"

!macro RemoveFusionInventoryWindowsService
   ; Push $R0 onto the stack
   Push $R0

   ; Check if the service exist
   SimpleSC::ExistsService "${PRODUCT_INTERNAL_NAME}"
   Pop $R0

   ${If} $R0 = 0
      ; The service exists
      ; Stop service
      SimpleSC::StopService "${PRODUCT_INTERNAL_NAME}" "1" "${SERVICE_CHANGE_STATE_TIMEOUT}"
      Pop $R0

      ; Disable service
      SimpleSC::SetServiceStartType "${PRODUCT_INTERNAL_NAME}" "${SERVICE_STARTTYPE_DISABLED}"
      Pop $R0

      ; Remove service
      SimpleSC::RemoveService "${PRODUCT_INTERNAL_NAME}"
      Pop $R0
   ${EndIf}

   ; Pop $R0 off of the stack
   Pop $R0
!macroend


!endif
