require "nori"

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
          #connect to rally and get workspaces and projects
          rally = RallyQCUtils::RallyConnection.new(get_rally_info(@config))
          rally_data = rally.gather_config_info
          #write rally data to spreadsheet
          excel_writer = RallyQCUtils::ExcelWriter.new(@spreadsheet_name)
          excel_writer.write("Rally", rally_data)
          puts "closing file"
          excel_writer.close_file
          #connect to qc and get domain project and field info
          #write qc data to spreadsheet
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