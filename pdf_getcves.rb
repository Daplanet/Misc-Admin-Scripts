#!/usr/bin/env ruby

require "rubygems"
require "pdf-reader"

class CVEExtractor
  attr_reader :cves

  def initialize()
    @nextline = nil
    @prevline = nil
    @cves = []
  end

  def extract_cves(line)
      line.chomp!

      if @nextline
        /((^-?\d{4}-\d{4})|(^-?\d{4}))/.match(line) do |m|
          cves.push(@prevline + m[0])
          @prevline = @nextline = nil
        end
      end

      line.scan(/(CVE-\d{4}-\d{4})/) do |m|
        cves.push(m[0])
      end

      /((CVE-\d{4}-?)|(CVE-?))$/.match(line) do |m|
        @prevline = m[0]
        @nextline = 1
      end
  end
end

reader = false
cvex = CVEExtractor.new

if ARGF.filename != "-"
  raise ArgumentError, "Unsupported file type." if ARGF.filename[-3,3] != "pdf"
  reader = PDF::Reader.new(ARGF.file)
end

if reader
  reader.pages.each do |page|
    page.text.each_line do |line|
      cvex.extract_cves(line)
    end
  end
else
  ARGF.lines do |line|
    cvex.extract_cves(line)
  end
end

cvex.cves.sort.uniq.each { |c| puts c }
