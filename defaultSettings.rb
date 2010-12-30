#!/usr/bin/env jruby

require 'ostruct'

::SUCCESS = :success
::FAILURE = :failure

::SHELL_STARTUP_FILES = ['/etc/bashrc', '/etc/profile', '~/.bashrc' , '~/.bash_profile']

::DEFAULT_PATHS = ['/usr/local/sbin','/usr/local/bin','/sbin','/bin','/usr/sbin','/usr/bin']

::DEFAULT_BUILD_DIRECTORIES = ['bin','include','lib','man','share']

::MENU_SEPARATOR = '----------'

::MENU_ORDER =  ['baseSystem' , 'apacheWebServer', MENU_SEPARATOR , 'readline6' , 'openssl']


::SYSTEM_SETTINGS = OpenStruct.new

::LOGGING_OPTIONS = OpenStruct.new
::LOGGING_OPTIONS.logLevel='DEBUG'
::LOGGING_OPTIONS.consoleLogging=true
::LOGGING_OPTIONS.fileLogging=true
::LOGGING_OPTIONS.logfile=::DEFAULT_LOGFILE_NAME

::COMPONENT_OPTIONS = OpenStruct.new

::COMPONENT_OPTIONS.baseSystem = OpenStruct.new
::COMPONENT_OPTIONS.baseSystem.name = "Basic System"
::COMPONENT_OPTIONS.baseSystem.componentInstallerName = "baseSystem"
::COMPONENT_OPTIONS.baseSystem.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.baseSystem.distributionGroup = nil
::COMPONENT_OPTIONS.baseSystem.distributionFile = nil
::COMPONENT_OPTIONS.baseSystem.componentDependencies = nil

::COMPONENT_OPTIONS.readline6 = OpenStruct.new
::COMPONENT_OPTIONS.readline6.name = "readline 6"
::COMPONENT_OPTIONS.readline6.componentInstallerName = "readline6"
::COMPONENT_OPTIONS.readline6.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.readline6.distributionGroup = 'readline'
::COMPONENT_OPTIONS.readline6.distributionFile = 'readline-6.1.tar.gz'
::COMPONENT_OPTIONS.readline6.componentDependencies = nil

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
::COMPONENT_OPTIONS.openssl.name = "OpenSSL"
::COMPONENT_OPTIONS.openssl.componentInstallerName = "openssl"
::COMPONENT_OPTIONS.openssl.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.openssl.distributionGroup = 'openssl'
::COMPONENT_OPTIONS.openssl.distributionFile = 'openssl-0.9.8q.tar.gz'
::COMPONENT_OPTIONS.openssl.componentDependencies = ['readline6']
::COMPONENT_OPTIONS.openssl.patchOSX64bitConfiguration=true
::COMPONENT_OPTIONS.openssl.patchOSXHeadersForRuby=false

# Bind configuration
::COMPONENT_OPTIONS.dnsServer = OpenStruct.new
::COMPONENT_OPTIONS.dnsServer.name = "DNS Server (Bind)"
::COMPONENT_OPTIONS.dnsServer.componentInstallerName = "dnsServer"
::COMPONENT_OPTIONS.dnsServer.buildInstallationDirectory = '/opt2'
::COMPONENT_OPTIONS.dnsServer.distributionGroup = 'bind'
::COMPONENT_OPTIONS.dnsServer.distributionFile = 'bind-9.7.2-P3.tar.gz'
::COMPONENT_OPTIONS.dnsServer.componentDependencies = ['readline6','openssl']

::COMPONENT_OPTIONS.apacheWebServer = OpenStruct.new
::COMPONENT_OPTIONS.apacheWebServer.name = "Apache Web Server"
::COMPONENT_OPTIONS.apacheWebServer.componentInstallerName = "apacheWebServer"
::COMPONENT_OPTIONS.apacheWebServer.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.apacheWebServer.distributionGroup = nil
::COMPONENT_OPTIONS.apacheWebServer.distributionFile = nil
::COMPONENT_OPTIONS.apacheWebServer.componentDependencies = nil

::COMPONENT_OPTIONS.php5 = OpenStruct.new
::COMPONENT_OPTIONS.php5.name = "PHP 5"
::COMPONENT_OPTIONS.php5.componentInstallerName = "php5"
::COMPONENT_OPTIONS.php5.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.php5.distributionGroup = nil
::COMPONENT_OPTIONS.php5.distributionFile = nil
::COMPONENT_OPTIONS.php5.componentDependencies = nil

::COMPONENT_OPTIONS.mysql5 = OpenStruct.new
::COMPONENT_OPTIONS.mysql5.name = "MYSQL 5"
::COMPONENT_OPTIONS.mysql5.componentInstallerName = "mysql5"
::COMPONENT_OPTIONS.mysql5.buildInstallationDirectory = nil
::COMPONENT_OPTIONS.mysql5.distributionGroup = nil
::COMPONENT_OPTIONS.mysql5.distributionFile = nil
::COMPONENT_OPTIONS.mysql5.componentDependencies = nil
