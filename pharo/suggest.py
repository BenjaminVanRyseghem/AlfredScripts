#author: Peter Okma
import xml.etree.ElementTree as et
import glob
import sys
import os

class Feedback():
    """Feeback used by Alfred Script Filter

    Usage:
        fb = Feedback()
        fb.add_item('Hello', 'World')
        fb.add_item('Foo', 'Bar')
        print fb

    """

    def __init__(self):
        self.feedback = et.Element('items')

    def __repr__(self):
        """XML representation used by Alfred

        Returns:
            XML string
        """
        return et.tostring(self.feedback)

    def add_item(self, title, subtitle = "", arg = "", valid = "yes", autocomplete = "", icon = "icon.png"):
        """
        Add item to alfred Feedback

        Args:
            title(str): the title displayed by Alfred
        Keyword Args:
            subtitle(str):    the subtitle displayed by Alfred
            arg(str):         the value returned by alfred when item is selected
            valid(str):       whether or not the entry can be selected in Alfred to trigger an action
            autcomplete(str): the text to be inserted if an invalid item is selected. This is only used if 'valid' is 'no'
            icon(str):        filename of icon that Alfred will display
        """
        item = et.SubElement(self.feedback, 'item',
            uid=str(len(self.feedback)), arg=arg)
        _title = et.SubElement(item, 'title')
        _title.text = title
        _sub = et.SubElement(item, 'subtitle')
        _sub.text = subtitle
        _valid = et.SubElement(item, 'valid')
        _valid.text = valid
        _autocomplete = et.SubElement(item, 'autocomplete')
        _autocomplete.text = autocomplete
        _icon = et.SubElement(item, 'icon')
        _icon.text = icon
        
        
    def retrieveFiles(self,query,path):
        return glob.glob(path+'/**/'+query+'*.image')
        
    def buildXML(self, query, path):
        files = self.retrieveFiles(query,path)
        self.add_item(query, "Download a new image named "+query,query, "true","", "add.png")
        for file in files:
            index = file.rfind("/")
            name = file[index+1:-6]
            self.add_item(name, "Open the existing image named "+name, name)
        
        
        
f = Feedback()
query = sys.argv[1]
path = os.getenv("PHARO_DIR")
f.buildXML(query,path)
print f