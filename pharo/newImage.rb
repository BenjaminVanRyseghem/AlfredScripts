#!/usr/bin/env ruby
require 'fileutils'
require 'find'

def openImage(string, full_path)
    puts string
    `open "#{full_path}"`
    exit(0)
end

def openExistingImage(full_path, new_image)
    if !new_image
        openImage("Already existing Pharo image\n#{full_path}", full_path)
    end
end

def splitArguments(s)
    args = []
    s.scan(/\"([^\"]+)\"/){|i| args << i[0]}
    return args
end

def retieveCurrentVersion()
    code = IO.popen("curl https://ci.inria.fr/pharo/job/Pharo-2.0/lastSuccessfulBuild/")
    code = code.readlines.join[0..-2]
    prefix = '      </h1><div><div id="description"><div>2.0 #'
    line = ''
    code.each_line { | l |
        if l.chomp.start_with?(prefix)
            line = l
            break
        end
    }
    size = prefix.size
    return line[size, 5]
end

def downloadNewVersion(path, destination)
    imageUrl = "https://ci.inria.fr/pharo/view/Pharo-2.0/job/Pharo-2.0/lastSuccessfulBuild/artifact/Pharo.zip"

    backup = ''
    Dir.glob(File.join(path, '*.zip')).each do |file|
        backup = file
    end
    backup = File.basename(backup,File.extname(backup))

    current_version = retieveCurrentVersion()
    if backup.eql?(current_version)        
        `cp "#{path}/#{backup}.zip" "#{path}/artifact.zip"`
    else
        `curl --retry 2 --connect-timeout 3 --anyauth "#{imageUrl}" --output "#{path}/artifact.zip" &&  cp -f "#{path}/artifact.zip" "#{path}/#{current_version}.zip" && rm "#{path}/#{backup}.zip" || cp "#{path}/#{backup}.zip" "#{path}/artifact.zip"`
    end

    `unzip -xo "#{path}"/artifact.zip -d "#{destination}"`
    `rm "#{path}"/artifact.zip`
end

def moveFiles(destination, name)
    Dir.glob(File.join(destination, '*')).each do |file|
        if File.basename(file,File.extname(file)) != name
            FileUtils.mv file, File.join(destination, name + File.extname(file)), :force=>true
        end
    end
end

new_image = false
s = $*[0]
args = splitArguments(s)


name_index = args.size-3
if args.size == 4 && args[0].eql?('-f' )
   new_image = true
end

name = args[name_index]
path = args[name_index+1]
dir = args[name_index+2]
destination = path +"/"+dir
full_path = destination+"/"+name+".image"

openExistingImage(full_path, new_image)
downloadNewVersion(path, destination)
moveFiles(destination, name)

openImage("New Pharo downloaded in #{destination}", full_path)