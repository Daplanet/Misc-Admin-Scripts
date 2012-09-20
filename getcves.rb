#!/usr/bin/env ruby -w

nextline = nil
prevline = nil
cves = []

ARGF.lines do |line|
    line.chomp!

    if nextline
      matches = /((^-?\d{4}-\d{4})|(^-?\d{4}))/.match(line)
        cve.push(prevline + matches[0])
        prevline = nextline = nil
    end

    /(CVE-\d{4}-\d{4})/.match(line) do |m|
      cves.push(m[0])
    end

    /((CVE-\d{4}-?)|(CVE-?))$/.match(line) do |m|
      prevline = m[0]
      nextline = 1
    end
end

cves.sort.uniq.each { |c| puts c }
