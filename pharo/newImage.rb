#!/usr/bin/env ruby
require 'fileutils'
require 'find'

new_image = false
args = []

s = $*[0]
s.scan(/\"([^\"]+)\"/){|i| args << i[0]}

name_index = 0
if args.size == 3
   if args[0].eql?('-f' )
       new_image = true
   end
   name_index = 1    
end

name = args[name_index]
path = args[name_index+1]

if !new_image
    puts "Already existing Pharo image\n#{path}"
    `open "#{path}"`
    exit(0)
end

# ===========================================================================

version  = '2.0'
tmp      = `mktemp -d -t pharo`.chomp

imageUrl = "https://ci.inria.fr/pharo/view/Pharo-#{version}/job/Pharo-#{version}/lastSuccessfulBuild/artifact/Pharo.zip"
artifact = "Pharo"
extraInstructions = ""

# ===========================================================================

puts "Downloading a new image from Jenkins"
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
