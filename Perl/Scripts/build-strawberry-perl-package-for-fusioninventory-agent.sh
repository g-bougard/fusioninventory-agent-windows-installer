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
# @file      .\Perl\Scripts\build-strawberry-perl-package-for-fusioninventory-agent.sh
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
declare tmpdir=''
declare mod_use=''
declare basename=''
declare base_path=''
declare fusinv_mod_uses=''

declare pp=''
declare perl=''
declare cpanm=''
declare dmake=''
declare windres=''
declare perl_path=''
declare cpanm_workpath=''

declare libdir=''
declare -i phase=1
declare src_path=''
declare src_file=''

declare digest=''
declare -a -r digests=(md5 sha1 sha256)

declare -r cat=$(type -P cat)
declare -r grep=$(type -P grep)
declare -r install=$(type -P install)
declare -r mktemp=$(type -P mktemp)
declare -r openssl=$(type -P openssl)
declare -r p7z=$(type -P 7z)
declare -r rm=$(type -P rm)
declare -r sed=$(type -P sed)
declare -r sort=$(type -P sort)
declare -r tar=$(type -P tar)
declare -r tr=$(type -P tr)
declare -r uniq=$(type -P uniq)

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

# Delete current package files
${rm} -f "${strawberry_pepfia_path}/${strawberry_pepfia_file}" \
         "${strawberry_pepfia_path}/${strawberry_pepfia_file}.txt" > /dev/null 2>&1

for digest in "${digests[@]}"; do
   ${rm} -f "${strawberry_pepfia_path}/${strawberry_pepfia_file}.${digest}" \
            "${strawberry_pepfia_path}/${strawberry_pepfia_file}.txt.${digest}" > /dev/null 2>&1
done

# Create temporal directory
tmpdir="$(${mktemp} -d --tmpdir=/tmp spepfia.XXXXXXXX)"

# Build Perl script file
fusinv_mod_uses="${fusinv_agent_mod_dependences}          \
                 ${fusinv_agent_mod_uses}                 \
                 ${fusinv_agent_mod_dependences_for_test} \
                 ${fusinv_agent_mod_uses_for_test}"
fusinv_mod_uses="$(echo ${fusinv_mod_uses} | \
                   ${tr} '[:space:]' '\n'  | \
                   ${sort} -i              | \
                   ${uniq}                 | \
                   ${tr} '\n' ' ')"

${cat} > "${tmpdir}/${strawberry_pepfia_par_template_file}" <<EndOfFile
use lib '.';
use lib 'lib';
use lib 'site/lib';
use lib 'vendor/lib';

$(for mod_use in ${fusinv_mod_uses}; do echo use ${mod_use}\;; done)

print "Welcome to FusionInventory!\n";
EndOfFile

# Workaround for 'threads' Perl module with StrawberryPerl v5.24.4.1
#
#   PAR::Packer shows this error when process 'threads' module:
#      <<Can't locate object method "tid" via package "threads" at ....>>
#
#   The workaround is remove 'threads' module from the previous file and
#   include it directly in the comand line of 'pp' comand widh '-M' option.
#
${sed} -i -e '/^\(use threads;\)$/s//# \1/' "${tmpdir}/${strawberry_pepfia_par_template_file}"

