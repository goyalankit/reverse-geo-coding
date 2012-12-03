require 'bundler'
Bundler.require

$: << File.dirname(__FILE__)

require 'application'
run ReverseGeocode.new
