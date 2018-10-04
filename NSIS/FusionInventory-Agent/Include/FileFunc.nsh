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
   @file      .\FusionInventory Agent\Include\FileFunc.nsh
   @author    Tomas Abad <tabadgp@gmail.com>
   @copyright Copyright (c) 2010-2013 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_FILEFUNC_INCLUDE__
!define __FIAI_FILEFUNC_INCLUDE__


!include LogicLib.nsh


; Global variables
Var STDERR

; FileWriteLine
!define FileWriteLine "!insertmacro FileWriteLine"

!macro FileWriteLine Handle String
   FileWrite ${Handle} "${String}"
   FileWriteByte ${Handle} "13"
   FileWriteByte ${Handle} "10"
!macroend


; StdErrInit
!define StdErrInit "!insertmacro StdErrInit"

!macro StdErrInit
   System::Call 'kernel32::GetStdHandle(i -12)i'
   pop $STDERR
   System::Call 'kernel32::AttachConsole(i -1)i.r0'
   ${If} $STDERR = 0
   ${OrIf} $R0 = 0
      System::Call 'kernel32::AllocConsole()'
      System::Call 'kernel32::GetStdHandle(i -12)i'
      pop $STDERR
   ${EndIf}
!macroend


; StdErr
!define StdErr "!insertmacro StdErr"

!macro StdErr String
   ${IfNot} $STDERR = 0
      ${FileWriteLine} $STDERR "${String}"
   ${EndIf}
!macroend


!endif

