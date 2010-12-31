#!/usr/bin/env jruby

# This class is called 'installationLogger' to avoid naming conflict with 'logger' provided in the standard library
# It is written to have no dependencies - so it may be loaded independently of any others
::DEFAULT_LOGFILE_NAME = 'bootstrap_installer.log' unless defined?(::DEFAULT_LOGFILE_NAME)
::CUSTOM_SETTINGS_FILE = 'customSettings' unless defined?(::CUSTOM_SETTINGS_FILE)

class InstallerLogger
  
  LEVEL_TRACE=0
  LEVEL_DEBUG=1
  LEVEL_INFO=2
  LEVEL_WARN=3
  LEVEL_ERROR=4
  LEVEL_FATAL=5

  LEVELS_TEXT = ['TRACE', 'DEBUG' , 'INFO', 'WARN', 'ERROR', 'FATAL']

  attr_reader :consoleLogging
  
  def initialize
    begin
      @currentLogLevel = LEVEL_DEBUG
      @currentFileName = File.expand_path(::DEFAULT_LOGFILE_NAME)
      @consoleLogging = true
      
      processCustomSettings
      processCommandLineOptions

    rescue Exception => ex
      puts %{Error: installerLogger failed to initialize correctly. Leaving ... \n#{ex.to_s} \n #{ex.backtrace.join("\n")}}
      Kernel.exit(1)
    end
  end

  # Load custom settings locally just for logging initialization
  def processCustomSettings
    if File.exists?(::CUSTOM_SETTINGS_FILE)
      customSettings = IO.read(::CUSTOM_SETTINGS_FILE)
      customSettings = customSettings.split("\n")
      customSettings.each do |customSetting|
        if customSetting =~ /^\:\:LOGGING_OPTIONS\./
          setting, value = customSetting.split('=')
          setting = setting.chomp.strip.sub('::LOGGING_OPTIONS.','')
          value = value.chomp.strip
          if setting == 'logLevel'
            value = value.upcase.gsub(/\'/,'')
            level = LEVELS_TEXT.index(value.upcase)
            @currentLogLevel = level if level
          elsif setting == 'consoleLogging'
            @consoleLogging = value.downcase == 'true'
          elsif setting == 'logfile'
            @currentFileName = File.expand_path(value)
          end
        end
      end
    end
  end

  # Parse command line options just for logging initialization
  def processCommandLineOptions
    if ARGV
      ARGV.each do |arg|
        if arg.index('=')
          setting, value = arg.split('=')
          setting = setting.chomp
          value = value.chomp.strip
          if setting == 'logLevel'
            value = value.upcase.gsub(/\'/,'')
            level = LEVELS_TEXT.index(value.upcase)
            @currentLogLevel = level if level
          elsif setting == 'consoleLogging'
            @consoleLogging = value.downcase == 'true'
          elsif setting == 'logfile'
            @currentFileName = File.expand_path(value)
          end
        end
      end
    end
  end
  
  def setFileName(fileName)
    @currentFileName = fileName
  end

  def getFileName
    return @currentFileName
  end

  def setTrace
    @currentLogLevel = LEVEL_TRACE
  end

  def setDebug
    @currentLogLevel = LEVEL_DEBUG
  end

  def setInfo
    @currentLogLevel = LEVEL_INFO
  end

  def setWarn
    @currentLogLevel = LEVEL_WARN
  end

  def setError
    @currentLogLevel = LEVEL_ERROR
  end

  def setFatal()
    @currentLogLevel = LEVEL_FATAL
  end


  def msg(levelText, msg)
    timeStamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    fullMsg = %{#{timeStamp} #{levelText}: #{msg}}
    if @consoleLogging
      puts(fullMsg)
    end
    File.open(getFileName,'a') do |logfile|
      logfile.puts(fullMsg)
    end
    return true
  end

  def logMsgAboveLogLevel(logLevel,msg)
    if @currentLogLevel <= logLevel
      levelText = LEVELS_TEXT[logLevel]
      return msg(levelText, msg)
    end
    return false
  end

  def trace(msg) 
    logMsgAboveLogLevel(LEVEL_TRACE,msg)
  end

  def debug(msg)
    logMsgAboveLogLevel(LEVEL_DEBUG,msg)
  end

  def info(msg)
    logMsgAboveLogLevel(LEVEL_INFO,msg)
  end

  def warn(msg)
    logMsgAboveLogLevel(LEVEL_WARN,msg)
  end

  def error(msg)
    logMsgAboveLogLevel(LEVEL_ERROR,msg)
  end

  def fatal(msg)
    logMsgAboveLogLevel(LEVEL_FATAL,msg)
  end


end

unless defined?(@@logger)
  @@logger = InstallerLogger.new
end

# Make a common logger instance global available as 'logger'
class Object
  
  def logger
    return @@logger
  end
  
end

