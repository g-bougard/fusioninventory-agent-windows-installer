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
   @file      .\FusionInventory Agent\Include\WinTasksFunc.nsh
   @author    Manuel J. Garrido <manuel.garrido@gmail.com>
   @copyright Copyright (c) 2010-2013 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_WINTASKSFUNC_INCLUDE__
!define __FIAI_WINTASKSFUNC_INCLUDE__


!include LogicLib.nsh
!include "${FIAI_DIR}\Include\INIFunc.nsh"
!include "${FIAI_DIR}\Include\WindowsInfo.nsh"


; IsTargetOsValidForWindowsTask
!define IsTargetOsValidForWindowsTask `"" IsTargetOsValidForWindowsTask ""`

!macro _IsTargetOsValidForWindowsTask _a _b _t _f
   !insertmacro _LOGICLIB_TEMP
   Call IsTargetOsValidForWindowsTask
   Pop $_LOGICLIB_TEMP
   !insertmacro _= $_LOGICLIB_TEMP 0 `${_t}` `${_f}`
!macroend

Function IsTargetOsValidForWindowsTask
   ; $R0 Auxiliary

   ; Note: $R0 is used also output variable

   ; Push $R0 onto the stack
   Push $R0

   ; Initialize $R0
   StrCpy $R0 1

   ; Check Windows version
   ${If} ${IsServerOS}
      ; It's a Windows server
      ${If} ${AtLeastWin2003}
         ; At least is a Windows Server 2003
         StrCpy $R0 0
      ${EndIf}
   ${Else}
      ; It's a Windows client
      ${If} ${AtLeastWinXP}
         ; At least is a Windows XP
         StrCpy $R0 0
      ${EndIf}
   ${EndIf}

   ; Exchanges the top element of the stack with $R0
   Exch $R0
FunctionEnd


; FusionInventoryAgentTaskIsInstalled
!macro _FusionInventoryAgentTaskIsInstalled _a _b _t _f
   ; $R0 Comspec full path
   ; $R1 String to look for
   ; $R2 ExecToStack's return value

   ; Push $R0, $R1 & $R2 onto the stack
   Push $R0
   Push $R1
   Push $R2

   ; Look for task
   !insertmacro _LOGICLIB_TEMP
   ExpandEnvStrings $R0 %COMSPEC%
   StrCpy $R1 '${PRODUCT_INTERNAL_NAME}'
   nsExec::ExecToStack '"$R0" /c schtasks /query /fo csv | find /c "$R1"'

   ; Get ExecToStack's return values
   Pop $R2
   Pop $_LOGICLIB_TEMP

   ; Pop $R2, $R1 & $R0 off of the stack
   Pop $R2
   Pop $R1
   Pop $R0

   !insertmacro _= $_LOGICLIB_TEMP 1 `${_t}` `${_f}`
!macroend

!define FusionInventoryAgentTaskIsInstalled `"" FusionInventoryAgentTaskIsInstalled ""`


; RemoveFusionInventoryWindowsTask
!define RemoveFusionInventoryWindowsTask "!insertmacro RemoveFusionInventoryWindowsTask"

!macro RemoveFusionInventoryWindowsTask
   ; $R0, $R1 ExecToStack's return values

   ; Push $R0 & $R1 onto the stack
   Push $R0
   Push $R1

   ${If} ${FusionInventoryAgentTaskIsInstalled}
      nsExec::ExecTostack 'schtasks /end /tn "${PRODUCT_INTERNAL_NAME}"'
      Pop $R0
      Pop $R1

      nsExec::ExecTostack 'schtasks /delete /tn "${PRODUCT_INTERNAL_NAME}" /f'
      Pop $R0
      Pop $R1
   ${EndIf}

   ; Pop $R1 & $R0 off of the stack
   Pop $R1
   Pop $R0
!macroend


; AddFusionInventoryWindowsTask
!define AddFusionInventoryWindowsTask "Call AddFusionInventoryWindowsTask"

Function AddFusionInventoryWindowsTask
   ; $R0 Section from which to read
   ; $R1 Install directory
   ; $R2 Time unit for the scheduler (minute, hourly, daily)
   ; $R3 Time interval
   ; $R4, $R5 ExecToStack's return values

   ; Push $R0, $R1, $R2, $R3, $R4  & $R5 onto the stack
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

   ; Get time unit for the scheduler (minute, hourly, daily)
   ${ReadINIOption} $R2 "$R0" "${IO_TASK-FREQUENCY}"

   ; Get the time interval
   ${Select} "$R2"
      ${Case} "${FREQUENCY_MINUTE}"
         ${ReadINIOption} $R3 "$R0" "${IO_TASK-MINUTE-MODIFIER}"
      ${Case} "${FREQUENCY_HOURLY}"
         ${ReadINIOption} $R3 "$R0" "${IO_TASK-HOURLY-MODIFIER}"
      ${Case} "${FREQUENCY_DAILY}"
         ${ReadINIOption} $R3 "$R0" "${IO_TASK-DAILY-MODIFIER}"
   ${EndSelect}

   ; Create scheduled task
   nsExec::ExecTostack 'schtasks /tn "${PRODUCT_INTERNAL_NAME}" /create /ru system \
       /tr "\"$R1\fusioninventory-agent.bat\"" /sc $R2 /mo $R3'
   Pop $R4
   Pop $R5

   ; Pop $R5, $R4, $R3, $R2, $R1 & $R0 off of the stack
   Pop $R5
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


