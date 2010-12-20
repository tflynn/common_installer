#!/usr/bin/env lua

dnsServer = {}

function dnsServer.preInstall()
  print "dnsServer.preInstall"
end

function dnsServer.install()
  print "dnsServer.install"
end

function dnsServer.postInstall()
  print "dnsServer.postInstall"
end

return dnsServer
