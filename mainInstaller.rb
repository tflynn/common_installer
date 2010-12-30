#!/usr/bin/env jruby

ENABLE_REMOTE_REQUIRE = true
REMOTE_REPOSITORIES = ['http://dl.dropbox.com/u/12189743/InstallationFiles']
DEFAULT_LOGFILE_NAME = 'bootstrap_installer.log'
DEFAULT_SETTINGS_FILE = 'defaultSettings'
CUSTOM_SETTINGS_FILE = 'customSettings'


#Load the module from a remote location
#This will fail in remote mode if the remote file is not present
def remoteRequire(moduleName)
  fullModuleName = %{#{moduleName}.rb}
  localCopy = File.exists?(fullModuleName)
  remoteRepository = REMOTE_REPOSITORIES.first
  fullModuleNameURI = "#{remoteRepository}/common_installer/#{fullModuleName}"
  if ENABLE_REMOTE_REQUIRE and (not localCopy)
    cmd = %{wget #{fullModuleNameURI}}
    fullCmd = %{#{cmd} > /dev/null 2>&1}
    targetDir = moduleName =~ /components\// ? 'components' : '.'
    success = false
    Dir.chdir(targetDir) do |dir|
      success = Kernel.system(fullCmd)
    end
    unless success
      msg = %{Error: File #{fullModuleName} not found at #{fullModuleNameURI}. Exiting ... }
      if Object.respond_to?(:logger)
        logger.error(msg)
      else
        puts(msg)
      end
      Kernel.exit(1)
    end
  end
  status = require(moduleName)
  unless localCopy
    logger.debug(%{Obtaining #{fullModuleName} from #{fullModuleNameURI}})
  end
  
  return status
  
end

remoteRequire 'installerLogger'
remoteRequire 'commandLine'
remoteRequire 'ioHelpers'
remoteRequire 'osHelpers'
remoteRequire 'core'
remoteRequire 'buildHelper'
remoteRequire 'networkHelper'

#puts "ARGV #{ARGV.inspect}"
Core.runInstaller

