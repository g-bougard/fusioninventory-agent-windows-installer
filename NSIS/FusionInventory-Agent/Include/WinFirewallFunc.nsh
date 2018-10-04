/*
   ------------------------------------------------------------------------
   FusionInventory Agent Installer for Microsoft Windows
   Copyright (C) 2010-2018 by the FusionInventory Development Team.

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
   @file      .\FusionInventory Agent\Include\WinFirewallFunc.nsh
   @author    Guillaume Bougard <gbougard@teclib.com>
   @copyright Copyright (c) 2010-2018 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_WINFIREWALLFUNC_INCLUDE__
!define __FIAI_WINFIREWALLFUNC_INCLUDE__


!include LogicLib.nsh
!include "${FIAI_DIR}\Include\INIFunc.nsh"
;!include "${FIAI_DIR}\Include\WindowsInfo.nsh"


; RemoveFusionInventoryFirewallExceptions
!define RemoveFusionInventoryFirewallExceptions "!insertmacro RemoveFusionInventoryFirewallExceptions"

!macro RemoveFusionInventoryFirewallExceptions
   ; $R0, $R1 ExecToStack's return values

   ; Push $R0 & $R1 onto the stack
   Push $R0
   Push $R1

   nsExec::ExecTostack 'netsh advfirewall firewall delete rule \
      name="${PRODUCT_INTERNAL_NAME}"'
   Pop $R0
   Pop $R1

   ; Pop $R1 & $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend

; AddFusionInventoryFirewallException
!define AddFusionInventoryFirewallException "Call AddFusionInventoryFirewallException"

Function AddFusionInventoryFirewallException
   ; $R0 Section from which to read
   ; $R1 Port for which add an exception
   ; $R2 Install directory
   ; $R3, $R4 ExecToStack's return values

   ; Push $R0, $R1, $R2, $R3 & $R4 onto the stack
   Push $R0
   Push $R1
   Push $R2
   Push $R3
   Push $R4

   ; Set the section from which to read
   StrCpy $R0 "${IOS_FINAL}"

   ; Get httpd port
   ${ReadINIOption} $R1 "$R0" "${IO_HTTPD-PORT}"

   ; Get install directory
   ${ReadINIOption} $R2 "$R0" "${IO_INSTALLDIR}"

   ; Create firewall exceptions
   nsExec::ExecTostack 'netsh advfirewall firewall add rule \
      name="${PRODUCT_INTERNAL_NAME}" \
      program="$R2\perl\bin\fusioninventory-agent.exe" \
      description="FusionInventory-Agent service HTTP daemon incoming traffic" \
      protocol=TCP dir=in localport=$R1 action=allow'
   Pop $R3
   Pop $R4
   ${If} "$R3" != "0"
      DetailPrint "AddFirewallException1: $R3: $R4"
   ${EndIf}

   nsExec::ExecTostack 'netsh advfirewall firewall add rule \
      name="${PRODUCT_INTERNAL_NAME}" \
      program="$R2\perl\bin\fusioninventory-agent.exe" \
      description="All FusionInventory-Agent service traffic" \
      dir=out action=allow'
   Pop $R3
   Pop $R4
   ${If} "$R3" != "0"
      DetailPrint "AddFirewallException2: $R3: $R4"
   ${EndIf}

   nsExec::ExecTostack 'netsh advfirewall firewall add rule \
      name="${PRODUCT_INTERNAL_NAME}" \
      program="$R2\perl\bin\perl.exe" \
      description="All FusionInventory-Agent perl interpreter traffic" \
      dir=out action=allow'
   Pop $R3
   Pop $R4
   ${If} "$R3" != "0"
      DetailPrint "AddFirewallException3: $R3: $R4"
   ${EndIf}

   ; Pop $R4, $R3, $R2, $R1 & $R0 off of the stack
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


!endif
