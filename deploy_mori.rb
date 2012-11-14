#!/usr/bin/env ruby -w
# Modified dl.rig.gr deploy script for keeping Mori up to date on here

require 'socket'
require 'timeout'

deploylist = {
  "moritasgus"       =>      "ssh://git@rig.gr:2020/moritasgus.git",
}

debug = true

deploypath = '/usr/local'
pidfile = '/tmp/moritasgus.pid'
moricmdline = 'python /usr/local/moritasgus/moritasgus/moritasgus.py -d -v -m layer4,iptables'

#################################################################
# Do not edit below this line.
#################################################################

deploylist.each do | name, repo |
  fullpath = "#{deploypath}/#{name}"
  if Dir.exists?(fullpath)
    puts "Already checked out, doing a pull" if debug
    `cd #{fullpath} && git pull > /dev/null 2>&1`
    puts "Error updating repository #{name} from #{repo}" unless $? == 0
  else
    puts "Cloning repo for the first time" if debug
    `git clone #{repo} #{deploypath}/#{name} > /dev/null 2>&1`
    puts "Error cloning new repository #{name} from #{repo}" unless $? == 0
  end
end

pid = 0

if File.exists?(pidfile)
  begin
    puts "pidfile exists, reading" if debug
    pid = IO.read(pidfile).to_i  
    puts "pid = #{pid}" if debug
  rescue => err
    puts "Problem reading pidfile: #{err}"
    exit
  end
end

if pid != 0
  puts "killing process id #{pid}" if debug
  Process.kill("TERM", pid)
  sleep(2)
end

begin
  Timeout::timeout(3) do
    begin
      puts "Ensuring socket is dead..." if debug
      TCPSocket.new('127.0.0.1', 10101).close
      puts "Moritasgus is still running? Not doing anything."
      exit
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      # Safe to start, do nothing
      puts "Nothing running on port 10101, starting Mori" if debug
    end
  end
rescue Timeout::Error
  # Do nothing
end

system(moricmdline)
puts "Mori started." if debug
