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
   @file      .\FusionInventory Agent\Include\CommandLineParser.nsh
   @author    Tomas Abad <tabadgp@gmail.com>
   @copyright Copyright (c) 2010-2013 FusionInventory Team
   @license   GNU GPL version 2 or (at your option) any later version
              http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
   @since     2012

   ------------------------------------------------------------------------
*/


!ifndef __FIAI_COMMANDLINEPARSER_INCLUDE__
!define __FIAI_COMMANDLINEPARSER_INCLUDE__


!include FileFunc.nsh
!include LogicLib.nsh
!include WordFunc.nsh
!include "${FIAI_DIR}\Include\CommaUStrFunc.nsh"
!include "${FIAI_DIR}\Include\FileFunc.nsh"
!include "${FIAI_DIR}\Include\INIFunc.nsh"
!include "${FIAI_DIR}\Include\OptionChecks.nsh"
!include "${FIAI_DIR}\Include\StrFunc.nsh"
!include "${FIAI_DIR}\Include\WinTasksFunc.nsh"


; Define command line parser logfile
!define COMMANDLINE_PARSER_LOGFILE "$PLUGINSDIR\CommandLineParser.log"


; Global variables
Var CommandLineNotProcessed
Var CommandLineSyntaxError


; CommandLineSyntaxError
!macro _CommandLineSyntaxError _a _b _t _f
   Call GetCommandLineOptions
   !insertmacro _= $CommandLineSyntaxError 0 `${_t}` `${_f}`
!macroend

!define CommandLineSyntaxError `"" CommandLineSyntaxError ""`


; OutputCommandLineSyntaxError
!define OutputCommandLineSyntaxError "!insertmacro OutputCommandLineSyntaxError"
!macro OutputCommandLineSyntaxError
   FileOpen $0 "${COMMANDLINE_PARSER_LOGFILE}" r
   IfErrors done
   FileRead $0 $1
   ${Do}
      ${StdErr} "$1"
      FileRead $0 $1
   ${LoopUntil} ${Errors}
   FileClose $0
   done:
!macroend

; GetCommandLineOptions
!define CommandLineOptionsSearchBlock "!insertmacro CommandLineOptionsSearchBlock"

!macro CommandLineOptionsSearchBlock ParamToSearch ParamIntoINIFile
   ${If} $CommandLineSyntaxError = 1
   ${AndIf} $R0 != ""
      ${Do}
         ${FileWriteLine} $R9 "--------------------"

         StrCpy $R2 "${ParamToSearch}"
         StrCpy $R3 ""
         StrCpy $R4 "${ParamIntoINIFile}"

         ${FileWriteLine} $R9 "Searching for '$R2'..."
         ${GetOptionsS} "$R0" "$R2" $R3
         ${FileWriteLine} $R9 "GetOptionsS('$R0', '$R2'): '$R3'"

         ${IfNot} ${Errors}
            ${FileWriteLine} $R9 "...'$R2' found!"

            ; Remove the first occurrence of $R2$R3 from $R0
            ${WordReplace} "$R0" "$R2$R3" "" "+1" $R1
            ${If} "$R0" == "$R1"
               ${WordReplace} "$R0" "$R2$\'$R3$\'" "" "+1" $R1
               ${If} "$R0" == "$R1"
                  ${WordReplace} "$R0" "$R2$\"$R3$\""  "" "+1" $R1
                  ${If} "$R0" == "$R1"
                     ${WordReplace} "$R0" "$R2$\`$R3$\`"  "" "+1" $R1
                  ${EndIf}
               ${EndIf}
            ${EndIf}
            ${Trim} "$R1" $R0

            ${FileWriteLine} $R9 "New parameters (without '$R2[|$\'|$\"|$\`]$R3[$\`|$\"|$\'|]'): '$R0'"

            ; Check whether option $R2 already exist in Options.ini
            ${ReadINIOption} $R5 "$R8" "$R4"

            ${If} ${Errors}
               ; It's the first occurrence of $R2 into the command line

               ; Checks about $R3 below
               ; See examples inside 'GetCommandLineOptions' macro definition
