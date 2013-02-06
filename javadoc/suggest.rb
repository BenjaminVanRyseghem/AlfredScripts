#!/usr/bin/env ruby
require 'fileutils'

class Javadoc
   attr_accessor :name, :url, :package
    def initialize(string)
        start_index = string.index('<A HREF="')
        stop_index = string.index('" title="', start_index)
        @url = "http://docs.oracle.com/javase/6/docs/api/"+string[start_index+9..stop_index-1]
        
        start_index = stop_index
        stop_index = string.index('">', start_index)
        @package = string[start_index+18..stop_index-1]
        offset = 0
        e_offset = 1
        if @package[0,4].eql?" in "
            offset = 3
            e_offset = 5
            @package = @package[4..-1] 
        end
        start_index = stop_index
        stop_index = string.index('</A>', start_index)
        @name = string[offset+start_index+2..stop_index-e_offset]
    end 
end


def buildXMLItemFor(arg, title, subtitle, valid, icon)
    string = '<item uid="suggest {query}" arg=\''+arg+'\'>'
    string += '<title>'+title+'</title>'
    string += '<subtitle>'+subtitle+'</subtitle>'
    string += '<valid>'+valid+'</valid>'
    string += '<icon>'+icon+'</icon>'
    string += '</item>'
    return string
end

def retrieveSource(path)
    if !File.exists?(path)
        sourceCode = `curl -s http://docs.oracle.com/javase/6/docs/api/allclasses-noframe.html`
        File.open(path, 'w') {|f| 
            f.puts <<IDENTIFIER
            #{sourceCode}
IDENTIFIER
        }
    else
        file = File.open(path, "rb")
        sourceCode = file.read
        file.close
    end
    if sourceCode.empty?
       puts 'Error in the #{path} file'
       exit(1) 
    end
    return sourceCode
end


def retrieveClasses(query, sourceCode)
    classes = []
    sourceCode.each_line{|line|
        if line.include?(">"+query)
            classes << Javadoc.new(line) 
        end
    }
    return classes
end

def buildXMLForClass(klass)
   return buildXMLItemFor(klass.url, klass.name, "from package "+klass.package, "yes", "icon.png")
end

def buildXML(query, path)
    sourceCode = retrieveSource(path)
    classes = retrieveClasses(query, sourceCode)
    string = "<items>"
    classes.each { | cl | string += buildXMLForClass(cl)} 
    string += "</items>"
    return string
end


query = $*[0]
path = '.javadoc_src'

xml = buildXML(query, path)

puts xml
