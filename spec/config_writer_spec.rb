require 'rspec'
require_relative 'spec_helper'

describe 'Config writer tests' do

  rally_info = {
      'Url'             => "rally1.rallydev.com",
      'WorkspaceName'   => "Test",
      'Projects'        => [ "Project1" ],
      'User'            => "user@company.com",
      'Password'        => "apassword",
      'ArtifactType'    => "Story",
      'ExternalIDField' => "QCID"
  }

  qc_info = {
      'Url'                     => "vmqc11:8080",
      'Domain'                  => "DomainTest",
      'Project'                 => "QCProject1",
      'User'                    => "user@company.com",
      'Password'                => "apassword",
      'ArtifactType'            => "REQ",
      'ExternalIDField'         => "RallyObjectID",
      'ExternalEndUserIDField'  => "RallyID"
  }

  fields = {
      'RQ_REQ_NAME'     => "Name",
      'RQ_REQ_COMMENT'  => "Description",
      'RQ_REQ_PRIORITY' => "Priority"
  }

  it 'should construct rally xml' do
    configger = RallyQCUtils::ConfigWriter.new({:file_name => "test.xml"})
    rallyxml = configger.construct_rally_xml(rally_info)
    rallyxml.should_not be_nil
  end

  it 'should construct qc xml' do
    configger = RallyQCUtils::ConfigWriter.new({:file_name => "test.xml"})
    qcxml = configger.construct_qc_xml(qc_info)
    qcxml.should_not be_nil
  end

  it 'should construct field mappings xml' do
    configger = RallyQCUtils::ConfigWriter.new({:file_name => "test.xml"})
    xml = configger.construct_field_mapping_xml(fields)
    xml.should_not be_nil
  end

  it "should generate a whole config file" do
    configger = RallyQCUtils::ConfigWriter.new({:file_name => "test.xml"})
    data = {
        :rally  => rally_info,
        :qc     => qc_info,
        :fields => fields
    }
    xml = configger.gen_file(data)
    puts "xml is:\n#{xml} "
    xml.should_not be_nil
  end

end