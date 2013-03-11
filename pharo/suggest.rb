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

def printDateFor(file)
    return printDate(File.mtime(file))
end

def printDate(date)
    today = Time.now
    if(!today.year == date.year) 
        return date.strftime("%d/%m/%Y")
    end
    if(!today.month == date.month)
        return date.strftime("%d %b - %H:%M:%S")
    end
    if (today.day - date.day < 7)
        return date.strftime("%A - %H:%M:%S")
    end
    return date.strftime("%d %a - %H:%M:%S")
end

def buildXMLForFile(file, path)
    name = File.basename(file, File.extname(file))
    file_path = File.dirname(file)
    dir = file_path[path.size+1..-1]
    return buildXMLItemFor('"'+name +'" "'+ path+'" "'+ dir+'"', name, "Open image named "+name+" ("+printDateFor(file)+")", "yes", "icon.png")
end

def buildSuggestionXML(query, path)
    string = '<items>'
    string += buildXMLItemFor('"-f" "'+query+'" "'+path+'" "'+query+'"', query, "Add a new image named "+query, "yes", "add.png")
    files = findImagesFor(query, path)
    files.each{ | file | string += buildXMLForFile(file, path) }
    string += '</items>'
    return string
end

query = $*[0]
path = ENV["PHARO_DIR"]

xml = buildSuggestionXML(query, path)

puts xml