#!/usr/bin/env jruby

ENABLE_REMOTE_REQUIRE = true
REMOTE_REPOSITORIES = ['http://dl.dropbox.com/u/12189743/InstallationFiles/common_installer']
DEFAULT_LOG_FILE_NAME = 'bootstrap_installer.log'

#Load the module from a remote location
#This will fail in remote mode if the remote file is not present
def remoteRequire(moduleName)
  fullModuleName = %{#{moduleName}.rb}
  localCopy = File.exists?(fullModuleName)
  remoteRepository = REMOTE_REPOSITORIES.first
  fullModuleNameURI = "#{remoteRepository}/#{fullModuleName}"
  if ENABLE_REMOTE_REQUIRE and (not localCopy)
    cmd = %{wget #{fullModuleNameURI}}
    fullCmd = %{#{cmd} > /dev/null 2>&1}
    targetDir = moduleName =~ /components\// ? 'components' : '.'
    success = false
    Dir.chdir(targetDir) do |dir|
      success = Kernel.system(fullCmd)
    end
    unless success
      msg = %{Error: File #{fullModuleName} not found at fullModuleNameURI. Exiting ... }
      if Object.respond_to?(:logger)
        logger.error(msg)
      else
        puts(msg)
      end
      Kernel.exit(1)
    end
  end
  require(moduleName)
  logger.info(%{Obtaining #{fullModuleName} from #{fullModuleNameURI}}) unless localCopy
end

remoteRequire 'installerLogger'

remoteRequire 'commandLine'
remoteRequire 'osHelpers'
remoteRequire 'ioHelpers'
remoteRequire 'core'
remoteRequire 'buildHelper'

#puts "ARGV #{ARGV.inspect}"
Core.runInstaller

