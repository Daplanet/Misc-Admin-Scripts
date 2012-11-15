#!/usr/bin/env ruby -w
# Modified dl.rig.gr deploy script for keeping Mori up to date on here

require 'socket'
require 'timeout'

deploylist = {
  "moritasgus"       =>      "ssh://git@rig.gr:2020/moritasgus.git",
}

deploypath = '/usr/local'
pidfile = '/tmp/moritasgus.pid'
moricmdline = 'python /usr/local/moritasgus/moritasgus/moritasgus.py -d -v -m layer4,iptables'

#################################################################
# Do not edit below this line.
#################################################################

deploylist.each do | name, repo |
  fullpath = "#{deploypath}/#{name}"
  if Dir.exists?(fullpath)
    `cd #{fullpath} && git pull > /dev/null 2>&1`
    puts "Error updating repository #{name} from #{repo}" unless $? == 0
  else
    `git clone #{repo} #{deploypath}/#{name} > /dev/null 2>&1`
    puts "Error cloning new repository #{name} from #{repo}" unless $? == 0
  end
end

pid = 0

if File.exists?(pidfile)
  begin
    pid = IO.read(pidfile).to_i  
  rescue => err
    puts "Problem reading pidfile: #{err}"
    exit
  end
end

if pid != 0
  Process.kill("TERM", pid)
  sleep(2)
end

begin
  Timeout::timeout(3) do
    begin
      TCPSocket.new('127.0.0.1', 10101).close
      puts "Moritasgus is still running? Not doing anything."
      exit
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      # Safe to start, do nothing
    end
  end
rescue Timeout::Error
  # Do nothing
end

system(moricmdline)