# Builder loop
while (( ${iter} < ${#archs[@]} )); do
   # Set arch and arch_label
   arch=${archs[${iter}]}
   arch_label=${arch_labels[${iter}]}

   # Add perl_path to PATH
   eval perl_path="$(pwd)/${strawberry_arch_path}/perl/site/bin:"
   eval perl_path="${perl_path}$(pwd)/${strawberry_arch_path}/perl/bin:"
   eval perl_path="${perl_path}$(pwd)/${strawberry_arch_path}/c/bin:"
   PATH="${perl_path}${PATH}"

   # Set perl, cpanm, dmake and windres
   perl=$(type -P perl)
   cpanm=$(type -P cpanm)
   dmake=$(type -P dmake)
   windres=$(type -P windres)

   # Remove temporary cpanm files
   eval ${rm} -rf "${strawberry_arch_path}/data/.cpanm" > /dev/null 2>&1

   # Install modules
   echo "Installing Strawberry Perl ${strawberry_release} (${strawberry_version}-${arch_label}s) modules..."
   ${perl} ${cpanm} --install --auto-cleanup 0 --no-man-pages --skip-installed --notest --quiet PAR::Packer

   # Check whether there is an error
   if (( $? != 0 )); then
      echo
      echo "There has been an error downloading 'PAR::Packer' Perl module."
      echo
      echo "Whether you are behind a proxy system, please, edit file"
      echo "'load-proxy-environment.bat', follow its instructions and try again."

      exit 4
   fi

   # Set pp
   pp=$(type -P pp)

   # Build the Perl ARchive (PAR) package
   echo "Building the Perl ARchive (PAR) package for Strawberry Perl ${strawberry_release} (${strawberry_version}-${arch_label}s)..."

   (eval cd "${strawberry_arch_path}"
    eval ${perl} ${pp} -p -B -c -u -M threads -o ${tmpdir}/${strawberry_pepfia_par_file} \
       "${tmpdir}/${strawberry_pepfia_par_template_file}" > ../../pp.log 2>&1
   )

   # Partial clean
   #    It seems "${tmpdir}/inc" is created when pp takes into account
   #    the Perl module inc::Module::Install
   ${rm} -rf "${tmpdir}/inc" > /dev/null 2>&1

   # Remove perl_path from PATH
   PATH="${PATH/${perl_path}/}"

   # Select files from Strawberry Perl distribution
   echo "Selecting files from Strawberry Perl ${strawberry_release} (${strawberry_version}-${arch_label}s)..."

   # Build structure
   ${install} --mode 0775 --directory "${tmpdir}/Strawberry/${strawberry_version}/${arch}/c/bin/startup/winnt/mingw"
   ${install} --mode 0775 --directory "${tmpdir}/Strawberry/${strawberry_version}/${arch}/cpan/sources"
   ${install} --mode 0775 --directory "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/bin"
   ${install} --mode 0775 --directory "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/lib"
   ${install} --mode 0775 --directory "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/packer/lib"
   ${install} --mode 0775 --directory "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/site/lib"
   ${install} --mode 0775 --directory "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/vendor/lib"

   # Extract PAR package files
   eval ${p7z} x -bd -y -o"${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/packer" \
      "${tmpdir}/${strawberry_pepfia_par_file}"                                            \
      "lib/*" > /dev/null 2>&1

   # Delete some innecesary PAR package files
   ${rm} -f "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/packer/lib/${strawberry_pepfia_par_template_file}" > /dev/null 2>&1

   # Partial clean
   eval ${rm} -f "${tmpdir}/${strawberry_pepfia_par_file}" > /dev/null 2>&1

   # Copy files
   eval ${install} "${strawberry_arch_path}/portable.perl" "${tmpdir}/Strawberry/${strawberry_version}/${arch}"
   eval ${install} "${strawberry_arch_path}/portableshell.bat" "${tmpdir}/Strawberry/${strawberry_version}/${arch}"
   eval ${install} "${strawberry_arch_path}/c/bin/dmake.exe" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/c/bin"
   eval ${install} "${strawberry_arch_path}/c/bin/libbz2-1*.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/c/bin"
   eval ${install} "${strawberry_arch_path}/c/bin/liblzma-5*.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/c/bin"
   eval ${install} "${strawberry_arch_path}/c/bin/libssl*.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/c/bin"
   eval ${install} "${strawberry_arch_path}/c/bin/libcrypto*.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/c/bin"
   eval ${install} "${strawberry_arch_path}/c/bin/zlib1*.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/c/bin"
   eval ${install} "${strawberry_arch_path}/perl/bin/perl{.exe,*.*.*.exe,*.dll}" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/bin"
   eval ${install} "${strawberry_arch_path}/perl/bin/pl2bat.bat" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/bin"
   eval ${install} "${strawberry_arch_path}/perl/bin/libstdc++-6.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/bin"
   eval ${install} "${strawberry_arch_path}/perl/bin/libgcc_s_*.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/bin"
   eval ${install} "${strawberry_arch_path}/perl/bin/libwinpthread-1.dll" "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/bin"

   # Select files
   phase=1
   for libdir in lib site/lib vendor/lib; do
      echo -n "Phase ${phase}/3>"
      eval src_path="${strawberry_arch_path}/perl"
      for src_file in $(find ${src_path}/${libdir} -type f); do
         src_file=${src_file#${src_path}/}

         ls -1 ${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/packer/lib/${src_file#${libdir}/} > /dev/null 2>&1
         if (( $? == 0 )); then
            install ${src_path}/${src_file} ${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/${src_file} > /dev/null 2>&1
            if (( $? != 0 )); then
               install -d ${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/${src_file%/*}
               install ${src_path}/${src_file} ${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/${src_file} > /dev/null 2>&1
            fi
            echo -n '.'
         fi
      done
      echo
      phase=$(( ${phase} + 1 ))
   done
   echo "Done!"

   # Partial clean
   ${rm} -rf "${tmpdir}/Strawberry/${strawberry_version}/${arch}/perl/packer" > /dev/null 2>&1

   eval base_path="${strawberry_arch_path}"
   base_path="${base_path#${strawberry_pepfia_path}/*}"

   # Package files
   echo -n "Packing Strawberry Perl ${strawberry_release} (${strawberry_version}-${arch_label}s)."
   ${tar} -r -f "${strawberry_pepfia_path}/${strawberry_pepfia_file%*.xz}" \
          -C "${tmpdir}/Strawberry"                                        \
          "${base_path}/portable.perl"                                     \
          "${base_path}/portableshell.bat"                                 \
          "${base_path}/c/bin/"                                            \
          "${base_path}/cpan/sources/"                                     \
          "${base_path}/perl/bin/"                                         \
          "${base_path}/perl/lib/"                                         \
          "${base_path}/perl/site/lib/"                                    \
          "${base_path}/perl/vendor/lib/" > /dev/null 2>&1
   echo ".Done!"

   # New architecture
   iter=$(( ${iter} + 1 ))
done

# Compressing
echo -n "Compressing package Strawberry Perl ${strawberry_release} (${strawberry_version}-32/64bits)."
${p7z} a -bd -mx=9 -- "${strawberry_pepfia_path}/${strawberry_pepfia_file}" \
                      "${strawberry_pepfia_path}/${strawberry_pepfia_file%*.xz}" > /dev/null 2>&1
echo -n "."
${rm} -f "${strawberry_pepfia_path}/${strawberry_pepfia_file%*.xz}" > /dev/null 2>&1
echo ".Done!"

# Build the description file
echo -n "Describing package Strawberry Perl ${strawberry_release} (${strawberry_version}-32/64bits)."
${cat} > "${strawberry_pepfia_path}/${strawberry_pepfia_file}.txt" <<EndOfFile
   The file '${strawberry_pepfia_file}' includes
Strawberry Perl ${strawberry_release} Portable Edition (${strawberry_version}-32/64bits) with all the
required and recommended Perl modules for:

      .- ${fusinv_agent_mod_name}-${fusinv_agent_commit}
EndOfFile

echo ".Done!"

# Digest calculation loop
echo -n "Calculating digest message files."
for digest in "${digests[@]}"; do
   (cd "${strawberry_pepfia_path}"; \
    ${openssl} dgst -${digest} -c -out "${strawberry_pepfia_file}.${digest}" "${strawberry_pepfia_file}")
   echo -n "."
   (cd "${strawberry_pepfia_path}"; \
    ${openssl} dgst -${digest} -c -out "${strawberry_pepfia_file}.txt.${digest}" "${strawberry_pepfia_file}.txt")
   echo -n "."
done
echo ".Done!"

# Delete temporal directory
${rm} -rf "${tmpdir}" > /dev/null 2>&1

# Done
echo "Package '${strawberry_pepfia_path}/${strawberry_pepfia_file}' built."

echo
