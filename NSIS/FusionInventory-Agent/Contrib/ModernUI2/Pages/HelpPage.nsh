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
   @file      .\FusionInventory Agent\Contrib\ModernUI2\Pages\HelpPage.nsh
   @author    Tomas Abad <tabadgp@gmail.com>
   @copyright Copyright (c) 2010-2013 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!include LogicLib.nsh
!include "${FIAI_DIR}\Include\INIFunc.nsh"
!include "${FIAI_DIR}\Include\FileFunc.nsh"
!include "${FIAI_DIR}\Contrib\ModernUI2\Pages\HelpPageLangStrings.nsh"


;--------------------------------
; Help Page Functions

Function HelpPage_Show
   ; Pushes $R0 onto the stack
   Push $R0

   ; Check for command line syntax error
   ${IfNot} ${CommandLineSyntaxError}
      ; Check for help
      ${ReadINIOption} $R0 "${IOS_COMMANDLINE}" "${IO_HELP}"
      ${If} $R0 = 1
         ; Display help and exit
         Call ShowHelpFile
         ${PrepareToExit}
         Pop $R0
         Quit
      ${EndIf}
   ${Else}
      ; Syntax error
      ; Display help and exit
      Call ShowHelpFile
      ${PrepareToExit}
      Pop $R0
      Quit
   ${EndIf}

   ; Pop $R0 off of the stack
   Pop $R0
FunctionEnd


Function HelpPage_Leave
   Nop
FunctionEnd


Function ShowHelpFile
   SetOutPath "$TEMP"
   File "${FIAI_DIR}\Doc\fusioninventory-agent_windows_installer_en.html"
   ;File "${FIAI_DIR}\Doc\fusioninventory-agent_windows_installer_fr.html"
   ;File "${FIAI_DIR}\Doc\fusioninventory-agent_windows_installer_es.html"
   ;ExecShell "open" "$TEMP\fusioninventory-agent_windows_installer_$(HelpFile_Lang).html"
   ExecShell "open" "$TEMP\fusioninventory-agent_windows_installer_en.html"
FunctionEnd

