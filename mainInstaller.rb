#!/usr/bin/env jruby

enableRemoteRequire = true
remoteRepository = ['http://dl.dropbox.com/u/12189743/InstallationFiles/common_installer']

#Load the module from a remote location
#This will fail in remote mode if the remote file is not present
def remoteRequire(moduleName)
  fullModuleName = %{#{moduleName}.rb}
  localCopy = File.exists?(fullModuleName)
  if enableRemoteRequire and (not localCopy)
    cmd = %{wget #{remoteRepository.first}/#{fullModuleName}}
    fullCmd = %{#{cmd} > /dev/null 2>&1}
    targetDir = moduleName =~ /components\// ? 'components' : '.'
    success = false
    Dir.chdir(targetDir) do |dir|
      success = Kernel.system(fullCmd)
    end
    unless success
      puts(%{Error: File not found in remote repository #{remoteRepository.first}/#{moduleName}.rb . Exiting ... })
      return nil
    end
  end
  require(moduleName)
end


# remoteRequire 'commandLine'
# remoteRequire 'osHelpers'
# remoteRequire 'logger'
# remoteRequire 'ioHelpers'
# remoteRequire 'core'
# 
# 
# Core.runInstaller()

puts "mainInstaller ARGV #{ARGV.inspect}"

