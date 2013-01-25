#!/usr/bin/env ruby
require 'fileutils'
require 'find'

def help
    puts "    usage /.image pharo"
    puts "          --hack     edit the sources of this script"
    puts "          -h/--help  show this help text"
end

if $*.size > 1
    help
    exit 1
end

#not used yet
vmPath = ENV['VM_PATH']

def editor()
    if ENV['EDITOR']
        return ENV['EDITOR']
    else
        return 'nano'
    end
end

forced = false
name = $*[0]

if name[0..1] == "-f"
    forced = true
    name = name[3..-1]
end

def exists(name)
    if (name == nil)
        return nil
    else 
        return lookForFileNamed(ENV['PHARO_DIR'],name+".image")
    end    
end

if $*[0] == "--help" || $*[0] == "-h"
    help()
    exit 0
elsif $*[0] == "--hack"
    sourceFile = `readlink #{__FILE__} || echo #{__FILE__}`
    exec("#{editor()} #{sourceFile}")
end

# Check if the file already exists

def lookForFileNamed(dir,name)
    Find.find(dir) do |path|
        if FileTest.directory?(path)
            if dir == path
                next
            end
            res = lookForFileNamed(path,name)
            if res != nil
                return File.join(path,res)
            end
        else
           res = File.basename(path)
           if res == name
               return res
           end
        end
    end
    return nil
end

alreadyExists = exists(name)
if alreadyExists != nil && !forced
    puts "Already existing Pharo loaded from #{alreadyExists}"
    `open "#{alreadyExists}"`
    exit(0)
end


# ===========================================================================

tmp      = `mktemp -d -t pharo`.chomp

imageUrl = "https://ci.inria.fr/pharo/job/Event-Model/lastSuccessfulBuild/artifact/Event-Model.zip"
artifact = "Event-Model"
path = ENV['PHARO_DIR']
extraInstructions = ""

# ===========================================================================

`cd "#{path}" && curl --retry 2 --connect-timeout 3 --anyauth "#{imageUrl}" --output "artifact.zip" &&  cp -f "#{path}/artifact.zip" "#{path}/backup.zip"  || cp "#{path}/backup.zip" "#{path}/artifact.zip"`
#wget --tries=2 --timeout=3 --no-check-certificate "#{imageUrl}" --output-document="artifact.zip"

list = Dir["#{path}/#{artifact}*"]

if list == []
    id = nil
else
    lastName = list.last
    id = lastName.split.last
end

if id == nil
    arity = ""
elsif id == artifact
    arity = "\ 1"
else
    arity = "\ " + (id.to_i()+1).to_s
end

if name.nil?
    dir = artifact+arity
    subdir = artifact
else
    dir = name
    subdir = name
end

destination = "#{path}/#{dir}"

`unzip -xo "#{path}"/artifact.zip -d "#{destination}"`

if !(name.nil?)
    Dir.glob(File.join(destination, '*')).each do |file|
        if File.basename(file,File.extname(file)) != name
            FileUtils.mv file, File.join(destination, name + File.extname(file)), :force=>true
        end
    end
end

`rm "#{path}"/artifact.zip`
`rm -rf "#{tmp}"`

# ===========================================================================
puts "New Pharo downloaded in #{destination}"
`open "#{destination}/#{subdir}.image"`
