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

def downloadNewVersion(path, destination)
    imageUrl = "https://ci.inria.fr/pharo/job/Pharo-2.0-Issue-Tracker-Image/lastSuccessfulBuild/artifact/Pharo-2.0-Issue-Tracker-Image.zip"

    `curl --retry 2 --time-cond "#{path}/backup.zip" --connect-timeout 3 --anyauth "#{imageUrl}" --output "#{path}/artifact.zip" &&  cp -f "#{path}/artifact.zip" "#{path}/backup.zip" || cp "#{path}/backup.zip" "#{path}/artifact.zip"`

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

def openDirectory(destination, open_directory)
   if(open_directory) 
       puts "Open encapsulating folder: #{destination}"
       `open "#{destination}"` 
       exit(0)
    end
end

new_image = false
open_directory = false
s = $*[0]
args = splitArguments(s)


name_index = args.size-3
if args.size == 4 && args[0].eql?('-f' )
   new_image = true
end

if args.size == 4 && args[0].eql?('-o' )
   open_directory = true
end

name = args[name_index]
path = args[name_index+1]
dir = args[name_index+2]
destination = path +"/"+dir
full_path = destination+"/"+name+".image"

openDirectory(destination, open_directory)
openExistingImage(full_path, new_image)
downloadNewVersion(path, destination)
moveFiles(destination, name)

openImage("New Pharo downloaded in #{destination}", full_path)