require 'test/unit'
require File.join(File.dirname(__FILE__), *%w{.. lib subtrigger})
$prevent_subtrigger_run = true