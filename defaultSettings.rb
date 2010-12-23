#!/usr/bin/env jruby

SYSTEM_SETTINGS = {}

MENU_SEPARATOR = '----------'
BUILD_TYPE_GNU = 'gnu'

MENU_ORDER =  ['baseSystem' , 'dnsServer', 'apacheWebServer', MENU_SEPARATOR , 'php5' , 'mysql5' ]

COMPONENT_OPTIONS =  {
  
  'baseSystem' => {
    :name => 'Basic System',
    :buildInstallationDirectory => nil,
    :distributionGroup => nil,
    :distributionFile => nil,
    :componentDependencies => nil,
    :compomentBuildType => nil,
  },
  
  'dnsServer' => {
    :name => 'DHS Server',
    :buildInstallationDirectory => nil,
    :distributionGroup => nil,
    :distributionFile => nil,
    :componentDependencies => ['baseSystem' , 'apacheWebServer'],
    :compomentBuildType => nil,
  },
  
  'apacheWebServer' => {
    :name => 'Apache Web Server' ,
    :buildInstallationDirectory => nil,
    :distributionGroup => nil,
    :distributionFile => nil,
    :componentDependencies => nil,
    :compomentBuildType => BUILD_TYPE_GNU,
  },
  
  'php5' => {
    :name => 'PHP 5' ,
    :buildInstallationDirectory => nil,
    :distributionGroup => nil,
    :distributionFile => nil,
    :componentDependencies => nil,
    :compomentBuildType => nil,
  },
  
  'mysql5' => {
    :name => 'MySQL 5' ,
    :buildInstallationDirectory => nil,
    :distributionGroup => nil,
    :distributionFile => nil,
    :componentDependencies => nil,
    :compomentBuildType => nil,
  },
  
}
