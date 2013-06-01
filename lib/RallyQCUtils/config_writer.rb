module RallyQCUtils

  class ConfigWriter

    RALLY_ELEMENTS = %w(Url WorkspaceName Projects User Password ArtifactType ExternalIDField)
    QC_ELEMENTS    = %w(Url Domain Project User Password ArtifactType ExternalIDField ExternalEndUserIDField)
    CONN_RUNNER    = "<ConnectorRunner>
  <Preview>False</Preview>
  <LogLevel>Debug</LogLevel>
  <Services>COPY_RALLY_TO_QC, UPDATE_QC_TO_RALLY</Services>
</ConnectorRunner>"

    def initialize(file_options)
      @file_name = file_options[:file_name]
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
          fields_hash.each do |qc_field, rally_field|
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


    def entity_to_xml(type, hash_fields)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.Entity(:Type => type) {
          xml.Fields{
            hash_fields.each do |field_name, value|
              xml.Field(:Name => field_name) { xml.Value value }
            end
          }
        }
      end
      return_xml = builder.doc.root.to_xml
      puts "entity hash to xml is #{return_xml}\n\n"
      return_xml
    end


  end

end