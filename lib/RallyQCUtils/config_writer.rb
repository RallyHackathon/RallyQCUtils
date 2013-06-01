module RallyQCUtils

  #expects the following
  #rally_info = {
  #    'Url'             => "rally1.rallydev.com",
  #    'WorkspaceName'   => "Test",
  #    'Projects'        => [ "Project1" ],
  #    'User'            => "user@company.com",
  #    'Password'        => "apassword",
  #    'ArtifactType'    => "Story",
  #    'ExternalIDField' => "QCID"
  #}
  #
  #qc_info = {
  #    'Url'                     => "vmqc11:8080",
  #    'Domain'                  => "DomainTest",
  #    'Project'                 => "QCProject1",
  #    'User'                    => "user@company.com",
  #    'Password'                => "apassword",
  #    'ArtifactType'            => "REQ",
  #    'ExternalIDField'         => "RQ_USER_01",
  #    'ExternalEndUserIDField'  => "RQ_USER_02"
  #}
  #
  #fields = {
  #    'Name'         => "RQ_REQ_NAME",
  #    'Description'  => 'RQ_REQ_COMMENT',
  #    'Priority'     => 'RQ_REQ_PRIORITY'
  #}




  class ConfigWriter

    RALLY_ELEMENTS = %w(Url WorkspaceName Projects User Password ArtifactType ExternalIDField)
    QC_ELEMENTS    = %w(Url Domain Project User Password ArtifactType ExternalIDField ExternalEndUserIDField)
    CONN_RUNNER    = "<ConnectorRunner>
  <Preview>False</Preview>
  <LogLevel>Debug</LogLevel>
  <Services>COPY_RALLY_TO_QC, UPDATE_QC_TO_RALLY</Services>
</ConnectorRunner>"

    def initialize()
    end

    def write_config_file(file_name_with_path, data)
      file_contents = gen_file(data)
      File.open(file_name_with_path, "wb") {|f| f.write(file_contents) }
    end

    def gen_file(data)
      rally_xml = construct_rally_xml(data[:rally])
      qc_xml    = construct_qc_xml(data[:qc])
      fields_xml= construct_field_mapping_xml(data[:fields])
      file_contents = "<?xml version=\"1.0\"?>\n<Config>\n"
      file_contents << rally_xml << "\n\n"
      file_contents << qc_xml
      file_contents << "\n\n<Connector>\n#{fields_xml}\n</Connector>\n"
      file_contents << "\n#{CONN_RUNNER}\n</Config>\n"
      file_contents
    end

    def construct_rally_xml(rally_info)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.RallyConnection() {
          RALLY_ELEMENTS.each do |elname|
            if elname == "Projects"
              xml.Projects {
                rally_info['Projects'].each do |prj|
                  xml.Project prj
                end
              }
              next
            end
            xml.send(:"#{elname}", rally_info[elname])
          end
        }
      end
      return_xml = builder.doc.root.to_xml
      puts "rally xml is:\n#{return_xml}\n\n"
      return_xml
    end

    def construct_qc_xml(qc_info)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.QCConnection() {
          QC_ELEMENTS.each do |elname|
            xml.send(:"#{elname}", qc_info[elname])
          end
        }
      end
      return_xml = builder.doc.root.to_xml
      puts "qc xml is:\n#{return_xml}\n\n"
      return_xml
    end

    def construct_field_mapping_xml(fields_hash)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.FieldMapping() {
          fields_hash.each do |rally_field, qc_field|
            xml.Field {
              xml.Rally rally_field
              xml.Other qc_field
            }
          end
        }
      end
      return_xml = builder.doc.root.to_xml
      puts "field mapping xml is:\n#{return_xml}\n\n"
      return_xml
    end


  end

end