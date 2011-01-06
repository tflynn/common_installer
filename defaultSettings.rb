#!/usr/bin/env jruby

require 'ostruct'

::SUCCESS = :success
::FAILURE = :failure

::SHELL_STARTUP_FILES = ['/etc/bashrc', '/etc/profile', '~/.bashrc' , '~/.bash_profile']

::DEFAULT_PATHS = ['/usr/local/sbin','/usr/local/bin','/sbin','/bin','/usr/sbin','/usr/bin']

::DEFAULT_BUILD_DIRECTORIES = ['bin','include','lib','man','share']

::MENU_SEPARATOR = '----------'

::MENU_ORDER =  ['baseSystem' , 'dnsServer', 'chefServer', 'chefClient' , MENU_SEPARATOR , 'readline6' , 'openssl']


::SYSTEM_SETTINGS = OpenStruct.new
::SYSTEM_SETTINGS.modify_shell_startup_file=true
::SYSTEM_SETTINGS.forceUTCClockLinux = true
::SYSTEM_SETTINGS.forceUTCClockOSX = false
::SYSTEM_SETTINGS.setPermanentHostName = true

::LOGGING_OPTIONS = OpenStruct.new
::LOGGING_OPTIONS.logLevel='DEBUG'
::LOGGING_OPTIONS.consoleLogging=false
::LOGGING_OPTIONS.logfile=::DEFAULT_LOGFILE_NAME

::COMPONENT_OPTIONS = OpenStruct.new

::COMPONENT_OPTIONS.baseSystem = OpenStruct.new
::COMPONENT_OPTIONS.baseSystem.name = "Basic System"
::COMPONENT_OPTIONS.baseSystem.enabled = false
::COMPONENT_OPTIONS.baseSystem.componentInstallerName = "baseSystem"
::COMPONENT_OPTIONS.baseSystem.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.baseSystem.distributionGroup = nil
::COMPONENT_OPTIONS.baseSystem.distributionFile = nil
::COMPONENT_OPTIONS.baseSystem.componentDependencies = nil
::COMPONENT_OPTIONS.baseSystem.forceReloadOnEveryRestart = false

::COMPONENT_OPTIONS.readline6 = OpenStruct.new
::COMPONENT_OPTIONS.readline6.name = "readline 6 (6.1)"
::COMPONENT_OPTIONS.readline6.componentInstallerName = "readline6"
::COMPONENT_OPTIONS.readline6.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.readline6.distributionGroup = 'readline'
::COMPONENT_OPTIONS.readline6.distributionFile = 'readline-6.1.tar.gz'
::COMPONENT_OPTIONS.readline6.componentDependencies = ['baseSystem']

# MaraDNS configuration
# ::COMPONENT_OPTIONS.dnsServer = OpenStruct.new
# ::COMPONENT_OPTIONS.dnsServer.name = "DNS Server (MaraDNS)"
#::COMPONENT_OPTIONS.dnsServer.componentInstallerName = "dnsServer"
# ::COMPONENT_OPTIONS.dnsServer.osSpecific = 'Linux'
# ::COMPONENT_OPTIONS.dnsServer.buildInstallationDirectory = '/opt2'
# ::COMPONENT_OPTIONS.dnsServer.distributionGroup = 'maradns'
# ::COMPONENT_OPTIONS.dnsServer.distributionFile = 'maradns-2.0.01.tar.bz2'
# ::COMPONENT_OPTIONS.dnsServer.componentDependencies = nil

# Primary OpenSSL configuration
::COMPONENT_OPTIONS.openssl = OpenStruct.new
::COMPONENT_OPTIONS.openssl.name = "OpenSSL (0.9.8q)"
::COMPONENT_OPTIONS.openssl.componentInstallerName = "openssl"
::COMPONENT_OPTIONS.openssl.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.openssl.distributionGroup = 'openssl'
::COMPONENT_OPTIONS.openssl.distributionFile = 'openssl-0.9.8q.tar.gz'
::COMPONENT_OPTIONS.openssl.componentDependencies = ['baseSystem','readline6']
::COMPONENT_OPTIONS.openssl.patchOSX64bitConfiguration=true
::COMPONENT_OPTIONS.openssl.patchOSXHeadersForRuby=false

# Bind configuration
::COMPONENT_OPTIONS.dnsServer = OpenStruct.new
::COMPONENT_OPTIONS.dnsServer.name = "DNS Server (Bind 9.7.2-P3)"
::COMPONENT_OPTIONS.dnsServer.componentInstallerName = "dnsServer"
::COMPONENT_OPTIONS.dnsServer.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.dnsServer.distributionGroup = 'bind'
::COMPONENT_OPTIONS.dnsServer.distributionFile = 'bind-9.7.2-P3.tar.gz'
::COMPONENT_OPTIONS.dnsServer.componentDependencies = ['baseSystem','readline6','openssl']

###
# Chef components
###

# Chef Client
::COMPONENT_OPTIONS.chefClient = OpenStruct.new
::COMPONENT_OPTIONS.chefClient.name = "Chef Client"
::COMPONENT_OPTIONS.chefClient.componentInstallerName = "chefClient"
::COMPONENT_OPTIONS.chefClient.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.chefClient.distributionGroup = 'chef'
::COMPONENT_OPTIONS.chefClient.distributionFile = ''
::COMPONENT_OPTIONS.chefClient.componentDependencies = ['baseSystem']

# Chef Server
::COMPONENT_OPTIONS.chefServer = OpenStruct.new
::COMPONENT_OPTIONS.chefServer.name = "Chef Server"
::COMPONENT_OPTIONS.chefServer.componentInstallerName = "chefServer"
::COMPONENT_OPTIONS.chefServer.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.chefServer.distributionGroup = 'chef'
::COMPONENT_OPTIONS.chefServer.distributionFile = ''
::COMPONENT_OPTIONS.chefServer.componentDependencies = ['baseSystem']

::COMPONENT_OPTIONS.apacheWebServer = OpenStruct.new
::COMPONENT_OPTIONS.apacheWebServer.name = "Apache Web Server"
::COMPONENT_OPTIONS.apacheWebServer.componentInstallerName = "apacheWebServer"
::COMPONENT_OPTIONS.apacheWebServer.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.apacheWebServer.distributionGroup = nil
::COMPONENT_OPTIONS.apacheWebServer.distributionFile = nil
::COMPONENT_OPTIONS.apacheWebServer.componentDependencies = ['baseSystem']

::COMPONENT_OPTIONS.php5 = OpenStruct.new
::COMPONENT_OPTIONS.php5.name = "PHP 5"
::COMPONENT_OPTIONS.php5.componentInstallerName = "php5"
::COMPONENT_OPTIONS.php5.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.php5.distributionGroup = nil
::COMPONENT_OPTIONS.php5.distributionFile = nil
::COMPONENT_OPTIONS.php5.componentDependencies = ['apacheWebServer']

::COMPONENT_OPTIONS.mysql5 = OpenStruct.new
::COMPONENT_OPTIONS.mysql5.name = "MYSQL 5"
::COMPONENT_OPTIONS.mysql5.componentInstallerName = "mysql5"
::COMPONENT_OPTIONS.mysql5.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.mysql5.distributionGroup = nil
::COMPONENT_OPTIONS.mysql5.distributionFile = nil
::COMPONENT_OPTIONS.mysql5.componentDependencies = ['baseSystem']
