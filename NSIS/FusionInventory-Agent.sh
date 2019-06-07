#!/bin/bash
# ------------------------------------------------------------------------
# FusionInventory Agent Installer for Microsoft Windows
# Copyright (C) 2010-2017 by the FusionInventory Development Team.
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
# @file      .\NSIS\FusionInventory-Agent.sh
# @author    Tomas Abad <tabadgp@gmail.com>
#            Guillaume Bougard <gbougard@teclib.com>
# @copyright Copyright (c) 2010-2017 FusionInventory Team
# @license   GNU GPL version 2 or (at your option) any later version
#            http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
# @link      http://www.fusioninventory.org/
# @link      https://github.com/fusioninventory/fusioninventory-agent
# @since     2012
#
# ------------------------------------------------------------------------

# Load perl environment
source ../Perl/Scripts/load-perl-environment

declare -r installer_file='./fusioninventory-agent_windows-${arch}_*.exe'
declare -r nsis_log_level='3'
declare -r nsis_script='./FusionInventory-Agent.nsi'
declare -r nsis_log_file='./FusionInventory-Agent_MakeNSIS-Output-${arch}.txt'
declare -r help_file='./FusionInventory-Agent/Doc/fusioninventory-agent_windows_installer_${lang}.md'

declare arch=''
declare lang=''
declare digest=''
declare basename=''
declare installer=''
#declare -a -r archs=(x64 x86)
declare -a -r langs=(en es fr)
declare -a -r digests=(md5 sha1 sha256)

declare option_nsis_define=''
declare -r option_nsis_log_file="-O${nsis_log_file}"
declare -r option_nsis_log_level="-V${nsis_log_level}"


declare -r makensis=$(type -P makensis)
declare -r pandoc=$(type -P pandoc)
declare -r openssl=$(type -P openssl)
declare -r rm=$(type -P rm)

# Check the OS
if [ "${MSYSTEM}" = "MSYS" ]; then
   # Windows OS with MinGW/MSYS

   basename="${0##*\\}"
   option_nsis_define='-DPRODUCT_PLATFORM_ARCHITECTURE=${arch}'
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

   # Is NSIS installed?
   if [ ! -x "${makensis}" ]; then
      # NSIS is not installed

      echo
      echo 'It seems that NSIS is not installed into this system.'
      echo 'Please, install it and try again.'
      echo

      exit 2
   fi

   basename="${0##*/}"
   option_nsis_define='-DPRODUCT_PLATFORM_ARCHITECTURE=${arch}'
fi

# Check to select type checking fusinv_agent_commit
if [ -n "${TYPE}" ]; then
   if [ "$TYPE" == "development" ]; then
      option_nsis_define="$option_nsis_define -DFIAI_DEBUG_LEVEL=1"
   fi
elif [ -z "$( echo ${fusinv_agent_commit} | tr -d [0-9a-f] )" ]; then
   declare -r TYPE="development"
   option_nsis_define="$option_nsis_define -DFIAI_DEBUG_LEVEL=1"
elif [ -z "${fusinv_agent_commit##*-rc*}" ]; then
   declare -r TYPE="candidate"
   option_nsis_define="$option_nsis_define -DFIAI_DEBUG_LEVEL=1"
else
   declare -r TYPE="stable"
fi
option_nsis_define="$option_nsis_define -DPRODUCT_RELEASE_TYPE=$TYPE"

# Define required NSI variables
if [ -n "${strawberry_version}" ]; then
   option_nsis_define="$option_nsis_define -DSTRAWBERRY_RELEASE=${strawberry_version}"
else
   echo "ERROR: strawberry_version not set" >&2
   exit 1
fi
option_nsis_define="$option_nsis_define -DFIA_RELEASE=${fusinv_agent_release}"

read MAJOR MINOR SUB <<<"${fusinv_agent_release//./ }"
if [ -n "${MAJOR}" ]; then
   option_nsis_define="$option_nsis_define -DFIA_MAJOR=${MAJOR}"
else
   echo "ERROR: Can't read MAJOR version number" >&2
   exit 1
fi
if [ -n "${MINOR}" ]; then
   option_nsis_define="$option_nsis_define -DFIA_MINOR=${MINOR%%-*}"
else
   echo "ERROR: Can't read MINOR version number" >&2
   exit 1
fi

# Support numbering with empty or 'x' SUB as zero sub
[ -n "${SUB%x}" ] || SUB="0"
# Release number extacted from sub removing all chars with first '-'
option_nsis_define="$option_nsis_define -DFIA_SUB=${SUB%%-*}"
if [ "$TYPE" == "stable" ]; then
   # Use last number separated with '-'
   option_nsis_define="$option_nsis_define -DFIA_PATCH=${SUB##*-}"
elif [ "$TYPE" == "candidate" ]; then
   # Use last number separated after "-rc"
   RC="${fusinv_agent_release##*-rc}"
   FILERC="99$( printf '%02i' $RC )"
   option_nsis_define="$option_nsis_define -DFIA_RC=${RC} -DFIA_FILERC=${FILERC}"
fi

BUILD="$( printf '%i' $APPVEYOR_BUILD_NUMBER )"
option_nsis_define="$option_nsis_define -DFIAI_BUILD=${BUILD}"

# In the case fusinv_agent_commit is not set, use fusinv_agent_release as commit tag
if [ -n "${fusinv_agent_commit}" ]; then
   option_nsis_define="$option_nsis_define -DFIA_COMMIT=${fusinv_agent_commit}"
elif [ -n "${fusinv_agent_release}" ]; then
   option_nsis_define="$option_nsis_define -DFIA_COMMIT=${fusinv_agent_release}"
elif [ -n "${APPVEYOR_REPO_TAG_NAME}" ]; then
   option_nsis_define="$option_nsis_define -DFIA_COMMIT=${APPVEYOR_REPO_TAG_NAME}"
fi

# All seems be correct...

# Delete current installers
for arch in ${archs[@]}; do
   eval ${rm} -f "${nsis_log_file}" "${installer_file}" "${installer_file}.*" > /dev/null 2>&1
   ${rm} -f "*-portable.exe" > /dev/null 2>&1
done

# Delete current help files
for lang in ${langs[@]}; do
   eval ${rm} -f "${help_file%.md}.html" > /dev/null 2>&1
done

# Build help files
for lang in ${langs[@]}; do
   eval ${pandoc}                      \
      --normalize                      \
      --section-divs                   \
      --standalone                     \
      --smart                          \
      --tab-stop=3                     \
      --table-of-contents              \
      --toc-depth=3                    \
      --from markdown                  \
      --to html                        \
      --output "${help_file%.md}.html" \
      "${help_file}"
done

# Build installers
for arch in ${archs[@]}; do
   # Build ${arch} installer

   echo -n "Compilling ${arch} installer..."
   eval makensis ${option_nsis_log_level} \
                 ${option_nsis_log_file}  \
                 ${option_nsis_define}    \
                 ${nsis_script}

   if (( $? == 0 )); then
      echo '.Done!'

      # Digest calculation loop
      echo -n "Calculating digest message for ${arch} installer."
      for installer in "$(eval ls ${installer_file##*/})"; do
         for digest in "${digests[@]}"; do
            ${openssl} dgst -${digest} -c -out "${installer}.${digest}" "${installer}"
            echo -n "."
         done
      done
      echo ".Done!"
   else
      echo '.Failure!'
      eval echo " Please, read \'${nsis_log_file}\' for more information."
   fi
done

echo
