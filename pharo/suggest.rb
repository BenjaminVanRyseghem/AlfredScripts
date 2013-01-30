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

def findImagesFor(query, path)
    return Dir.glob(path+'/**/'+query+'*.image')
end

def buildXMLForFile(file)
    name = File.basename(file, File.extname(file))
    path = File.expand_path(file)
    return buildXMLItemFor('"'+name +'" "'+ path+'"', name, "Open image named "+name, "yes", "icon.png")
end

def buildSuggestionXML(query, path)
    string = '<items>'
    string += buildXMLItemFor('"-f" "'+query+'" "'+path+'/'+query+'/'+query+'.image"', query, "Add a new image named "+query, "yes", "add.png")
    files = findImagesFor(query, path)
    files.each{ | file | string += buildXMLForFile(file) }
    string += '</items>'
    return string
end

query = $*[0]
path = ENV["PHARO_DIR"]

xml = buildSuggestionXML(query, path)

puts xml