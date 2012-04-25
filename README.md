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

getcves.pl
----------
Quality: ****

Pipe in some text and it'll dump out anything that looks like a CVE reference.
