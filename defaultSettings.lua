#!/usr/bin/env luad
--[[

This file contains the default settings for all the components that the installation system knows about.

Any given setting or group of settings can be overridden by inserting the new settings in 'customSettings.lua' in the top level directory

For example, to override the default installation directory for the component 'apacheWebServer' specify 
'COMPONENT_OPTIONS.apacheWebServer.defaultInstallationDirectory=/usr/local/www' in 'customSettings.lua'.

]]

COMPONENT_NAMES = {'baseSystem' , 'dnsServer', 'apacheWebServer', 'php5' , 'mysql5' }

COMPONENT_OPTIONS =  {
  
  baseSystem = {
    name = 'Basic System',
    defaultInstallationDirectory = nil
  },
  
  dnsServer = {
    name = 'DHS Server',
    defaultInstallationDirectory = nil
  },
  
  apacheWebServer = {
    name = 'Apache Web Server' ,
    defaultInstallationDirectory = nil
  },
  
  php5 = {
    name = 'PHP 5' ,
    defaultInstallationDirectory = nil
  },
  
  nysql5 = {
    name = 'MySQL 5' ,
    defaultInstallationDirectory = nil
  },
  
  
}

PACKAGE_NAMES = {'dns'}

PACKAGE_OPTIONS = {
  
  dns = { name = "DNS Server" , components = { 'baseSystem' , 'apacheWebServer' , 'dnsServer' } },
      
}