!macroend


!define EndCommandLineOptionsSearchBlock "!insertmacro EndCommandLineOptionsSearchBlock"

!macro EndCommandLineOptionsSearchBlock
               ; After checks about $R3
               ; See examples inside 'GetCommandLineOptions' macro definition

               ; Write "$R4=$R3" into the section $R8 of the file Options.ini
               ${WriteINIOption} "$R8" "$R4" "$R3"

               ${FileWriteLine} $R9 "'$R4=$R3' written into the section [$R8] of the file '$PLUGINSDIR\Options.ini'"
            ${Else}
               ; It's the second occurrence of $R2 into the command line
               ; Syntax error. Only one occurrence is allowed
               StrCpy $CommandLineSyntaxError 0
               ${FileWriteLine} $R9 "Syntax error. Only one occurrence of '$R2' is allowed into the command line."
               ${Break}
            ${EndIf}

            ${If} "$R0" == ""
               ${Break}
            ${EndIf}
         ${Else}
            ${FileWriteLine} $R9 "...'$R2' not found."
            ${Break}
         ${EndIf}
      ${Loop}
   ${EndIf}
!macroend


!define GetCommandLineOptions "Call GetCommandLineOptions"

Function GetCommandLineOptions
   ; $R0 Command line parameters
   ; $R1 Command line parameters (auxiliary string)
   ; $R2 Option to search in command line parameters
   ; $R3 Option value in command line parameters
   ; $R4 Option to search in Options.ini
   ; $R5 Option value in Options.ini
   ;
   ; $R8 Options.ini section
   ; $R9 Command line parser logfile handle

   ; Check whether the command line options has been previously processed
   ${If} $CommandLineNotProcessed = 1
      ; The command line has been previously processed
      Return
   ${EndIf}

   ; Push $R0, $R1, $R2, $R3, $R4, $R5, $R8 & $R9 onto the stack
   Push $R0
   Push $R1
   Push $R2
   Push $R3
   Push $R4
   Push $R5
   Push $R8
   Push $R9

   ; Initialize syntax error flag
   StrCpy $CommandLineSyntaxError 1

   ; Set Options.ini file section
   StrCpy $R8 "${IOS_COMMANDLINE}"

   ; Create an empty command line parser logfile
   Delete "${COMMANDLINE_PARSER_LOGFILE}"
   FileOpen $R9 "${COMMANDLINE_PARSER_LOGFILE}" w

   ; Delete '$R8' section from Options.ini
   ${DeleteINIOptionSection} "$R8"

   ; Get command line parameters
   ${GetParameters} $R0

   ${FileWriteLine} $R9 "$$CMDLINE: '$CMDLINE'"
   ${FileWriteLine} $R9 "GetParameters(): '$R0'"

   ; Search for '/acceptlicense' option
   ${CommandLineOptionsSearchBlock} "/acceptlicense" "${IO_ACCEPTLICENSE}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/add-firewall-exception' option
   ${CommandLineOptionsSearchBlock} "/add-firewall-exception" "${IO_ADD-FIREWALL-EXCEPTION}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/backend-collect-timeout' option
   ${CommandLineOptionsSearchBlock} "/backend-collect-timeout=" "${IO_BACKEND-COLLECT-TIMEOUT}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionBackendCollectTimeoutValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${StdErr} "Wrong /backend-collect-timeout value: $R3"
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/ca-cert-dir' option
   ${CommandLineOptionsSearchBlock} "/ca-cert-dir=" "${IO_CA-CERT-DIR}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionCaCertDirValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/ca-cert-file' option
   ${CommandLineOptionsSearchBlock} "/ca-cert-file=" "${IO_CA-CERT-FILE}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionCaCertFileValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/ca-cert-uri' option
   ${CommandLineOptionsSearchBlock} "/ca-cert-uri=" "${IO_CA-CERT-URI}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionCaCertUriValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/conf-reload-interval' option
   ${CommandLineOptionsSearchBlock} "/conf-reload-interval=" "${IO_CONF-RELOAD-INTERVAL}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionConfReloadIntervalValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/debug' option
   ${CommandLineOptionsSearchBlock} "/debug=" "${IO_DEBUG}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionDebugValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/delaytime' option
   ${CommandLineOptionsSearchBlock} "/delaytime=" "${IO_DELAYTIME}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionDelaytimeValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/execmode' option
   ${CommandLineOptionsSearchBlock} "/execmode=" "${IO_EXECMODE}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionExecmodeValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/help' option
   ${CommandLineOptionsSearchBlock} "/help" "${IO_HELP}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/html' option
   ${CommandLineOptionsSearchBlock} "/html" "${IO_HTML}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/httpd-ip' option
   ${CommandLineOptionsSearchBlock} "/httpd-ip=" "${IO_HTTPD-IP}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionHttpdIpValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/httpd-port' option
   ${CommandLineOptionsSearchBlock} "/httpd-port=" "${IO_HTTPD-PORT}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionHttpdPortValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/httpd-trust' option
   ${CommandLineOptionsSearchBlock} "/httpd-trust=" "${IO_HTTPD-TRUST}"
      ; Wipe $R3
      ${AddCommaStrCommaUStr} "" "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionHttpdTrustValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/httpd' option
   ${CommandLineOptionsSearchBlock} "/httpd" "${IO_NO-HTTPD}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 0
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/installdir' option
   ${CommandLineOptionsSearchBlock} "/installdir=" "${IO_INSTALLDIR}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionInstalldirValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/installtasks' option
   ${CommandLineOptionsSearchBlock} "/installtasks=" "${IO_INSTALLTASKS}"
      ; Wipe $R3
      ${AddCommaStrCommaUStr} "" "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionInstalltasksValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/installtype' option
   ${CommandLineOptionsSearchBlock} "/installtype=" "${IO_INSTALLTYPE}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionInstalltypeValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/local' option
   ${CommandLineOptionsSearchBlock} "/local=" "${IO_LOCAL}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionLocalValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/logfile' option
   ${CommandLineOptionsSearchBlock} "/logfile=" "${IO_LOGFILE}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionLogfileValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/logfile-maxsize' option
   ${CommandLineOptionsSearchBlock} "/logfile-maxsize=" "${IO_LOGFILE-MAXSIZE}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionLogfileMaxsizeValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/logger' option
   ${CommandLineOptionsSearchBlock} "/logger=" "${IO_LOGGER}"
      ; Wipe $R3
      ${AddCommaStrCommaUStr} "" "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionLoggerValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-category' option
   ${CommandLineOptionsSearchBlock} "/no-category=" "${IO_NO-CATEGORY}"
      ; Wipe $R3
      ${AddCommaStrCommaUStr} "" "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionNoCategoryValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-html' option
   ${CommandLineOptionsSearchBlock} "/no-html" "${IO_HTML}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 0
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-httpd' option
   ${CommandLineOptionsSearchBlock} "/no-httpd" "${IO_NO-HTTPD}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-p2p' option
   ${CommandLineOptionsSearchBlock} "/no-p2p" "${IO_NO-P2P}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-scan-homedirs' option
   ${CommandLineOptionsSearchBlock} "/no-scan-homedirs" "${IO_SCAN-HOMEDIRS}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 0
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-scan-profiles' option
   ${CommandLineOptionsSearchBlock} "/no-scan-profiles" "${IO_SCAN-PROFILES}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 0
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-ssl-check' option
   ${CommandLineOptionsSearchBlock} "/no-ssl-check" "${IO_NO-SSL-CHECK}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-start-menu' option
   ${CommandLineOptionsSearchBlock} "/no-start-menu" "${IO_NO-START-MENU}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/no-task' option
   ${CommandLineOptionsSearchBlock} "/no-task=" "${IO_NO-TASK}"
      ; Wipe $R3
      ${AddCommaStrCommaUStr} "" "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionNoTaskValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/p2p' option
   ${CommandLineOptionsSearchBlock} "/p2p" "${IO_NO-P2P}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 0
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/password' option
   ${CommandLineOptionsSearchBlock} "/password=" "${IO_PASSWORD}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionPasswordValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/proxy' option
   ${CommandLineOptionsSearchBlock} "/proxy=" "${IO_PROXY}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionProxyValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/runnow' option
   ${CommandLineOptionsSearchBlock} "/runnow" "${IO_RUNNOW}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/scan-homedirs' option
   ${CommandLineOptionsSearchBlock} "/scan-homedirs" "${IO_SCAN-HOMEDIRS}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/scan-profiles' option
   ${CommandLineOptionsSearchBlock} "/scan-profiles" "${IO_SCAN-PROFILES}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 1
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/server' option
   ${CommandLineOptionsSearchBlock} "/server=" "${IO_SERVER}"
      ; Wipe $R3
      ${AddCommaStrCommaUStr} "" "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionServerValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/ssl-check' option
   ${CommandLineOptionsSearchBlock} "/ssl-check" "${IO_NO-SSL-CHECK}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 0
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/start-menu' option
   ${CommandLineOptionsSearchBlock} "/start-menu" "${IO_NO-START-MENU}"
      ; Wipe $R3
      ;    There should not be anything to wipe
      Nop

      ; Check $R3 domain
      ${If} "$R3" != ""
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
         ${Break}
      ${Else}
         ; Override $R3
         StrCpy $R3 0
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/tag' option
   ${CommandLineOptionsSearchBlock} "/tag=" "${IO_TAG}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionTagValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/tasks' option
   ${CommandLineOptionsSearchBlock} "/tasks=" "${IO_TASKS}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionTasksValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/task-daily-modifier' option
   ${CommandLineOptionsSearchBlock} "/task-daily-modifier=" "${IO_TASK-DAILY-MODIFIER}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionTaskDailyModifierValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/task-hourly-modifier' option
   ${CommandLineOptionsSearchBlock} "/task-hourly-modifier=" "${IO_TASK-HOURLY-MODIFIER}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionTaskHourlyModifierValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/task-frequency' option
   ${CommandLineOptionsSearchBlock} "/task-frequency=" "${IO_TASK-FREQUENCY}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionTaskFrequencyValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/task-minute-modifier' option
   ${CommandLineOptionsSearchBlock} "/task-minute-modifier=" "${IO_TASK-MINUTE-MODIFIER}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionTaskMinuteModifierValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/timeout' option
   ${CommandLineOptionsSearchBlock} "/timeout=" "${IO_TIMEOUT}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionTimeoutValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/user' option
   ${CommandLineOptionsSearchBlock} "/user=" "${IO_USER}"
      ; Wipe $R3
      ${Trim} "$R3" $R3

      ; Check $R3 domain
      ${IfNot} ${IsValidOptionUserValue} "$R3"
         ; Syntax error
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. The value '$R3' is not allowed."
         ${Break}
      ${EndIf}
   ${EndCommandLineOptionsSearchBlock}

   ; Search for '/S' option
   ${CommandLineOptionsSearchBlock} "/S" "${IO_SILENTMODE}"
               ; Wipe $R3
               ;    There should not be anything to wipe
               Nop

               ; Check $R3 domain
               ${If} "$R3" != ""
                  ; Syntax error
                  StrCpy $CommandLineSyntaxError 0
                  ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
                  ${Break}
               ${Else}
                  ; Override $R3
                  StrCpy $R3 1
               ${EndIf}

               ; Like ${EndCommandLineOptionsSearchBlock} but not exactly

               ; Write "$R4=$R3" into the section $R8 of the file Options.ini
               ${WriteINIOption} "$R8" "$R4" "$R3"

               ${FileWriteLine} $R9 "'$R4=$R3' written into the section [$R8] of the file '$PLUGINSDIR\Options.ini'"
            ${Else}
               ; It's the nth occurrence of $R2 into the command line
               ; It's allowed in this case
               Nop
            ${EndIf}

            ${If} "$R0" == ""
               ${Break}
            ${EndIf}
         ${Else}
            ${FileWriteLine} $R9 "...'$R2' not found."
            ${Break}
         ${EndIf}
      ${Loop}
   ${EndIf}

   ; Search for '/NCRC' option
   ${If} $CommandLineSyntaxError = 1
   ${AndIf} $R0 != ""
      ${Do}
         ${FileWriteLine} $R9 "--------------------"

         StrCpy $R2 "/NCRC"
         StrCpy $R3 ""
         StrCpy $R4 ""

         ${FileWriteLine} $R9 "Searching for '$R2'..."
         ${GetOptionsS} "$R0" "$R2" $R3
         ${FileWriteLine} $R9 "GetOptionsS('$R0', '$R2'): '$R3'"

         ${IfNot} ${Errors}
            ${FileWriteLine} $R9 "...'$R2' found!"

            ; Remove the first occurrence of $R2$R3 from $R0
            ${WordReplace} "$R0" "$R2$R3" "" "+1" $R1
            ${If} "$R0" == "$R1"
               ${WordReplace} "$R0" "$R2$\'$R3$\'" "" "+1" $R1
               ${If} "$R0" == "$R1"
                  ${WordReplace} "$R0" "$R2$\"$R3$\""  "" "+1" $R1
                  ${If} "$R0" == "$R1"
                     ${WordReplace} "$R0" "$R2$\`$R3$\`"  "" "+1" $R1
                  ${EndIf}
               ${EndIf}
            ${EndIf}
            ${Trim} "$R1" $R0

            ${FileWriteLine} $R9 "New parameters (without '$R2[|$\'|$\"|$\`]$R3[$\`|$\"|$\'|]'): '$R0'"

            ; Wipe $R3
            ;    There should not be anything to wipe
            Nop

            ; Check $R3 domain
            ${If} "$R3" != ""
               ; Syntax error
               StrCpy $CommandLineSyntaxError 0
               ${FileWriteLine} $R9 "Syntax error. '$R2' is a switch, it has no values."
               ${Break}
            ${EndIf}

            ${If} "$R0" == ""
               ${Break}
            ${EndIf}
         ${Else}
            ${FileWriteLine} $R9 "...'$R2' not found."
            ${Break}
         ${EndIf}
      ${Loop}
   ${EndIf}

   ${FileWriteLine} $R9 "--------------------"
   ${FileWriteLine} $R9 "End of command line parser"

   ; Trim
   ${Trim} "$R0" $R0

   ${If} $CommandLineSyntaxError = 1
      ${If} "$R0" != ""
         ; Syntax error. Invalid options
         StrCpy $CommandLineSyntaxError 0
         ${FileWriteLine} $R9 "Syntax error. Invalid options '$R0'."
      ${Else}
         ${FileWriteLine} $R9 "Syntax OK. All options have been recognized."
      ${EndIf}
   ${Else}
      ; Syntax Error
      ${FileWriteLine} $R9 "Syntax error. For more information see above."
   ${EndIf}

   ; Close the command line parser logfile
   FileClose $R9

   ; Set the flag of processed
   StrCpy $CommandLineNotProcessed 1

   ; Pop $R9, $R8, $R5, $R4, $R3, $R2, $R1 & $R0 off of the stack
   Pop $R9
   Pop $R8
   Pop $R5
   Pop $R4
   Pop $R3
   Pop $R2
   Pop $R1
   Pop $R0
FunctionEnd


!endif
