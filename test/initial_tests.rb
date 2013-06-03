#!/usr/bin/env ruby
$LOAD_PATH << File.join(Dir.pwd, 'lib')  # shouldn't be needed if this is a gem - keep if testing in source
require "rally_qc_utils"
require "test/unit"
require "nori"
require "tempfile"

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
 
 def test_file_read
   file = Tempfile.new(['foo','.csv'])
   file.write "QC Domain,QC Project,Rally Workspace, Rally Workspace ID,  Rally Project, Rally Project ID,  RQ_REQ_NAME, RQ_REQ_COMMENT,  RQ_USER_01\n"+
   "DomainA,ProjectA,TestWorkspace,12345,Team1,987,Name,Description,ObjectID,FormattedID\n"+
   "DomainA,ProjectB,TestWorkspace,12345,Team2,654,Name,Description,ObjectID,FormattedID"
   location = file.path
   file.rewind
   location_less_csv = location.slice(0,location.size-4)
   csv_reader = RallyQCUtils::ExcelCsvReader.new(location_less_csv)
   results = csv_reader.gather_info
   assert_equal("TestWorkspace",results[0][:rally]["WorkspaceName"])
   assert_equal("Team1",results[0][:rally]["Projects"][0])
   assert_equal("DomainA",results[0][:qc]["Domain"])
   assert_equal("ProjectA",results[0][:qc]["Project"])
   assert_equal("TestWorkspace",results[1][:rally]["WorkspaceName"])
   assert_equal("Team2",results[1][:rally]["Projects"][0])
   assert_equal("DomainA",results[1][:qc]["Domain"])
   assert_equal("ProjectB",results[1][:qc]["Project"])
   #{:rally=>{"WorkspaceName"=>"TestWorkspace", "Projects"=>["Team1"]}, :qc=>{"Domain"=>"   DomainA", "Project"=>"ProjectA", "ExternalIDField"=>"  RQ_USER_01", "ExternalEndUserIDField"=>nil}, :fields=>{"Name "=>"  RQ_REQ_NAME", "Description"=>" RQ_REQ_COMMENT"}}
   #{:rally=>{"WorkspaceName"=>"TestWorkspace", "Projects"=>["Team2"]}, :qc=>{"Domain"=>"   DomainA", "Project"=>"ProjectB", "ExternalIDField"=>"  RQ_USER_01", "ExternalEndUserIDField"=>nil}, :fields=>{"Name"=>"  RQ_REQ_NAME", "Description"=>" RQ_REQ_COMMENT"}}
 end
 def test_fields_xml
   field_info = [["Name","RQ_REQ_NAME"],["Description","RQ_REQ_DESC"]]
   config_writer =  RallyQCUtils::ConfigWriter.new
   field_xml = config_writer.construct_field_mapping_xml(field_info)
   parser = Nori.new(:parser => :rexml)
   loaded_config = parser.parse(field_xml)
   assert_equal("Name",loaded_config["FieldMapping"]['Field'][0]['Rally'])
   assert_equal("RQ_REQ_NAME",loaded_config["FieldMapping"]['Field'][0]['Other'])
   assert_equal("Description",loaded_config["FieldMapping"]['Field'][1]['Rally'])
   assert_equal("RQ_REQ_DESC",loaded_config["FieldMapping"]['Field'][1]['Other'])
 end
 def test_qc_xml
   qc_info = {"Domain"=>"domain1","Project"=>"project1"}
   config_writer =  RallyQCUtils::ConfigWriter.new
   qc_xml = config_writer.construct_qc_xml(qc_info)
   parser = Nori.new(:parser => :rexml)
   loaded_config = parser.parse(qc_xml)
   assert_equal("domain1",loaded_config["QCConnection"]['Domain'])
   assert_equal("project1", loaded_config["QCConnection"]['Project'])
 end
 def test_rally_xml
   rally_info = {"WorkspaceName"=>"workspace1", "Projects"=>['project1']}
   config_writer = RallyQCUtils::ConfigWriter.new
   rally_xml = config_writer.construct_rally_xml(rally_info)
   parser = Nori.new(:parser => :rexml)
   loaded_config = parser.parse(rally_xml)
   assert_equal("workspace1",loaded_config["RallyConnection"]['WorkspaceName'])
   assert_equal("project1", loaded_config["RallyConnection"]['Projects']['Project'])
 end
end
