#!/usr/bin/env luad
--[[

This file contains the default settings for all the components that the installation system knows about.

Any given setting or group of settings can be overridden by inserting the new settings in 'customSettings.lua' in the top level directory

For example, to override the default installation directory for the component 'apacheWebServer' specify 
'COMPONENT_OPTIONS.apacheWebServer.defaultInstallationDirectory=/usr/local/www' in 'customSettings.lua'.

]]

SYSTEM_SETTINGS = {}

MENU_SEPARATOR = '----------'

MENU_ORDER =  { 'baseSystem' , 'dnsServer', 'apacheWebServer', MENU_SEPARATOR , 'php5' , 'mysql5' }

COMPONENT_OPTIONS =  {
  
  baseSystem = {
    name = 'Basic System',
    defaultInstallationDirectory = nil,
    componentDependencies = nil,
  },
  
  dnsServer = {
    name = 'DHS Server',
    defaultInstallationDirectory = nil ,
    componentDependencies = { 'baseSystem' , 'apacheWebServer' } ,
  },
  
  apacheWebServer = {
    name = 'Apache Web Server' ,
    defaultInstallationDirectory = nil ,
    componentDependencies = nil,
  },
  
  php5 = {
    name = 'PHP 5' ,
    defaultInstallationDirectory = nil ,
    componentDependencies = nil,
  },
  
  mysql5 = {
    name = 'MySQL 5' ,
    defaultInstallationDirectory = nil ,
    componentDependencies = nil,
  },
  
}
