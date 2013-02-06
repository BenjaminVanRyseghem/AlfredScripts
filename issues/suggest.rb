#!/usr/bin/env ruby
require 'fileutils'
require 'find'

class Issue
   attr_accessor :title, :id, :url, :status 
   
   def initialize(title, id, url , status)
      @title = title
      @id = id
      @url = url
      @status = status 
   end
   
   def asXML()
      return buildXMLItemFor(@url, ("%-5s: " % [@id])+title, status, "yes", "icon.png")
   end
end

def buildXMLItemFor(arg, title, subtitle, valid, icon)
    string = '<item uid="suggest {query}" arg="'+arg+'">'
    string += '<title>'+title+'</title>'
    string += '<subtitle>'+subtitle+'</subtitle>'
    string += '<valid>'+valid+'</valid>'
    string += '<icon>'+icon+'</icon>'
    string += '</item>'
    return string
end

def retrieveSourceCode(query)
    url = "https://code.google.com/feeds/issues/p/pharo/issues/full?q=#{query}&can=open"
    sourceCode = `curl -s "#{url}"`
    return sourceCode
end

def retrieveIssues(query, sourceCode)
    prefix = "http://code.google.com/feeds/issues/p"
    prefix_size = prefix.size
    issues = []
    should_iterate = true
    first_index = sourceCode.index("<id>")+3
    while should_iterate do
        first_index = sourceCode.index("<id>", first_index)
        if first_index.nil?
            should_iterate = false
        else
            first_index += 4
            last_index = sourceCode.index("</id>", first_index)
            url = sourceCode[prefix_size+first_index..last_index-1]
            id_index = url.size() - url.reverse.index("/")
            id = url[id_index..-1]
            url = 'https://code.google.com/p/pharo/issues/detail?id='+id
            title_begin = sourceCode.index("<title>", first_index)
            title_end = sourceCode.index("</title>", title_begin)
            title = sourceCode[title_begin+7..title_end-1]
            
            title = title.gsub("&lt;", "<")
            title = title.gsub("&gt;", ">")
            
            status_begin = sourceCode.index("<issues:status>", first_index)
            status_end = sourceCode.index("</issues:status>", title_begin)
            status = sourceCode[status_begin+15..status_end-1]

            issues << Issue.new(title, id, url , status)
        end
    end
    return issues
end

def buildXML(query){}
    sourceCode = retrieveSourceCode(query)
    issues = retrieveIssues(query, sourceCode)
    string = "<items>"
    issues.each {| e | string += e.asXML()}
    string += "</items>"
    return string
end

query = $*[0]
query = query.gsub(" ", "+")
xml = buildXML(query)

puts xml