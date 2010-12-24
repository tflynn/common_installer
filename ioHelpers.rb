#!/usr/bin/env jruby

class IOHelpers
  
  class << self
    
    def readFile(fileName)
      rawLines = nil
      File.open(fileName) do |file|
        rawLines = file.readlines
      end
      lines = []
      rawLines.each do |rawLine|
        lines << rawLine.chomp.strip
      end
      return lines
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