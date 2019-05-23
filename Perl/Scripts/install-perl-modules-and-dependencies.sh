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
# @file      .\Perl\Scripts\install-perl-modules-and-dependencies.sh
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

declare perl=''
declare cpanm=''
declare perl_path=''

declare -i iter=0
declare basename=''
declare fusinv_mod_dependences=''
declare fusinv_mod_specific_dependences=''

declare -r rm=$(type -P rm)
declare -r sort=$(type -P sort)
declare -r tr=$(type -P tr)
declare -r uniq=$(type -P uniq)
declare -r find=$(type -P find)
declare -r cp=$(type -P cp)

# Check the OS
if [ "${MSYSTEM}" = "MSYS" ]; then
   # Windows OS with MinGW/MSYS

   basename="${0##*\\}"

   # Set terminal
   TERM=dumb

   # Avoid collisions with other perl stuff on your system
   unset PERL_JSON_BACKEND
   unset PERL_YAML_BACKEND
   unset PERL5LIB
   unset PERL5OPT
   unset PERL_MM_OPT
   unset PERL_MB_OPT

   # Avoid that Strawberry Perl Nov 2012 Portable Edition (5.16.2.1-32/64bits)
   # save cpanm temporary files in $HOME/.cpanm directory instead of in
   # $INSTALLDIR/data/.cpanm directory like Strawberry Perl Aug 2012 Portable
   # Edition (5.16.1.1-32/64bits) did.
   unset HOME
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

   echo
   echo "You should launch '${basename}' only from a Microsoft Windows OS."
   echo

   exit 2
fi

# Check whether Strawberry Perl ${strawberry_path} is already installed
if [ ! -d "${strawberry_path}" ]; then
   echo
   echo "Sorry but it seems that Strawberry Perl ${strawberry_release} (${strawberry_version}-32/64bits)"
   echo "is not installed into the '${strawberry_path}' directory."
   echo "Please, install it with 'install-strawberry-perl.bat' and try again."
   echo
   exit 3
fi

# Select perl modules to install
fusinv_mod_dependences="$(echo ${fusinv_agent_mod_dependences}            \
                               ${fusinv_agent_mod_dependences_for_test} | \
                        ${tr} '[:space:]' '\n'                          | \
                        ${sort} -i                                      | \
                        ${uniq}                                         | \
                        ${tr} '\n' ' ')"
fusinv_mod_dependences="${fusinv_mod_dependences% *}"

# Select perl specific modules to install
fusinv_mod_specific_dependences="$(echo ${fusinv_agent_mod_specific_dependences} | \
                                 ${tr} '[:space:]' '\n'                          | \
                                 ${sort} -i                                      | \
                                 ${uniq}                                         | \
                                 ${tr} '\n' ' ')"
fusinv_mod_specific_dependences="${fusinv_mod_specific_dependences% *}"

# Installation loop
while (( ${iter} < ${#archs[@]} )); do
   # Set arch and arch_label
   arch=${archs[${iter}]}
   arch_label=${arch_labels[${iter}]}

   # Add perl_path to PATH
   eval perl_path="$(pwd)/${strawberry_arch_path}/perl/site/bin:"
   eval perl_path="${perl_path}$(pwd)/${strawberry_arch_path}/perl/bin:"
   eval perl_path="${perl_path}$(pwd)/${strawberry_arch_path}/c/bin:"
   PATH="${perl_path}${PATH}"

   # Set perl and cpanm
   perl=$(type -P perl)
   cpanm=$(type -P cpanm)

   # Remove temporary cpanm files
   eval ${rm} -rf "$(pwd)/${strawberry_arch_path}/data/.cpanm" > /dev/null 2>&1

   # The process starts
   echo "Working with Strawberry Perl ${strawberry_release} (${strawberry_version}-${arch_label}s)..."

   # Copy netpcap downloaded from Teclib
   if [ -d "netpcap" ]; then
      eval ${cp} -av "netpcap/${arch}/*" "$(pwd)/${strawberry_arch_path}"
   fi

   # Update cpanm
   echo "Updating 'cpanm'..."
   ${perl} ${cpanm} --install --auto-cleanup 0 --no-man-pages --skip-installed --notest --quiet App::cpanminus

   # Install specific modules
   if [ -n "${fusinv_mod_specific_dependences}" ]; then
      echo "Installing specific modules..."
      ${perl} ${cpanm} --install --auto-cleanup 0 --no-man-pages --skip-installed --notest --quiet ${fusinv_mod_specific_dependences}
   fi

   # Install modules
   echo "Installing modules..."
   ${perl} ${cpanm} --install --auto-cleanup 0 --no-man-pages --skip-satisfied --notest ${fusinv_mod_dependences}
   echo

   # build.log can be used to debug cpanm install problems
   echo "Checking build logs..."
   eval ${find} "$(pwd)/${strawberry_arch_path}/data/.cpanm" -type f -name build.log
   echo "Keeping perl ${strawberry_version}-${arch_label}s modules build log..."
   eval ${cp} -av "$(pwd)/${strawberry_arch_path}/data/.cpanm/build.log" "$(pwd)/${strawberry_path}/../build-${arch_label}s.log"
   echo

   # Remove perl_path from PATH
   PATH="${PATH/${perl_path}/}"

   # New architecture
   iter=$(( ${iter} + 1 ))
done

echo
