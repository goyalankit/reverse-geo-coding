reverse-geo-coding: using PlaceFinder API of Yahoo!
===================================================

This is a simple ruby script to translate location into a human-readable address. There are two branches associated with this project.

* master
* web-interface

master branch
-------------

This is a simple ruby script without any web interface.

Installation:

    git clone --branch=master git@github.com:ankitunique/reverse-geo-coding.git

Usage:

    ruby reverse-geo-code.rb input_file.csv output_file.csv


web-interface branch
--------------------

It's a very simple sinatra app with a web interface, where one can upload file and execute script. 

Installation:
    
    git clone --branch=web-interface git@github.com:ankitunique/reverse-geo-coding.git

To run the server use:

    rackup
    
Simple go to 

    localhost:9292/upload

you'll see a form to upload file and later you'll be asked to input name for ouput file and then run the script.
