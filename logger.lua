#!/usr/bin/env lua

logger = {}

remoteRequire 'commandLine'
remoteRequire 'osHelpers'

local LEVEL_TRACE=0
local LEVEL_DEBUG=1
local LEVEL_INFO=2
local LEVEL_WARN=3
local LEVEL_ERROR=4
local LEVEL_FATAL=5

local LEVELS_TEXT = {'TRACE', 'DEBUG' , 'INFO', 'WARN', 'ERROR', 'FATAL'}

local TYPE_CONSOLE_APPENDER = 'typeConsoleAppender'
local TYPE_FILE_APPENDER = 'typeFileAppender'

local currentLogLevel = LEVEL_DEBUG
local currentAppenders = { }
local currentFileName = nil

function logger.setFileName(fileName)
    currentFileName = fileName
end

function logger.getFileName()
  if currentFileName == nil then
    currentFileName =  commandLine.getLogFileName()
  end
  return currentFileName
end

function logger.addConsoleAppender()
  currentAppenders[#currentAppenders + 1] = TYPE_CONSOLE_APPENDER
end

function logger.addFileAppender(fileName) 
  logger.setFileName(fileName)
  currentAppenders[#currentAppenders + 1] = TYPE_FILE_APPENDER
end

function logger.setTrace()
  currentLogLevel = LEVEL_TRACE
end

function logger.setDebug()
  currentLogLevel = LEVEL_DEBUG
end

function logger.setInfo()
  currentLogLevel = LEVEL_INFO
end

function logger.setWarn()
  currentLogLevel = LEVEL_WARN
end

function logger.setError()
  currentLogLevel = LEVEL_ERROR
end

function logger.setFatal()
  currentLogLevel = LEVEL_FATAL
end


function logger.msg(levelText, msg)
  local status = nil
  local timeStamp = nil
  status, timeStamp = osHelpers.captureAndStrip('date "+%Y-%m-%d %H:%M:%S"')
  local fullMsg = timeStamp .. ' ' .. levelText .. ': ' .. msg
  if #currentAppenders == 0 then
    logger.addConsoleAppender()
  end
  for currentAppenderId = 1 , #currentAppenders do
    local currentAppenderType = currentAppenders[currentAppenderId]
    if currentAppenderType == TYPE_CONSOLE_APPENDER then
      print(fullMsg)
    end
    if currentAppenderType == TYPE_FILE_APPENDER then
      local logfileName = logger.getFileName()
      local logFile = assert(io.open(logfileName,'a'),"Unable to open log file " .. logfileName)
      logFile:write(fullMsg .. "\n")
      logFile:close()
    end
  end
end

function logger.logMsgAboveLogLevel(logLevel,msg)
  if currentLogLevel <= logLevel then
    local levelText = LEVELS_TEXT[logLevel + 1]
    logger.msg(levelText, msg)
  end
end

function logger.trace(msg) 
  logger.logMsgAboveLogLevel(LEVEL_TRACE,msg)
end

function logger.debug(msg)
  logger.logMsgAboveLogLevel(LEVEL_DEBUG,msg)
end

function logger.info(msg)
  logger.logMsgAboveLogLevel(LEVEL_INFO,msg)
end

function logger.warn(msg)
  logger.logMsgAboveLogLevel(LEVEL_WARN,msg)
end

function logger.error(msg)
  logger.logMsgAboveLogLevel(LEVEL_ERROR,msg)
end

function logger.fatal(msg)
  logger.logMsgAboveLogLevel(LEVEL_FATAL,msg)
end

return logger
