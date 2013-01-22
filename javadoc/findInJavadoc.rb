#!/usr/bin/env ruby
require 'fileutils'

className = $*[0]
suffix = '>'+className+'</A>
'

path = '.javadoc_src'

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

urlLine = ''


sourceCode.each_line{|line|
    if line.end_with?(suffix)
        urlLine = line 
    end
    }
    
if urlLine.empty?
   puts 'Are you sure this class exists ?'
   exit(1) 
end

start = urlLine.index('<A HREF="') +9
stop = urlLine.index('" title="') -1
url = urlLine[start..stop]

fullUrl = 'http://docs.oracle.com/javase/6/docs/api/'+url
if !fullUrl.empty?
    `open #{fullUrl}`
end