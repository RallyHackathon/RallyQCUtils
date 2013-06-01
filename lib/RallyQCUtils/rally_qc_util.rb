require "nori"
require "set"
module RallyQCUtils

  class RallyQCUtil

    def initialize(args)
      @operation        = args[0]
      case @operation
        when "--create"
          @spreadsheet_name = args[1]
          config_name       = args[2]    #todo check file exists?
          @config = RallyQCUtils.load_config(config_name)
        when "--generate"
          @spreadsheet_name = args[1]
          @location         = args[2]
      end

    end

    def run
      case @operation
        when "--create"
          #connect to qc and get domain project and field info
          #write qc data to spreadsheet
          qc_config = {
              :url            => @config["QCConnection"]["Url"],
              :qc_user        => @config["QCConnection"]["User"],
              :qc_password    => @config["QCConnection"]["Password"],
              :artifact_type  => @config["QCConnection"]["ArtifactType"]
          }
          hpqc = RallyQCUtils::QCConnection.new(qc_config)
          domains = hpqc.gather_qc_info
          fields = Set.new()
          project_array = []
          qc_data = []
          domains.each do |domain|
            domain_name = domain[:name]
            domain[:projects].each do |project|
              project_array.push([domain_name,project[:name]])
              project[:fields].each do |field|
                fields.add(field[:name])
              end
              field_array = fields.to_a
              project_array.each do |project|
                  row = project.concat(field_array)
                  qc_data.push(row)
              end
            end
          end
          excel_writer = RallyQCUtils::ExcelWriter.new(@spreadsheet_name)
          #write qc data to spreadsheet
          excel_writer.write("HPQC", qc_data)
          #connect to rally and get workspaces and projects
          rally = RallyQCUtils::RallyConnection.new(get_rally_info(@config))
          rally_data = rally.gather_config_info
          #write rally data to spreadsheet
          excel_writer.write("Rally", rally_data)
          excel_writer.close_file
        when "--generate"
          #read spreadsheet and generate sample configs
      end

    end

    def get_rally_info(config_hash)
      puts config_hash
      rally_config = {}
      rally_config[:base_url]      = config_hash["RallyConnection"]["Url"]
      rally_config[:username]      = config_hash["RallyConnection"]["User"]
      rally_config[:password]      = config_hash["RallyConnection"]["Password"]
      rally_config[:artifact_type] = config_hash["RallyConnection"]["ArtifactType"]
      rally_config
    end

    def get_qc_info(config_hash)
      qc_config = {}
      qc_config[:base_url]      = config_hash["QCConnection"]["Url"]
      qc_config[:username]      = config_hash["QCConnection"]["User"]
      qc_config[:password]      = config_hash["QCConnection"]["Password"]
      qc_config[:artifact_type] = config_hash["QCConnection"]["ArtifactType"]
      qc_config
    end

  end



  def self.load_config(config_name)
    return config_name if config_name.is_a?(Hash)
    parser = Nori.new(:parser => :rexml)
    config = File.read(config_name)
    loaded_config = parser.parse(config)
    return loaded_config["Config"]
  end

end