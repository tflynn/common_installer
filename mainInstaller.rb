#!/usr/bin/env jruby

TEST_ARGV=['--logfile', 'bootstrap_installer.log']

ENABLE_REMOTE_REQUIRE = true
REMOTE_REPOSITORIES = ['http://dl.dropbox.com/u/12189743/InstallationFiles/common_installer']
DEFAULT_LOG_FILE_NAME = 'bootstrap_installer.log'

#Load the module from a remote location
#This will fail in remote mode if the remote file is not present
def remoteRequire(moduleName)
  fullModuleName = %{#{moduleName}.rb}
  localCopy = File.exists?(fullModuleName)
  if ENABLE_REMOTE_REQUIRE and (not localCopy)
    cmd = %{wget #{REMOTE_REPOSITORIES.first}/#{fullModuleName}}
    fullCmd = %{#{cmd} > /dev/null 2>&1}
    targetDir = moduleName =~ /components\// ? 'components' : '.'
    success = false
    Dir.chdir(targetDir) do |dir|
      success = Kernel.system(fullCmd)
    end
    unless success
      puts(%{Error: File not found in remote repository #{REMOTE_REPOSITORIES.first}/#{moduleName}.rb . Exiting ... })
      return nil
    end
  end
  require(moduleName)
end


remoteRequire 'commandLine'
# remoteRequire 'osHelpers'
# remoteRequire 'logger'
# remoteRequire 'ioHelpers'
# remoteRequire 'core'
# 
# 
# Core.runInstaller()

if defined?(TEST_ARGV)
  puts "mainInstaller TEST_ARGV #{TEST_ARGV.inspect}"
  CommandLine.parseOptions(TEST_ARGV)
else
  CommandLine.parseOptions(ARGV)
end

