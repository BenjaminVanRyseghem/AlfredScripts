#!/usr/bin/env ruby
require 'fileutils'
require 'find'

new_image = false
args = []

s = $*[0]
s.scan(/\"([^\"]+)\"/){|i| args << i[0]}

name_index = args.size-3
    IO.popen('pbcopy', 'w').puts s

if args.size == 4 && args[0].eql?('-f' )
   new_image = true
end

name = args[name_index]
path = args[name_index+1]
dir = args[name_index+2]
destination = path +"/"+dir
full_path = destination+"/"+name+".image"

if !new_image
    puts "Already existing Pharo image\n#{full_path}"
    `open "#{full_path}"`
    exit(0)
end

# ===========================================================================

version  = '2.0'
tmp      = `mktemp -d -t pharo`.chomp
imageUrl = "https://ci.inria.fr/pharo/view/Pharo-#{version}/job/Pharo-#{version}/lastSuccessfulBuild/artifact/Pharo.zip"

# ===========================================================================
`cd "#{path}" && curl --retry 2 --connect-timeout 3 --anyauth "#{imageUrl}" --output "artifact.zip" &&  cp -f "#{path}/artifact.zip" "#{path}/backup.zip"  || cp "#{path}/backup.zip" "#{path}/artifact.zip"`
`unzip -xo "#{path}"/artifact.zip -d "#{destination}"`

Dir.glob(File.join(destination, '*')).each do |file|
    if File.basename(file,File.extname(file)) != name
        FileUtils.mv file, File.join(destination, name + File.extname(file)), :force=>true
    end
end

`rm "#{path}"/artifact.zip`
`rm -rf "#{tmp}"`

# ===========================================================================
puts "New Pharo downloaded in #{destination}"
`open "#{full_path}"`
