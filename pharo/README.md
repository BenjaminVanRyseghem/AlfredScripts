== About ==

The goal of this plugin is to open a pharo image.

If the name provided as argument matches the name of a pharo image existing in your images folder, 
this script will open this image.

Otherwise, it will download a fresh image from the CI server (https://ci.inria.fr/pharo), 
put it in your images folder and name it accordingly to the name provided as argument.

== Use ==

pharo [-f] name

Options:

	-f	: Force the download of an image even in an already existing image 
		  with the provided name exists

== Known issue ==

== Version ==

1.3
    - Add the argument -f

1.2
    - Add the search for already existing image

1.1
    - Change the ci server address since Jenkins moved

1.0
    - First version of the script

== To Do ==
