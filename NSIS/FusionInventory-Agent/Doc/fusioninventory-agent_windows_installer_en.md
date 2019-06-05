% FusionInventory Agent Windows Installer 2.5.1\
  User's Guide
% Tomás Abad Gómez-Pastrana
% Jan 18, 2016

----------

# Synopsys

> `fusioninventory-agent_windows-x86_2.5.1.exe [/Option [/Option [...]]]`
>
> `fusioninventory-agent_windows-x64_2.5.1.exe [/Option [/Option [...]]]`
[^fiawi64]

[^fiawi64]: *`fusioninventory-agent_windows-x64_2.5.1.exe`* can only be
    installed on 64-bit (x86_64) systems.

# Description

FusionInventory Agent Windows Installer installs FusionInventory Agent
on Microsoft Windows operating systems[^acronyms].

It has two types of installation; the *from-scratch* type, that allows to
perform an installation of FusionInventory Agent from the beginning ---based on
the default values of [options](#command-line-options)--- and the
*from-current-config* type, that allows to perform an installation based on the
values of options of the current FusionInventory Agent present on the system,
whether it exists[^switch-to-from-scratch]. Besides these types of
installation, it also has two modes of installation; the *silent mode*, that
allows to perform the installation of FusionInventory Agent in a
non-interactive or unattended way, and the *visual mode*, that allows to
perform the installation of FusionInventory Agent in a graphical and
interactive way.

It is needed to bear in mind that, with independence of the type of
installation choosed, any existing release of FusionInventory Agent present on
the system will be uninstalled automatically just before installing
FusionInventory Agent. It is also noteworthy that, in the case of a
*from-current-config* installation, any deprecated option will not be taken
into account, and that any other change regarding options ---renaming,
splitting or grouping--- will be managed automatically.

[^acronyms]: *FusionInventory Agent* and  *FusionInventory Agent Windows
    Installer* are also known by the acronyms FIA and FIAWI respectively. The
    terms *FusionInventory Agent* and *FIA*, and *FusionInventory Agent Windows
    Installer* and *FIAWI* may be used interchangeably in this document.

[^switch-to-from-scratch]: If a *from-current-config* installation has been
    specified, and FIAWI has not been able to detect a previous FIA
    installation, the installation type is automatically switched from
    *from-current-config* to *from-scratch*.

# Where to achieve *FusionInventory Agent Windows Installer*?

It is possible to achieve FusionInventory Agent Windows Installer from
[GitHub] or [SourceForge].

# Using *FusionInventory Agent Windows Installer*

This section describes some of the most typical uses of FusionInventory Agent
Windows Installer.

# Command line options

FusionInventory Agent Windows Installer is provided with a series of options
that allows to adapt the installation to practically any environment or need.
To use these options properly is essential to know the order in which values
are taken into account. That order is as follows ---the higher the number, the
greater the priority---.

> 1. Default values
> 2. Values from the current FusionInventory Agent (whether it exists and only
>    in the case of *from-current-config* installation type)
> 3. Values from the command line (whether they exist)
> 4. Values from graphic user interface (only in the case of *graphic mode*
>    installation)

You should bear in mind the following when using the command line:

> * There are two types of options; those that act as a *Yes/No*, *On/Off* or
>   *True/False* switch (*`/option`*), and those that have a value
>   (*`/option=value`*)
> * The name of the options is case sensitive (`/html` is not the same that
>   `/HTML`)
> * The value of the options, unless otherwise specified, is not case sensitive
>   (`/local=C:\Temp` is the same that `/local=c:\temp`)
> * There should be no separation around the equal sign (`/local = c:\temp` is
>   incorrect)
> * Those values which contain a space, tabulator or the "`/`" character,
>   should go between single "`'`" or double "`"`" quotes
>   (`/local='C:\FusionInventory Agent'`)
> * An empty string is need to indicate an empty value (`/local=''` is correct,
>   `/local=` would generate an error)

The two following sections contain, on one hand, the [specific options of the
installer](#specific-options-of-the-installer) and, on the other hand, those
[options which change the FusionInventory Agent
behaviour](#specific-options-of-the-agent).

## Specific options of the installer

`/acceptlicense`{#acceptlicense}

:   You accept and acknowledge that you have read, and understood, the terms
    and conditions of the license. (By default: `No`)

    You must use this option if you perform the installation in *silent mode*
    (see [`/S`](#S)).

    If you indicate this option on the command line, but not the [`/S`](#S)
    option, the *visual mode* installation will omit any question about the
    license.

`/add-firewall-exception`{#add-firewall-exception}

:   Adds FusionInventory Agent to the Windows Firewall exception list.
    (By default: `Yes`)

`/no-firewall-exception`{#add-firewall-exception}

:   Avoids to add FusionInventory Agent to the Windows Firewall exception list.
    (By default: `No`)

`/ca-cert-uri`{#ca-cert-uri}=*URI*

:   *URI* from where to obtain the file or files of certificate of authorities
    (CA). (By default: `''`)

    The use of this option requires the joint use of the
    [`/ca-cert-dir`](#ca-cert-dir) or [`/ca-cert-file`](#ca-cert-file) options,
    but not both.

    *It is not implemented yet*.

`/dumphelp`{#dumphelp}

:   This option was deprecated in FusionInventory Agent Windows Installer
    2.3.13.

`/execmode`{#execmode}=*mode*

:   Sets the agent execution mode. (By default: `Current`)

    *mode* can be any of the following values:

    > `Service` [^Service]
    > :   The agent runs as a Windows Service
    >
    > `Task` [^Task]
    > :   The agent runs as a Windows Task
    >
    > `Manual` [^Manual]
    > :   The agent doesn't run automatically
    >
    > `Current` [^Current]
    > :   The agent runs in the same way that the agent already installed runs

    [^Service]: In *service* mode the agent runs constantly. The *service* mode
        is also known as *server* mode or *managed* mode.

    [^Task]: In *task* mode the agent runs at intervals. The *task* mode, also
        known as *half-managed* mode, is only available on Windows XP (or
        higher) and Windows Server 2003 (or higher) operating systems.

    [^Manual]: In *manual* mode the agent is not managed by the system, it is
        the user who decides when and how it will be run. The *manual* mode is
        also know as *non-managed* mode or *autonomous* mode.

    [^Current]: `Current` mode changes its behaviour in the case of an
        installation *from-scratch* (see [`/installtype`](#installtype)).  In
        that case, `Current` mode is a synonym of `Service`.

    When *mode* is `Service` or `Task`, FusionInventory Agent Windows Installer
    creates, respectively, a Windows Service called *FusionInventory-Agent* or
    a Windows Task called *FusionInventory-Agent*.

    For more information about the different uses of the agent, please, read
    [FusionInventory Agent Usage] in [FusionInventory] web site.

`/help`{#help}

:   This help. If the `/help` option is present, shows this help and aborts the
    installation.

`/installdir`{#installdir}=*pathname*

:   Sets the installation base directory of the agent. (By default:
    `%ProgramFiles%\FusionInventory-Agent`)

    *pathname* must be an absolute path.

`/installtasks`{#installtasks}={*task*[,*task*[...]] | *macro*}

:   Selects the tasks to install. (By default: `Default`)

    *task* can be any of the following values:

    > `Collect`
    > :   Collect task
    >
    > `Deploy`
    > :   Deploy task
    >
    > `ESX`
    > :   ESX task
    >
    > `Inventory`
    > :   Inventory task
    >
    > `NetDiscovery`
    > :   Network Discovery task
    >
    > `NetInventory`
    > :   Network Inventory task
    >
    > `WakeOnLan`
    > :   Wake on LAN task

    There are three macros defined to simplify the mission, they are the
    following:

    > `Minimal`
    > :   It is equivalent to `Inventory`
    >
    > `Default`
    > :   It is equivalent to `Inventory`
    >
    > `Full`
    > :   It is equivalent to
    >     `Collect`,`Deploy`,`ESX`,`Inventory`,`NetDiscovery`,`NetInventory`,
    >     `WakeOnLan`

    It should be noted that the `Inventory` task will be always installed and
    that the `NetDiscovery` and `NetInventory` tasks are inter-dependent.
    Nowadays `Minimal` and `Default` are the same configuration.

`/installtype`{#installtype}={`from-scratch` | `from-current-config`}

:   Selects between an installation from the beginning (`from-scratch`) or,
    whether the system has a previously installed agent, an installation based
    on the current configuration (`from-current-config`).  (By default:
    `from-current-config`)

    The installer automatically switches from `from-current-config` to
    `from-scratch` whether it's not able to detect a FusionInventory Agent
    previously installed on the system. This behaviour makes unnecesary to have
    to indicate `/installtype=from-scratch` to perform a FusionInventory Agent
    installation on those systems in which it doesn't exist previously and, at
    the same time, facillitates the update of FusionInventory Agent on those
    systems in which it exists.

`/no-start-menu`{#no-start-menu}

:   Do not create the *FusionInventory Agent* folder on the Start Menu.  (By
    default: `No`)

    The *FusionInventory Agent* folder, whether it is created, it is for all
    users.

`/runnow`{#runnow}

:   Launches the agent immediately[^runnow] after its installation. (By
    default: `No`)

[^runnow]: Actually it is not so *immediately*. Really, the agent is launched
    within 70 seconds following the end of the installer.

`/S`{#S}

:   Silent installation. (By default: `No`)

    You must accept the license in a explicit way if you perform the
    installation in silent mode (see [`/acceptlicense`](#acceptlicense)).

`/start-menu`{#start-menu}

:   This option is the opposite of `/no-start-menu`.

    See [`/no-start-menu`](#no-start-menu) for more information.

`/task-daily-modifier`{#task-daily-modifier}=*modifier*

:   Daily task schedule modifier. (By default: `1`)

    *modifier* can take values between 1 and 30 (days), both included.

    The `/task-daily-modifier` option has effect only if you have also
    indicated `Daily` as value of the [`/task-frequency`](#task-frequency)
    option.

`/task-frequency`{#task-frequency}=*frequency*

:   Frequency for task schedule. (By default: `Hourly`)

    *frequency* can be any of the following values:

    > `Minute`
    > :   At minute intervals
    >     (see option [`/task-minute-modifier`](#task-minute-modifier))
    >
    > `Hourly`
    > :   At hour intervals
    >     (see option [`/task-hourly-modifier`](#task-hourly-modifier))
    >
    > `Daily`
    > :   At day intervals
    >     (see option [`/task-daily-modifier`](#task-daily-modifier))

`/task-hourly-modifier`{#task-hourly-modifier}=*modifier*

:   Hourly task schedule modifier. (By default: `1`)

    *modifier* can take values between 1 and 23 (hours), both included.

    The `/task-hourly-modifier` option has effect only if you have also
    indicated `Hourly` as value of the [`/task-frequency`](#task-frequency)
    option.

`/task-minute-modifier`{#task-minute-modifier}=*modifier*

:   Minute task schedule modifier. (By default: `15`)

    *modifier* can take the following values: 15, 20 or 30 (minutes).

    The `/task-minute-modifier` option has effect only if you have also
    indicated `Minute` as value of the [`/task-frequency`](#task-frequency)
    option.

## Specific options of the agent

This set of options is actually a subset of FusionInventory Agent options to
which FusionInventory Agent Windows Installer adds some
others[^options-for-from-current-config] to be able to realize
*from-current-config* installations. It is interesting to note that, with the
exception of those added options, there is a direct relationship between the
names of FusionInventory Agent Windows Installer specific options for
FusionInventory Agent and the names of FusionInventory Agent options
---`/server` and `--server`, `/ca-cert-dir` and `--ca-cert-dir`, `/no-category`
and `--no-category`, etc.---, and that they are the only options used by
[*FusionInventory Agent*
configuration](#the-fusioninventory-agent-configuration). You can find more
information about how to configure and how to use FusionInventory Agent in
[FusionInventory Agent configuration], in [FusionInventory] web site.

[^options-for-from-current-config]: Options [`/httpd`](#httpd),
    [`/no-html`](#no-html), [`/no-scan-homedirs`](#no-scan-homedirs),
    [`/no-scan-profiles`](#no-scan-profiles), [`/p2p`](#p2p) and
    [`/ssl-check`](#ssl-check).

`/backend-collect-timeout`{#backend-collect-timeout}=*timeout*

:   Timeout for task `Inventory` modules execution. (By default: `180`)

    *timeout* is expressed in seconds.

`/ca-cert-dir`{#ca-cert-dir}=*pathname*

:   Absolute path to the standard certificate directory [^scd] of certificate
    authorities (CA). (By default: `''`)

    The use of this option is incompatible with the use of the
    [`/ca-cert-file`](#ca-cert-file) option.

    [^scd]: A *standard certificate directory* must contain the certificate
        files corresponding to different certificate authorities in Privacy
        Enhanced Mail (PEM) encoding, and their names must correspond to the
        hash value of the *subject* field of the certificate, with extension
        `*.0`.  

        For example, if you want to include the certificate file
        *FICert_Class1.crt*, in Distinguished Encoding Rules (DER) encoding, in
        the directory *pathname*, you must transform the file in PEM encoding
        using, for example, [OpenSSL] 

            C:\OpenSSL> openssl.exe x509 -in C:\FICert_Class1.crt -inform der -outform pem -out C:\FICert_class1.pem

        calculate the hash value of the *subject* field of the certificate

            C:\OpenSSL> openssl.exe x509 -in C:\FICert_Class1.pem -subject_hash -noout
            b760f1ce

        and afterwards, move or copy the certificate file to the directory
        *pathname* with the name `b760f1ce.0`.

           C:\OpenSSL> move.exe C:\FICert_Class1.pem <pathname>\b760f1ce.0

        See [x509(1)] for more information about the certificate display and
        signing utility of OpenSSL.

`/ca-cert-file`{#ca-cert-file}=*filename*

:   Full path to the certificates file of certification authorities (CA). (By default: `''`)

    *filename* must be in PEM (Privacy Enhanced Mail) encoding and its
    extension must be `*.pem`. Also, *filename* can contain one or more
    certificates of certificate authorities. [^cmf]

    The use of this option is incompatible with the use of the
    [`/ca-cert-dir`](#ca-cert-dir) option.

    [^cmf]: To concatenate multiple certificate files into one file you can
        make use of, for example, the *copy* command.

            C:\> copy.exe FICert_Class1.pem+FICert_Class2.pem FICerts.pem

`/conf-reload-interval`{#conf-reload-interval}=*frequency*

:   Frequency for configuration reloading. (By default: `0`)

    *frequency* can be any of the following values:

    > `0`
    > :   It disables configuration reloading.
    >
    > *`f`*
    > :   It sets configuration reloading each *`f`* seconds. The lower
    >     value for *`f`* is 60.

    The `/conf-reload-interval` option has effect only if FusionInventory Agent
    runs in *server mode* (see [`/execmode`](#execmode)).

    *frequency* is expressed in seconds.

`/debug`{#debug}=*level*

:   Sets the debug level of the agent. (By default: `0`)

    *level* can be any of the following values:

    > `0`
    > :   It records the basic process of FusionInventory Agent
    >
    > `1`
    > :   It records in depth the process of FusionInventory Agent
    >
    > `2`
    > :   It records communications of FusionInventory Agent with remote
    >     destinations (see [`/server`](#server))
    >
    > `3`
    > :   It records additional traces for some external Perl libraries (as
    >     *Net::SSLeay* and others)

    Note that higher values of *level* carry implicit the lower ones and that
    *level* `3` only has sense whether [`/logger`](#logger) is set to `Stderr`.

`/delaytime`{#delaytime}=*limit*

:   Sets an initial delay before first contact with a remote destination (By
    default: `3600`).

    This delay is calculated at random between *limit/2* and *limit* seconds.

    This option is ignored for remote destinations (see [`/server`](#server))
    after the first contact with each one, in favor of the specific server
    parameter (`PROLOG_FREQ`).

    The `/delaytime` option has effect only if FusionInventory Agent runs in
    *server mode* (see [`/execmode`](#execmode)).

    *limit* is expressed in seconds.

`/html`{#html}

:   Save the result of Inventory task as HTML instead of XML. (By default:
    `No`)

`/httpd`{#httpd}

:   This option is the opposite of `/no-httpd`.

    See [`/no-httpd`](#ho-httpd) for more information.

`/httpd-ip`{#httpd-ip}=*ip*

:   IP address by which the embedded web server should listen.  (By default:
    `0.0.0.0`)

`/httpd-port`{#httpd-port}=*port*

:   IP port by which the embedded web server should listen. (By default:
    `62354`)

`/httpd-trust`{#httpd-trust}={*ip* | *range* | *hostname*}[,{*ip* | *range* | *hostname*}[...]]

:   Trusted IP addresses that do not require authentication token by the
    integrated web server. (By default: `127.0.0.1/32`)

    Trusted IP addresses can be indicated in different ways[^net::ip]:

    > *ip*
    > :   It is an IP address in dot-decimal notation (ex. `'127.0.0.1'`) or in
    >     CIDR notation (ex. `'127.0.0.1/32'`)
    >
    > *range*
    > :   It is an IP address range in dot-decimal notation (ex. `'192.168.0.0
    >     - 192.168.0.255'` or `'192.168.0.0 + 255'`) or in CIDR notation (ex.
    >     `'192.168.0.0/24'`)
    >
    > *hostname*
    > :   It is a name of a host (ex. `'itms.acme.org'`)

    Bear in mind that `/httpd-trust` does not have to include the hostname part
    of those URIs that are set up in [`/server`](#server) because they are
    tacitly included. The following is an example; both configurations are
    equal[^bug#2190].

    > `/httpd-trust='127.0.0.1/32,itms.acme.org'`\
    > `/server='http://itms.acme.org/glpi/plugins/fusioninventory/'`
    >
    > `/httpd-trust='127.0.0.1/32'`\
    > `/server='http://itms.acme.org/glpi/plugins/fusioninventory/'`

    [^net::ip]: See [Net::IP] Perl module for more information.

    [^bug#2190]: If you are going to install FIA on a Windows XP operating
        system, the [bug #2190] force you to indicate the IP address of those
        servers that are present in [`/server`](#server) option. So you should
        indicate

        > `/httpd-trust='127.0.0.1/32,192.168.0.1/32'`\
        > `/server='http://itms.acme.org/glpi/plugins/fusioninventory/'`

        ---where `192.160.0.1/32` is the IP address of `itms.acme.org`
        server--- instead of

        > `/httpd-trust='127.0.0.1/32,itms.acme.org'`\
        > `/server='http://itms.acme.org/glpi/plugins/fusioninventory/'`

        or simply

        > `/httpd-trust='127.0.0.1/32'`\
        > `/server='http://itms.acme.org/glpi/plugins/fusioninventory/'`

`/local`{#local}=*pathname*

:   Writes the results of tasks execution into the given directory. (By
    default: `''`)

    You must indicate an absolute pathname or an empty string. If you indicate
    an empty string (`''`) ---the default value--- the results of tasks
    execution will not be written locally.

    You can use the `/local` and [`/server`](#server) options simultaneously.

`/logfile`{#logfile}=*filename*

:   Writes log messages into the file *filename*. (By default:
    `%ProgramFiles%\FusionInventory-Agent\logs\fusioninventory-agent.log`)

    You must indicate a full path in *filename*. The `/logfile` option has
    effect only if you have also indicated `File` as a value of the
    [`/logger`](#loger) option.  (See also [`/installdir`](#installdir))


`/logfile-maxsize`{#logfile-maxsize}=*size*

:   Sets the maximum size of the file indicated in [`/logfile`](#logfile) to
    *size*. (By default: `16`)

    *size* is expressed in MBytes.

`/logger`{#logger}=*backend*[,*backend*]

:   Sets the logger backends. (By default: `File`)

    *backend* can be any of the following values[^logger-syslog]:

    > `File`
    > :   Sends the log messages to a file (see [`/logfile`](#logfile))
    >
    > `Stderr`
    > :   Sends the log messages to console

   [^logger-syslog]: FIA also supports `Syslog` as *backend* but it is not
       sense on Windows operating systems.

`/no-category`{#no-category}=*category*[,*category*[...]]

:   Do not inventory the indicated categories of elements. (By default: `''`)

    *category* can be any of the following values:

    > `Antivirus`
    > :   For antivirus solutions (it has effect on Microsoft Windows systems only)
    >
    > `Battery`
    > :   For batteries
    >
    > `Controller`
    > :   For motherboard controllers
    >
    > `CPU`
    > :   For processors
    >
    > `Drive`
    > :   For unit drives
    >
    > `Environment`
    > :   For environment variables
    >
    > `Input`
    > :   For input devices (*keyboard*, *mouse*, *smart card reader*,
    >     *fingerprint scanner*, etc.)
    >
    > `LicenseInfo`
    > :   For software licenses
    >
    > `Local_Group`
    > :   For user's local groups
    >
    > `Local_User`
    > :   For local users
    >
    > `LVM`
    > :   For Logic Volume Manager (it has no effect on Microsoft Windows
    >     systems)
    >
    > `Memory`
    > :   For memory modules
    >
    > `Modem`
    > :   For modem devices
    >
    > `Monitor`
    > :   For monitors
    >
    > `Network`
    > :   For network devices
    >
    > `Port`
    > :   For ports
    >
    > `Printer`
    > :   For printers
    >
    > `Process`
    > :   For system processes
    >
    > `Remote_Mgmt`
    > :   For remote management solutions
    >
    > `Slot`
    > :   For slots
    >
    > `Software`
    > :   For software
    >
    > `Sound`
    > :   For sound subsystem
    >
    > `Storage`
    > :   For storage subsystem
    >
    > `USB`
    > :   For USB devices
    >
    > `User`
    > :   For users
    >
    > `Video`
    > :   For video devices
    >
    > `VirtualMachine`
    > :   For virtual machines

    If you indicate an empty string (`''`) ---the default value--- all
    categories of elements will be inventoried.

`/no-html`{#no-html}

:   This option is the opposite of `/html`.

    See [`/html`](#html) for more information.

`/no-httpd`{#no-httpd}

:   Disables the embedded web server. (By default: `No`)

`/no-p2p`

:   Do not use peer to peer to download files. (By default: `No`)

`/no-scan-homedirs`{#no-scan-homedirs}

:   This option is the opposite of `/scan-homedirs`.

    See [`/scan-homedirs`](#scan-homedirs) for more information.

`/no-scan-profiles`{#no-scan-profiles}

:   This option is the opposite of `/scan-profiles`.

    See [`/scan-profiles`](#scan-profiles) for more information.

`/no-ssl-check`{#no-ssl-check}

:   Do not check certificates of remote destinations. (By default: `No`)

    See [`/ca-cert-dir`](#ca-cert-dir), [`/ca-cert-file`](#ca-cert-file) and
    [`/server`](#server) for more information.

`/no-task`{#no-task}=*task*[,*task*[...]]

:   Disables the given tasks. (By default: `''`)

    *task* can be any of the following values:

    > `Collect`
    > :   Collect task
    >
    > `Deploy`
    > :   Deploy task
    >
    > `ESX`
    > :   ESX task
    >
    > `Inventory`
    > :   Inventory task
    >
    > `NetDiscovery`
    > :   Network Discovery task
    >
    > `NetInventory`
    > :   Network Inventory task
    >
    > `WakeOnLan`
    > :   Wake on LAN task

    If you indicate an empty string (`''`) ---the default value--- all tasks
    will be executed.

`/p2p`{#p2p}

:   This option is the opposite of `/no-p2p`.

    See [`/no-p2p`](#no-p2p) for more information.

`/password`{#password}=*password*

:   Uses *password* as password for authentication on remote destinations. (By
    default: `''`)

    The `/password` option has effect only if you have also indicated a value
    for the [`/server`](#server) option. (See also [`/user`](#user))

`/proxy`{#proxy}=*URI*

:   Uses *URI* as HTTP/S proxy server. (By default: `''`)

    The `/proxy` option has effect only if you have also indicated a value for
    the [`/server`](#server) option.

`/scan-homedirs`{#scan-homedirs}

:   Allows the agent to scan home directories for virtual machines.
    (By default: `No`)

`/scan-profiles`{#scan-profiles}

:   Allows the agent to scan user profiles for software. (By default: `No`)

    The `/scan-profiles` option has effect only on Windows operating
    systems[^roaming-profiles].

    [^roaming-profiles]: It is needed to bear in mind that `/scan-profiles` may
        cause problems in roaming user profiles. Please, see [bug #2555] for
        more information.

`/server`{#server}=*URI*[,*URI*[...]]

:   Sends results of tasks execution to given servers. (By default: `''`)

    If you indicate an empty string (`''`) ---the default value--- the results
    of tasks execution will not be written remotely.

    You can use the `/server` and [`/local`](#local) options simultaneously.

`/ssl-check`{#ssl-check}

:   This option is the opposite of `/no-ssl-check`.
    See [`/no-ssl-check`](#no-ssl-check) for more information.

`/tag`=*tag*

:   Marks the computer with the tag *tag* . (By default: `''`)

`/tasks`{#tasks}={*task*[,*task*[...]]}

:   It runs given tasks in given order. (By default: `''`)

    *task* can be any of the following values:

    > `Collect`
    > :   Collect task
    >
    > `Deploy`
    > :   Deploy task
    >
    > `ESX`
    > :   ESX task
    >
    > `Inventory`
    > :   Inventory task
    >
    > `NetDiscovery`
    > :   Network Discovery task
    >
    > `NetInventory`
    > :   Network Inventory task
    >
    > `WakeOnLan`
    > :   Wake on LAN task

    It is possible write `...` (three dots) at the end of the list as value
    of *task* as synonymous of *the rest of tasks*. Also, it should be noted
    that it is possible to indicate the same *task* more than once.

`/timeout`{#timeout}=*timeout*
:   Sets the limit time (in seconds) to connect with the server.
    (By default: `180`)

    The `/timeout` option has effect only if you have also indicated
    a value for the [`/server`](#server) option.

    *timeout* is expressed in MBytes.

`/user`{#user}=*user*

:   Uses *user* as user for authentication on remote destinations. (By default:
    `''`)

    The `/user` option has effect only if you have also indicated a value for
    the [`/server`](#server) option. (See also [`/password`](#password))

# Graphic user interface

This section describes the relation between the graphic user interface (GUI)
and the [command line options](#command-line-options).

*ToDo*

# The *FusionInventory Agent* configuration

FusionInventory Agent on Microsoft Windows operating systems reads, by default,
its configuration from the Windows Registry. That is the reason why
FusionInventory Agent Windows Installer creates in the Windows Registry the
following set of sub-keys to store the FusionInventory Agent configuration.
Values here indicated correspond to the default values (see [Specific options
of the agent](#specific-options-of-the-agent)).

        "backend-collect-timeout"="180"
        "ca-cert-dir"=""
        "ca-cert-file"=""
        "debug"="0"
        "delaytime"="3600"
        "html"="0"
        "httpd-ip"="0.0.0.0"
        "httpd-port"="62354"
        "httpd-trust"="127.0.0.1/32"
        "local"=""
        "logfile"="C:\\Program Files\\FusionInventory-Agent\\logs\\fusioninventory-agent.log"
        "logfile-maxsize"="16"
        "logger"="File"
        "no-category"=""
        "no-httpd"="0"
        "no-p2p"="0"
        "no-ssl-check"="0"
        "no-task"=""
        "password"=""
        "proxy"=""
        "server"=""
        "scan-homedirs"="0"
        "scan-profiles"="0"
        "tag"=""
        "timeout"="180"
        "user"=""

Changes in these sub-keys using, for example, [Regedit.exe], change the
behavior of the agent. It is needed to bear in mind that, if the agent is
running as a Windows Service (see [`/execmode`](#execmode)), it's necessary to
restart the *FusionInventory-Agent* Windows Service for those changes take
effect.

The key of the Windows Registry under which the previous ones are located
depends on two factors, the architecture of the Microsoft Windows OS and the
architecture of the FusionInventory Agent Windows Installer. These are the
possible combinations and its corresponding key.

  * Microsoft Windows OS 32-bit (x86)
    * FusionInventory Agent Windows Installer 32-bit (x86)

      > `HKEY_LOCAL_MACHINE\SOFTWARE\FusionInventory-Agent`

  * Microsoft Windows OS 64-bit (x86_64)
    * FusionInventory Agent Windows Installer 64-bit (x86_64)

      > `HKEY_LOCAL_MACHINE\SOFTWARE\FusionInventory-Agent`

    * FusionInventory Agent Windows Installer 32-bit (x86)

      > `HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\FusionInventory-Agent`

# Reporting bugs

If you want to report about a bug of FusionInventory Agent Windows Installer,
or you have an idea or suggestion about it, please, let us know about it using
any of these ways.

  * Mailing list of users

    <http://lists.alioth.debian.org/mailman/listinfo/fusioninventory-user>

  * Mailing list of developers

    <http://lists.alioth.debian.org/mailman/listinfo/fusioninventory-devel>

  * Forums of FusionInventory

    <http://forum.fusioninventory.org/index.php>

  * Issue area of FusionInventory Agent Windows Installer in GitHub

    <https://github.com/tabad/fusioninventory-agent-windows-installer/issues>


# See also

  * FusionInventory web site

    <http://www.fusioninventory.org>

  * FusionInventory Agent Windows Installer in GitHub

    <https://github.com/tabad/fusioninventory-agent-windows-installer>

  * FusionInventory Agent Windows Installer in SourceForge

    <http://sourceforge.net/projects/fiawi>

# Authors

Tomás Abad Gómez-Pastrana \<tabadgp@gmail.com\>

# Copyright

Copyright 2012-2015 FusionInventory Team. [GNU GPL version 2] or (at your
option) any later version. This is free software: you are free to change and
redistribute it. There is NO WARRANTY, to the extent permitted by law.




[bug #2190]: http://forge.fusioninventory.org/issues/2190
[bug #2555]: http://forge.fusioninventory.org/issues/2555
[FusionInventory]: http://www.fusioninventory.org/ "FusionInventory Web Site"
[FusionInventory Agent configuration]: http://fusioninventory.org/documentation/documentation/agent/configuration.html "FusionInventory Agent configuration"
[FusionInventory Agent Usage]: http://fusioninventory.org/documentation/documentation/agent/usage.html "FusionInventory Agent Usage"
[GitHub]: https://github.com/tabad/fusioninventory-agent-windows-installer/releases/
[GNU GPL version 2]: http://www.gnu.org/licenses/old-licenses/gpl-2.0-standalone.html
[Net::IP]: https://metacpan.org/pod/Net::IP#DESCRIPTION
[OpenSSL]: http://slproweb.com/products/Win32OpenSSL.html "OpenSSL for Windows"
[Regedit.exe]: https://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/tools_regeditors.mspx?mfr=true
[SourceForge]: http://sourceforge.net/projects/fiawi/files/
[x509(1)]: https://www.openssl.org/docs/apps/x509.html

