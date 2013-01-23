#!/usr/bin/env ruby
require 'fileutils'
require 'find'


optionAndQuery = $*[0]

if optionAndQuery.nil?
    optionAndQuery = "--help"
end

first = optionAndQuery.split(" ").first

if first[0,1] == "-"
    option = first
else
    option = nil
end

def lookForFileNamed(dir,name)
    Find.find(dir) do |path|
        res = File.basename(path)
        if res == name
            return path
        end
    end
    return nil
end

info = `gem environment`
line = ''
info.each_line{| l |
    if l.lstrip.start_with?("- /Users")
        line = l
    end
}

path = line.lstrip[2..-2]+'/gems'

exe = lookForFileNamed(path, 'jump-bin')

rawResult = IO.popen("#{exe} #{optionAndQuery}")
result = rawResult.readlines.join[0..-2]

if option.eql?("-a") || option.eql?("--all")
   #can not add a bookmark from here
   exit(0)
end

if option.nil?
    #default case, you jump
    #in case of success, return the path, otherwise an error and the current path
    if result.eql?(Dir.pwd)
        #ERROR
        puts "Unknown bookmark: \'#{optionAndQuery}\'."
        exit(1)
    else
        #NO ERROR
       `open #{result}`
    end
    
else
    #OPTION or NOTHING
    puts result
end