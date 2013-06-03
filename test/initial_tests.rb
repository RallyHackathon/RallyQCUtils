#!/usr/bin/env ruby
$LOAD_PATH << File.join(Dir.pwd, 'lib')  # shouldn't be needed if this is a gem - keep if testing in source
require "rally_qc_utils"
require "test/unit"
require "nori"
# the following is required because of an eclipse bug (https://bugs.eclipse.org/bugs/show_bug.cgi?id=323736)
module Test
  module Unit
    module UI
      SILENT = false
    end

    class AutoRunner
      def output_level=(level)
        self.runner_options[:output_level] = level
      end
    end
  end
end

class InitialTests < Test::Unit::TestCase
 
  def test_version
    assert_equal("0.1.0", RallyQCUtils::VERSION )
  end
  
 def test_rally_xml
   rally_info = {"WorkspaceName"=>"workspace1", "Projects"=>['project1']}
   config_writer = RallyQCUtils::ConfigWriter.new
   rally_xml = config_writer.construct_rally_xml(rally_info)
   puts rally_xml
   parser = Nori.new(:parser => :rexml)
   loaded_config = parser.parse(rally_xml)
   assert_equal("workspace1",loaded_config["RallyConnection"]['WorkspaceName'])
   assert_equal("project1", loaded_config["RallyConnection"]['Projects']['Project'])
   assert_equal(1,1)
 end
end
