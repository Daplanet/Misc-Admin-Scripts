#!/usr/bin/env ruby -w

nextline = nil
prevline = nil
cves = []

ARGF.lines do |line|
    line.chomp!

    if nextline
      /((^-?\d{4}-\d{4})|(^-?\d{4}))/.match(line) do |m|
        cves.push(prevline + m[0])
        prevline = nextline = nil
      end
    end

    line.scan(/(CVE-\d{4}-\d{4})/) do |m|
      cves.push(m[0])
    end

    /((CVE-\d{4}-?)|(CVE-?))$/.match(line) do |m|
      prevline = m[0]
      nextline = 1
    end
end

cves.sort.uniq.each { |c| puts c }
