#!/usr/bin/env jruby

require 'fileutils'

remoteRequire 'installerLogger'
remoteRequire 'core'

class IOHelpers
  
  class << self
    
    def readFile(fileName,options = {})
      begin
        options = {:skipComments => true, :skipEmpty => true}.merge(options)
        rawLines = nil
        File.open(fileName) do |file|
          rawLines = file.readlines
        end
        lines = []
        rawLines.each do |rawLine|
          next if (rawLine =~ /^#/ and options[:skipComments])
          rawLine = rawLine.chomp.strip
          next if (rawLine == '' and options[:skipEmpty])
          lines << rawLine.chomp.strip
        end
        return lines
      rescue Exception => ex
        logger.error(%{IOHelpers.readFile for #{fileName} failed \n #{ex.to_s} \n #{ex.backtrace.join("\n")}})
        Core.errorExit
      end
    end

    def overwriteFile(fileName, contents, options = {})
      begin
        options = {:backupFile => true }.merge(options)
        if options[:backupFile]
          backupFile(fileName)
        end
        File.open(fileName,'w') do |file|
          if contents.kind_of? Array
            contents.each do |content|
              file.puts(content)
            end
          else
            file.write(contents)
          end
        end
      rescue Exception => ex
        logger.error(%{IOHelpers.overwriteFile for #{fileName} failed \n #{ex.to_s} \n #{ex.backtrace.join("\n")}})
        Core.errorExit
      end
    end
    
    def backupFile(fileName)
      begin
        dateTimeStamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
        backupFileName = "#{fileName}-#{dateTimeStamp}.bak"
        FileUtils.cp(fileName,backupFileName)
      rescue Exception => ex
        logger.error(%{IOHelpers.backupFile for #{fileName} failed \n #{ex.to_s} \n #{ex.backtrace.join("\n")}})
        Core.errorExit
      end
    end
    
    
    def readKeyboard
      return gets.chomp.strip
    end

    def readKeyboardWithPrompt(prompt)
      print(%{#{prompt}: })
      return readKeyboard
    end
  
    def readKeyboardWithPromptYesNo(prompt)
      while true
        print(%{#{prompt} [Y/N]: })
        response = readKeyboard
        if response =~ /^y.*/i 
          return true
        elsif response =~ /^n.*/i 
          return false
        end
      end
    end
    
  end

end
