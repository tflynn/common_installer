#!/usr/bin/env lua

apacheWebServer = {}

function apacheWebServer.preInstall()
  print "apacheWebServer.preInstall"
end

function apacheWebServer.install()
  print "apacheWebServer.install"
end

function apacheWebServer.postInstall()
  print "apacheWebServer.postInstall"
end

return apacheWebServer
