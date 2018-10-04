#!/bin/bash
# ------------------------------------------------------------------------
# FusionInventory
# Copyright (C) 2010-2013 by the FusionInventory Development Team.
#
# http://www.fusioninventory.org/   http://forge.fusioninventory.org/
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
# @file      .\Perl\Scripts\patch-fusioninventory-agent.sh
# @author    Tomas Abad <tabadgp@gmail.com>
# @copyright Copyright (c) 2010-2013 FusionInventory Team
# @license   GNU GPL version 2 or (at your option) any later version
#            http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
# @link      http://www.fusioninventory.org/
# @link      http://forge.fusioninventory.org/projects/fusioninventory-agent
# @since     2012
#
# ------------------------------------------------------------------------


# Load perl environment
source ./load-perl-environment

declare -i iter=0
declare basename=''
declare base_path=''
declare script_suffix=''

declare -r cat=$(type -P cat)
declare -r tr=$(type -P tr)

# Check the OS
if [ "${MSYSTEM}" = "MSYS" ]; then
   # Windows OS with MinGW/MSYS

   basename="${0##*\\}"
   script_suffix='bat'
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
   script_suffix='sh'
fi

# Check whether Strawberry Perl ${strawberry_path} is already installed
if [ ! -d "${strawberry_path}" ]; then
   echo
   echo "Sorry but it seems that Strawberry Perl ${strawberry_release} (${strawberry_version}-32/64bits)"
   echo "is not installed into the '${strawberry_path}' directory."
   if [ "${MSYSTEM}" = "MSYS" ]; then
      # Windows OS with MinGW/MSYS
      echo "Please, install it with 'install-strawberry-perl.bat' or with"
      echo "'install-strawberry-perl-package-for-fusioninventory-agent.sh', and try again."
   else
      # UNIX OS
      echo "Please, install it with 'install-strawberry-perl-package-for-fusioninventory-agent.sh',"
      echo "and try it again."
   fi
   echo

   exit 3
fi

# Setup loop
while (( ${iter} < ${#archs[@]} )); do
   # Set arch and arch_label
   arch=${archs[${iter}]}
   arch_label=${arch_labels[${iter}]}

   # Get base_path
   eval base_path="${strawberry_arch_path}/cpan/sources/${fusinv_agent_mod_name}-${fusinv_agent_commit}"

   # Check whether 'install-fusioninventory-agent.${script_suffix}' was launched
   if [ ! -d "${base_path}" ]; then
      echo
      echo "Sorry but it seems that you didn't install FusionInventory-Agent ${fusinv_agent_commit} before."
      echo "Please, install it with 'install-fusioninventory-agent.${script_suffix}' and try again."
      echo

      break
   fi

   # Display task
   echo -n "Setting up FusionInventory-Agent ${fusinv_agent_commit} for Strawberry Perl ${strawberry_release} (${strawberry_version}-${arch_label}s)."

   # Updated version release ${base_path}/lib/FusionInventory/Agent/Version.pm
   # with version tag
   if [ -n "${fusinv_agent_release}" ]; then
      PACKAGE_TIME=$(LANG=C date -u)

      FIA_VERSION="${fusinv_agent_release}"
      if [ "${TYPE}" = "development" ]; then
         BUILD=${APPVEYOR_BUILD_NUMBER}
         : ${BUILD:=0000}
         FIA_VERSION="${fusinv_agent_release}-test-${BUILD}"
      fi
      : ${APPVEYOR_ACCOUNT_NAME:=$USERNAME}
      APPVEYOR_ACCOUNT_NAME="$( echo -n ${APPVEYOR_ACCOUNT_NAME:0:1} | ${tr} 'a-z' 'A-Z' )${APPVEYOR_ACCOUNT_NAME#?}"

      ${cat} >"${base_path}/lib/FusionInventory/Agent/Version.pm" <<HERE_VERSION
package FusionInventory::Agent::Version;

use strict;
use warnings;

our \$VERSION = "${FIA_VERSION}";
our \$PROVIDER = "FusionInventory";
our \$COMMENTS = [
    "Provided by ${APPVEYOR_ACCOUNT_NAME}",
    "Installer built with Appveyor on $PACKAGE_TIME"
];

1;
HERE_VERSION

      echo -n "."
   fi

   echo ".Done!"

   # New architecture
   iter=$(( ${iter} + 1 ))
done

echo
