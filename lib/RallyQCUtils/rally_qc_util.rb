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
          config_name       = args[2]    #todo check file exists?
          @config = RallyQCUtils.load_config(config_name)
          @location         = args[3]
      end

    end
    def create_python_dict(data)
        data_str = data.to_s
        data_str.gsub!(":name","\"name\"")
        data_str.gsub!("=>",":")
        data_str.gsub!(":id","\"id\"")
        data_str.gsub!(":projects","\"projects\"")
        data_str
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
          field_data = []
          qc_data = []
          domains.each do |domain|
            domain_name = domain[:name]
            domain[:projects].each do |project|
              qc_data.push([domain_name,project[:name]])
              project[:fields].each do |field|
                fields.add(field[:name].to_s)
              end
            end
          end
          field_data = fields.to_a
          #connect to rally and get workspaces and projects
          rally = RallyQCUtils::RallyConnection.new(get_rally_info(@config))
          rally_data = rally.gather_config_info
          # data sheet is just the first row of the qc_data replacing the first
          # two cells

          data_data = ["QC Domain","Project","Rally Workspace", "Rally Workspace ID","Rally Project", "Rally Project ID"].concat(field_data)
          #write data to spreadsheet
          rally_dict = create_python_dict(rally_data)
          script_name = "#{File.dirname(__FILE__)}/excel_writer.py"
          system("python",script_name,"hpqc_template",  "'" + rally_dict + "'" ,"'" + qc_data.to_s + "'", "'" + data_data.to_s + "'")
        when "--generate"
          read_csv_and_write_configs
      end

    end

    def read_csv_and_write_configs
      #read spreadsheet and generate sample configs
      csv_name = @spreadsheet_name + "-csv"
      script_name = "#{File.dirname(__FILE__)}/excel_reader.py"
      system("python",script_name,"\"#{@spreadsheet_name}\"","\"#{csv_name}\"")
      csv = RallyQCUtils::ExcelCsvReader.new("#{csv_name}")
      configs = csv.gather_info
      #add rally and qc info
      config_writer = RallyQCUtils::ConfigWriter.new
      configs.each do |config|
        add_rally_to_config(config[:rally])
        add_qc_to_config(config[:qc])
        file_name = "#{config[:qc]['Domain']}_#{config[:qc]['Project']}_#{config[:qc]['ArtifactType']}.xml"
        file_with_path = @location + "/" + file_name
        config_writer.write_config_file(file_with_path, config)
      end
    end

    def add_rally_to_config(config)
      config['Url']             = @config["RallyConnection"]["Url"]
      config['User']            = @config["RallyConnection"]["User"]
      config['Password']        = @config["RallyConnection"]["Password"]
      config['ArtifactType']    = @config["RallyConnection"]["ArtifactType"]
      config['ExternalIDField'] = @config["RallyConnection"]["ExternalIDField"]
    end

    def add_qc_to_config(config)
      config['Url']             = @config["QCConnection"]["Url"]
      config['User']            = @config["QCConnection"]["User"]
      config['Password']        = @config["QCConnection"]["Password"]
      config['ArtifactType']    = @config["QCConnection"]["ArtifactType"]
    end

    def get_rally_info(config_hash)
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