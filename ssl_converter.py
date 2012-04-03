#!/usr/bin/env python
# Converts a crt/key SSL into a PFX SSL for IIS using OpenSSL

# This must only return the public IP and nothing else.
IPSITE="http://www.icanhazip.com"

# Port to run webserver on for file retrieval
PORT=8090

import os
from os import system, unlink, chdir
from sys import exit
import fileinput
import tempfile
import SimpleHTTPServer
import SocketServer
import urllib2

cert = ""
key = ""

domain = raw_input("Domain for SSL?: ") #Purely for the filename, does nothing other than that.
print "Paste certificate (CTRL+D twice to finish):"
for line in fileinput.input():
    cert = cert + line
print
print "Paste key (CTRL+D twice to finish):"
for line in fileinput.input():
    key = key + line
print
print "Converting..."
print

tmpdir = tempfile.mkdtemp(suffix=domain)

certfile = file(os.path.join(tmpdir, domain+".crt"),'w')
certfile.write(cert)
certfile.close()

keyfile = file(os.path.join(tmpdir, domain+".key"),'w')
keyfile.write(key)
keyfile.close()

system("openssl pkcs12 -export -out "+os.path.join(tmpdir, domain)+".pfx -inkey "+ \
       os.path.join(tmpdir, domain)+".key -in "+os.path.join(tmpdir, domain)+".crt")

print
print "Completed (hopefully!)"
print

resp = urllib2.urlopen(IPSITE)
ip = resp.read()

print "Serving PFX SSL file up for retrieval at:"
print
print "       http://"+ip[:-1]+":8090" # Removes newline
print
print "Press CTRL+C to finish."
print

chdir(tmpdir)
handler = SimpleHTTPServer.SimpleHTTPRequestHandler
httpd = SocketServer.TCPServer(("",PORT), handler)
try:
    httpd.serve_forever()
except KeyboardInterrupt:
    exit()
