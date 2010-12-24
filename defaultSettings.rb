#!/usr/bin/env jruby

require 'ostruct'

SYSTEM_SETTINGS = {}

SHELL_STARTUP_FILES = ['/etc/bashrc', '/etc/profile', '~/.bashrc' , '~/.bash_profile']

MENU_SEPARATOR = '----------'
BUILD_TYPE_GNU = 'gnu'

MENU_ORDER =  ['baseSystem' , 'dnsServer', 'apacheWebServer', MENU_SEPARATOR , 'php5' , 'mysql5' ]


COMPONENT_OPTIONS = OpenStruct.new

COMPONENT_OPTIONS.baseSystem = OpenStruct.new
COMPONENT_OPTIONS.baseSystem.name = "Basic System"
COMPONENT_OPTIONS.baseSystem.buildInstallationDirectory = nil
COMPONENT_OPTIONS.baseSystem.distributionGroup = nil
COMPONENT_OPTIONS.baseSystem.distributionFile = nil
COMPONENT_OPTIONS.baseSystem.componentDependencies = nil
COMPONENT_OPTIONS.baseSystem.compomentBuildType = nil

COMPONENT_OPTIONS.dnsServer = OpenStruct.new
COMPONENT_OPTIONS.dnsServer.name = "DHS Server (MaraDNS)"
COMPONENT_OPTIONS.dnsServer.buildInstallationDirectory = '/opt2'
COMPONENT_OPTIONS.dnsServer.distributionGroup = 'maradns'
COMPONENT_OPTIONS.dnsServer.distributionFile = nil
COMPONENT_OPTIONS.dnsServer.componentDependencies = nil
COMPONENT_OPTIONS.dnsServer.compomentBuildType = nil

COMPONENT_OPTIONS.apacheWebServer = OpenStruct.new
COMPONENT_OPTIONS.apacheWebServer.name = "Apache Web Server"
COMPONENT_OPTIONS.apacheWebServer.buildInstallationDirectory = nil
COMPONENT_OPTIONS.apacheWebServer.distributionGroup = nil
COMPONENT_OPTIONS.apacheWebServer.distributionFile = nil
COMPONENT_OPTIONS.apacheWebServer.componentDependencies = nil
COMPONENT_OPTIONS.apacheWebServer.compomentBuildType = BUILD_TYPE_GNU

COMPONENT_OPTIONS.php5 = OpenStruct.new
COMPONENT_OPTIONS.php5.name = "PHP5"
COMPONENT_OPTIONS.php5.buildInstallationDirectory = nil
COMPONENT_OPTIONS.php5.distributionGroup = nil
COMPONENT_OPTIONS.php5.distributionFile = nil
COMPONENT_OPTIONS.php5.componentDependencies = nil
COMPONENT_OPTIONS.php5.compomentBuildType = nil

COMPONENT_OPTIONS.mysql5 = OpenStruct.new
COMPONENT_OPTIONS.mysql5.name = "PHP 5 "
COMPONENT_OPTIONS.mysql5.buildInstallationDirectory = nil
COMPONENT_OPTIONS.mysql5.distributionGroup = nil
COMPONENT_OPTIONS.mysql5.distributionFile = nil
COMPONENT_OPTIONS.mysql5.componentDependencies = nil
COMPONENT_OPTIONS.mysql5.compomentBuildType = nil
