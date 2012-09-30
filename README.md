Misc Admin Scripts
==================

A collection of random scripts that I've created for various reasons. Quality is 1-5 with 1 being the lowest. These come with no warranty and will quite possibly break things. 

apachemem.sh
------------
Quality: **

Calculates the correct MaxClients setting for Apache, if you're lucky. ApacheBuddy is much better than this, but AB doesn't appear to work right on some cPanel servers, hence this. It's hacky as it combines several separate ways of doing things in a mish-mash of horribleness, yet it was thrown together quickly.

fix_munin_selinux.sh
--------------------
Quality: ***

Out of the box, Munin doesn't play nicely with SELinux for some things on CentOS 6. This will create an SELinux module using audit2allow to fix this... maybe.

purge.php
---------
Quality: *****

Example for purging files from Varnish caches. Requires pecl_http.

ssl_converter.py
----------------
Quality: ***

Uses OpenSSL to convert X.509 certs to PFX.

zencart_md5.py
--------------
Quality: *****

Generates a ZenCart salted MD5 password using a Python oneliner.

getcves.pl / getcves.rb
-----------------------
Quality: ****

Pipe in some text and it'll dump out anything that looks like a CVE reference. Now in your favourite language!

pdf_getcves.rb
--------------
Quality: ****

Give it a PDF (or pipe in some text) and it'll spew out CVE references for you!


plesk_exploit_fixer.sh
----------------------
Quality: ****

Finds and removes the 'km0ae9gr6m' exploit from PHP and JS files and changes all Plesk passwords to ensure the compromise cannot occur again.

server_triage.sh
----------------
Quality: *

A triage script to run on Linux servers with issues to give you an overview of the server state and what might be wrong, could be run with curl x.com/server_triage.sh | sh.
