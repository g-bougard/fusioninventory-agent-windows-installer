:: ------------------------------------------------------------------------
:: FusionInventory
:: Copyright (C) 2010-2013 by the FusionInventory Development Team.
::
:: http://www.fusioninventory.org/   http://forge.fusioninventory.org/
:: ------------------------------------------------------------------------
::
:: LICENSE
::
:: This file is part of FusionInventory project.
::
:: FusionInventory Agent Installer for Microsoft Windows is free software;
:: you can redistribute it and/or modify it under the terms of the GNU
:: General Public License as published by the Free Software Foundation;
:: either version 2 of the License, or (at your option) any later version.
::
::
:: FusionInventory Agent Installer for Microsoft Windows is distributed in
:: the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
:: the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
:: PURPOSE. See the GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program; if not, write to the Free Software Foundation,
:: Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA,
:: or see <http://www.gnu.org/licenses/>.
::
:: ------------------------------------------------------------------------
::
:: @package   FusionInventory Agent Installer for Microsoft Windows
:: @file      .\Perl\Scripts\load-gnu-utilities-environment.bat
:: @author    Tomas Abad <tabadgp@gmail.com>
:: @copyright Copyright (c) 2010-2013 FusionInventory Team
:: @license   GNU GPL version 2 or (at your option) any later version
::            http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
:: @link      http://www.fusioninventory.org/
:: @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
:: @since     2012
::
:: ------------------------------------------------------------------------


@echo off

set MINGW_PATH=%SYSTEMDRIVE%\MinGW
set MSYS_PATH=%MINGW_PATH%\msys\1.0
set MSYSTEM=MSYS

set HOME=%USERPROFILE%
set USER=%USERNAME%
set HISTFILE=%HOME%

copy /y ..\..\Tools\7zip\x86\7z.exe "%TEMP%" > NUL
copy /y ..\..\Tools\7zip\x86\7z.dll "%TEMP%" > NUL
copy /y ..\..\Tools\Curl\x86\curl.exe "%TEMP%" > NUL
copy /y ..\..\Tools\Curl\x86\brotlidec.dll "%TEMP%" > NUL
copy /y ..\..\Tools\Curl\x86\brotlienc.dll "%TEMP%" > NUL
copy /y ..\..\Tools\Curl\x86\brotlicommon.dll "%TEMP%" > NUL
copy /y ..\..\Tools\Curl\x86\curl-ca-bundle.crt "%TEMP%" > NUL
copy /y ..\..\Tools\reimp\reimp.exe "%TEMP%" > NUL

setlocal enabledelayedexpansion
set LOCAL_PATH=%PATH%
set LOCAL_PATH=!LOCAL_PATH:%TEMP%;=!
if not "x%LOCAL_PATH%" == "x%PATH%" (
   set LOCAL_PATH=
) else (
   set LOCAL_PATH=%TEMP%;
)
endlocal & set PATH=%LOCAL_PATH%%PATH%
set LOCAL_PATH=

setlocal enabledelayedexpansion
set LOCAL_PATH=%PATH%
set LOCAL_PATH=!LOCAL_PATH:%MSYS_PATH%\bin;=!
if not "x%LOCAL_PATH%" == "x%PATH%" (
   set LOCAL_PATH=
) else (
   set LOCAL_PATH=%MSYS_PATH%\bin;
)
endlocal & set PATH=%LOCAL_PATH%%PATH%
set LOCAL_PATH=

setlocal enabledelayedexpansion
set LOCAL_PATH=%PATH%
set LOCAL_PATH=!LOCAL_PATH:%MINGW_PATH%\bin;=!
if not "x%LOCAL_PATH%" == "x%PATH%" (
   set LOCAL_PATH=
) else (
   set LOCAL_PATH=%MINGW_PATH%\bin;
)
endlocal & set PATH=%LOCAL_PATH%%PATH%
set LOCAL_PATH=
