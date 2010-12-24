#!/usr/bin/env jruby

class InstallerLogger
  
  LEVEL_TRACE=0
  LEVEL_DEBUG=1
  LEVEL_INFO=2
  LEVEL_WARN=3
  LEVEL_ERROR=4
  LEVEL_FATAL=5

  LEVELS_TEXT = ['TRACE', 'DEBUG' , 'INFO', 'WARN', 'ERROR', 'FATAL']

  TYPE_CONSOLE_APPENDER = 'typeConsoleAppender'
  TYPE_FILE_APPENDER = 'typeFileAppender'

  def initialize
    @currentLogLevel = LEVEL_DEBUG
    @currentAppenders = []
    @currentFileName = nil
    addConsoleAppender
    addFileAppender(getFileName)
  end

  def setFileName(fileName)
    @currentFileName = fileName
  end

  def getFileName
    unless @currentFileName
      @currentFileName = DEFAULT_LOG_FILE_NAME
      #duplicate CommandLine.getLogFileName to avoid dependency here
      if ARGV
        ARGV.each do |arg|
          if arg =~ /^logfile/
            option, value = arg.split('=')
            @currentFileName = value
            break
          end
        end
      end
    end
    return @currentFileName
  end

  def addConsoleAppender
    @currentAppenders << TYPE_CONSOLE_APPENDER
  end

  def addFileAppender(fileName) 
    setFileName(fileName)
    @currentAppenders << TYPE_FILE_APPENDER
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
    timeStamp = `date "+%Y-%m-%d %H:%M:%S"`.chomp.strip
    fullMsg = %{#{timeStamp} #{levelText}: #{msg}}
    if @currentAppenders.size == 0
      addConsoleAppender
    end
    @currentAppenders.each do |currentAppender|
      if currentAppender == TYPE_CONSOLE_APPENDER
        puts(fullMsg)
      end
      if currentAppender == TYPE_FILE_APPENDER
        File.open(getFileName,'a') do |logfile|
          logfile.puts(fullMsg)
        end
      end
    end
  end

  def logMsgAboveLogLevel(logLevel,msg)
    if @currentLogLevel <= logLevel
      levelText = LEVELS_TEXT[logLevel]
      msg(levelText, msg)
    end
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

# Make a common logger instance global available as 'logger'
class Object
  
  def logger
    unless defined?(@@logger)
      @@logger = InstallerLogger.new
    end
    return @@logger
  end
  
end
