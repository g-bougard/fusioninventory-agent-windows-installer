#!/bin/bash
# ------------------------------------------------------------------------
# FusionInventory Agent Installer for Microsoft Windows
# Copyright (C) 2010-2019 by the FusionInventory Development Team.
#
# http://www.fusioninventory.org/
# ------------------------------------------------------------------------
#
# LICENSE
#
# This file is part of FusionInventory project.
#
# FusionInventory Agent Installer for Microsoft Windows is free software;
# you can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.
#
#
# FusionInventory Agent Installer for Microsoft Windows is distributed in
# the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
# the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA,
# or see <http://www.gnu.org/licenses/>.
#
# ------------------------------------------------------------------------
#
# @package   FusionInventory Agent Installer for Microsoft Windows
# @file      .\NSIS\FusionInventory-Agent-Portable.sh
# @author    Tomas Abad <tabadgp@gmail.com>
#            Guillaume Bougard <gbougard at teclib.com>
# @copyright Copyright (c) 2010-2019 FusionInventory Team
# @license   GNU GPL version 2 or (at your option) any later version
#            http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
# @link      http://www.fusioninventory.org/
# @link      https://github.com/fusioninventory/fusioninventory-agent
# @since     2012
#
# ------------------------------------------------------------------------

# Load perl environment
source ../Perl/Scripts/load-perl-environment

declare -r installer="$1"

declare arch=''
declare digest=''
declare basename=''
declare -a -r digests=(md5 sha1 sha256)

declare -r openssl=$(type -P openssl)
declare -r rm=$(type -P rm)

# Check the OS
if [ "${MSYSTEM}" = "MSYS" ]; then
   # Windows OS with MinGW/MSYS

   basename="${0##*\\}"
else
   if [ -n "${WINDIR}" ]; then
      # It's a Windows OS

      basename="${0##*\\}"

      echo
      echo -n "You can not launch '${basename}' directly. "
      echo "Please, launch '${basename%.sh}.bat' instead."
      echo

      exit 1
   fi

   # It's a UNIX OS.

   basename="${0##*/}"
fi

if [ -z "$installer" -o ! -e "$installer" ]; then
   basename="${0##*\\}"

   echo
   echo -n "You can not launch '${basename}' directly without an installer as argument. "
   echo "Please, launch '${basename%.sh}.bat' instead."
   echo

   exit 2
fi

if [ ! -d "Portable/FusionInventory-Agent" ]; then
   basename="${0##*\\}"

   echo
   echo "Agent not installed at the expected place"
   echo
   echo "Please, launch '${basename%.sh}.bat' only after installers has been built."
   echo

   exit 3
fi

# All seems be correct...

# Extract arch from installer name
arch=${installer##*windows-}
arch=${arch%_*}

# Build installer related portable archive
echo -n "Building ${arch} portable archive..."

# Wait until agent is fully installed
let timeout=5*60
while [ ! -e "Portable/FusionInventory-Agent/share/usb.ids" ]; do
   sleep 1
   let --timeout
   (( timeout % 10 )) || echo -n
   (( timeout % 60 )) || echo
   if [ "$timeout" -eq "0" ]; then
      echo "Failed on a timeout"
      ls Portable/FusionInventory-Agent
      exit 5
   fi
done
# Wait a little more by security
sleep 5

# Cleanup
${rm} -f "Portable/FusionInventory-Agent/Uninstall.exe" > /dev/null 2>&1

# Add data dir
install --directory "Portable/FusionInventory-Agent/data"

# Update conf dir
install --directory "Portable/FusionInventory-Agent/etc/conf.d"
mv -f "Portable/FusionInventory-Agent/etc/agent.cfg.sample" "Portable/FusionInventory-Agent/etc/agent.cfg"
echo 'include "conf.d/"' >>"Portable/FusionInventory-Agent/etc/agent.cfg"

# Fix agent launcher to use config file
sed -i -e "s/perl\.exe fusioninventory-agent/perl.exe fusioninventory-agent --conf-file ..\\\\..\\\\etc\\\\agent.cfg/" \
   "Portable/FusionInventory-Agent/fusioninventory-agent.bat"

# Reset _confdir in Config.pm
sed -i -e "s|'_confdir' => .*$|'_confdir' => '../../etc',|" \
   "Portable/FusionInventory-Agent/perl/agent/FusionInventory/Agent/Config.pm"

# Fix to use relative path in setup.pm
sed -i -e "s|use lib.*$|use lib '../agent';|" -e "s|datadir.*$|datadir => '../../share',|" \
   -e "s|vardir.*$|vardir  => '../../var',|" -e "s|libdir.*$|libdir  => '../agent',|" \
   "Portable/FusionInventory-Agent/perl/lib/setup.pm"

( cd Portable ; 7z a -bd -sfx7z.sfx -stl -y "../${installer%.exe}-portable.exe" "FusionInventory-Agent" >../7z-${arch}-portable.txt 2>&1; )
if (( $? == 0 )); then
   echo '.Done!'

   # Digest calculation loop
   echo -n "Calculating digest message for ${arch} portable archive."
   for digest in "${digests[@]}"; do
      "${openssl}" dgst -${digest} -c -out "${installer%.exe}-portable.${digest}" "${installer%.exe}-portable.exe"
      echo -n "."
   done
   echo ".Done!"
else
   echo '.Failure!'
   echo " Failed to build ${arch} portable agent archive."
fi

${rm} -rf "Portable" > /dev/null 2>&1

echo
