#!/usr/bin/env luad
--[[

This file contains the default settings for all the components that the installation system knows about.

Any given setting or group of settings can be overridden by inserting the new settings in 'customSettings.lua' in the top level directory

For example, to override the default installation directory for the component 'apacheWebServer' specify 
'COMPONENT_OPTIONS.apacheWebServer.buildInstallationDirectory=/usr/local/www' in 'customSettings.lua'.

]]

SYSTEM_SETTINGS = {}

MENU_SEPARATOR = '----------'
BUILD_TYPE_GNU = 'gnu'

MENU_ORDER =  { 'baseSystem' , 'dnsServer', 'apacheWebServer', MENU_SEPARATOR , 'php5' , 'mysql5' }

COMPONENT_OPTIONS =  {
  
  baseSystem = {
    name = 'Basic System',
    buildInstallationDirectory = nil,
    distributionGroup = nil,
    distributionFile = nil,
    componentDependencies = nil,
    compomentBuildType = nil,
  },
  
  dnsServer = {
    name = 'DHS Server',
    buildInstallationDirectory = nil ,
    distributionGroup = nil,
    distributionFile = nil,
    componentDependencies = { 'baseSystem' , 'apacheWebServer' } ,
    compomentBuildType = nil,
  },
  
  apacheWebServer = {
    name = 'Apache Web Server' ,
    buildInstallationDirectory = nil ,
    distributionGroup = nil,
    distributionFile = nil,
    componentDependencies = nil,
    compomentBuildType = BUILD_TYPE_GNU,
  },
  
  php5 = {
    name = 'PHP 5' ,
    buildInstallationDirectory = nil ,
    distributionGroup = nil,
    distributionFile = nil,
    componentDependencies = nil,
    compomentBuildType = nil,
  },
  
  mysql5 = {
    name = 'MySQL 5' ,
    buildInstallationDirectory = nil ,
    distributionGroup = nil,
    distributionFile = nil,
    componentDependencies = nil,
    compomentBuildType = nil,
  },
  
}
