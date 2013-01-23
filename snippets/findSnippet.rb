#!/usr/bin/env ruby

require 'rexml/document'
query = $*[0]

path = ENV['SNIPPET_DB']
doc = REXML::Document.new File.new(path)


xmlPath = '//object type="SNIPPET" id="z269"/attribute name="name" type="string"'
#doc.elements('//object type="SNIPPET" id="z269"/attribute name="name" type="string"') { |element| puts element.get_text }

snippets = []
doc.root.elements.each("object") { | object | 
    bool = false
    if object.attribute("type").value() == 'SNIPPET'
        object.each_element_with_attribute( 'name', 'name' ) {|e|     
            if e.text() == query
                 bool = true
            end
        }
        if bool
            object.each_element_with_attribute( 'name', 'code' ){|e|
                if !e.attribute("idrefs").nil?
                    snippets.insert(-1,object)
                end
            }
        end
    end 
}

if snippets.size == 0
    puts "Snippet #{query} not found"
    exit(1)
end

if snippets.size > 1
    puts "Too many Snippets named #{query} found"
#    snippets.each{|e| p e}
    exit(1)
end

snippet = snippets.first

codeId = nil
snippet.elements.each{| e |
    if e.attribute("name").value() == 'code'
       codeId = e.attribute("idrefs").value() 
    end   
}
    
if codeId.nil?
    puts "Error in the structure of the snippet"
    exit(1)
end    

code = ''
doc.root.elements.each("object") { | object | 
    
    if object.attribute("type").value() == 'CODE' && object.attribute("id").value() == codeId
        object.each_element_with_attribute('name','content'){|e|
            code = e.text
        }
    end 
}

" change \u2600 -> & "
code = code.gsub('\\u2600','&')

" change \u3c00 -> < "
code = code.gsub('\\u3c00','<')

" change \u3e00 -> > "
code = code.gsub('\\u3e00','>')

" change \\ -> \ "
code = code.gsub('\\\\', '\\')

puts code
IO.popen('pbcopy', 'w').puts code