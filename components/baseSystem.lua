#!/usr/bin/env lua

baseSystem = {}

function baseSystem.preInstall()
  print "baseSystem.preInstall"
end

function baseSystem.install()
  print "baseSystem.install"
end

function baseSystem.postInstall()
  print "baseSystem.postInstall"
end

return baseSystem