; GetFusionInventoryTaskSchedule
!define GetFusionInventoryTaskSchedule "!insertmacro GetFusionInventoryTaskSchedule"

!macro GetFusionInventoryTaskSchedule Frequency Modifier
   Call GetFusionInventoryTaskSchedule
   Pop ${Frequency}
   Pop ${Modifier}
!macroend

Function GetFusionInventoryTaskSchedule
   ${If} ${AtLeastWinVista}
      Call GetFusionInventoryTaskSchedule2_0
   ${Else}
      Call GetFusionInventoryTaskSchedule1_0
   ${EndIf}
FunctionEnd

; Get the agent's task schedule in systems with Task Scheduler 2.0
Function GetFusionInventoryTaskSchedule2_0
   ; TODO

   ; Clear errors
   ClearErrors

   Push 0
   Push "Unknown"

   SetErrors
FunctionEnd

; Get the agent's task schedule in systems with Task Scheduler 1.0
Function GetFusionInventoryTaskSchedule1_0
   ; $R0 API function's exit code
   ; $R1 ITaskScheduler object
   ; $R2 ITask object
   ; $R3 ITaskTrigger object
   ; $R4 TASK_TRIGGER struct
   ; $R5 Interval in minutes
   ; $R6 Trigger type
   ; $R7 Interval in days
   ; $R8 Frequency returned
   ; $R9 Frequency modifier returned

   ; Push $R9, $R8, $R0, $R1, $R2, $R3, $R4, $R5, $R6 & $R7 onto the stack
   Push $R9
   Push $R8
   Push $R0
   Push $R1
   Push $R2
   Push $R3
   Push $R4
   Push $R5
   Push $R6
   Push $R7

   ; Clear errors
   ClearErrors

   StrCpy $R9 "Unknown"
   StrCpy $R8 0

   !define GUIDITask "{148BD524-A2AB-11CE-B11F-00AA00530503}"
   !define GUIDTaskScheduler "{148BD52A-A2AB-11CE-B11F-00AA00530503}"
   !define GUIDITaskScheduler "{148BD527-A2AB-11CE-B11F-00AA00530503}"

   ; Get ITaskScheduler
   System::Call "ole32::CoCreateInstance(g '${GUIDTaskScheduler}',i 0, i 11, g '${GUIDITaskScheduler}', *i .R1) i.R0"

   ; Don't continue in case of error
   IntCmp $R0 0 0 Error

   ; ITaskScheduler->Activate(). Get reference to the task
   System::Call '$R1->6(w "${PRODUCT_INTERNAL_NAME}", g "${GUIDITask}", *i .R2) i.R0'

   ; Release ITaskScheduler
   System::Call '$R1->2() i'

   ; Don't continue in case of error
   IntCmp $R0 0 0 Error

   ; ITask->GetTrigger
   System::Call '$R2->6(i 0, *i .R3) i.R0'

   ; Release ITask
   System::Call '$R2->2() i'

   ; Don't continue in case of error
   IntCmp $R0 0 0 Error

   ; Struct to hold the trigger's properties
   System::Call "*(&l2, &v46) i.s"
   Pop $R4

   ; ITaskTrigger->GetTrigger
   System::Call '$R3->4(i R4 R4) i.R0'

   ; Get data from TASK_TRIGGER struct
   System::Call "*$R4(i2 .., i2 ..\
      &i2 .., &i2 .., &i2 .., \
      &i2 .., &i2 .., &i2 .., \
      &i2 .., &i2 .., \
      &i4 .., &i4 .R5, \
      &i4 .., \
      &i2 .R6, \
      &i2 .., &i2 .R7)"

   ; Free struct's memory
   System::Free $R4

   ; Don't continue in case of error
   IntCmp $R0 0 0 Error

   ${If} $R6 = 1 ; Trigger's type is daily even for hourly or minute frequency
      ${If} $R5 = 0
         StrCpy $R8 $R7
         StrCpy $R9 "${FREQUENCY_DAILY}"
      ${ElseIf} $R5 < 60
        StrCpy $R8 $R5
        StrCpy $R9 "${FREQUENCY_MINUTE}"
      ${Else}
        IntOp $R8 $R5 / 60
        StrCpy $R9 "${FREQUENCY_HOURLY}"
      ${EndIf}

      Goto End
   ${EndIf}

Error:
   SetErrors

End:
   ; Pop $R7, $R6, $R5, $R4, $R3, $R2, $R1 & $R0 off the stack
   Pop $R7
   Pop $R6
   Pop $R5
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0

   Exch $R8
   Exch
   Exch $R9
FunctionEnd


!endif
