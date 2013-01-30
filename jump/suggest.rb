#!/usr/bin/env ruby
require 'fileutils'
require 'find'

def buildXMLItemFor(arg, title, subtitle, valid, icon)
    string = '<item uid="suggest {query}" arg=\''+arg+'\'>'
    string += '<title>'+title+'</title>'
    string += '<subtitle>'+subtitle+'</subtitle>'
    string += '<valid>'+valid+'</valid>'
    string += '<icon>'+icon+'</icon>'
    string += '</item>'
    return string
end

def findBookmarksFor(query, path)
    lines = []
    File.open(path, "r").each_line do | line |
        if line.start_with? query
            lines << line
        end
    end
    return lines
end

def buildXMLForLine(line)
    splits = line.split
    name = splits[0].chop
    path = splits[1]
    return buildXMLItemFor(name, name, "Open this bookmark in Finder", "yes", "icon.png")
end

def buildSuggestionXML(query, path)
    string = '<items>'
    lines = findBookmarksFor(query, path)
    lines.each{ | line | string += buildXMLForLine(line) }
    string += '</items>'
    return string
end

query = $*[0]
path = File.expand_path("~/.jumprc")

xml = buildSuggestionXML(query, path)

puts xml