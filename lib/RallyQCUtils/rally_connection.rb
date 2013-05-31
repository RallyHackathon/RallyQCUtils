require "rally_api"

module RallyQCUtils

  class RallyConnection
    attr_accessor :rally, :workspace_name
    attr_accessor :logger

    def initialize(rally_info = {}, logger = nil)
      @workspace_name = workspace_name
      @logger         = logger

      #or one line custom header
      headers = RallyAPI::CustomHttpHeader.new({
                                                   :vendor  => "Rally",
                                                   :name    => "RallyQCUtility",
                                                   :version => "#{RallyQCUtils::VERSION}"
                                               })

      config = {:base_url => "https://#{rally_info[:base_url]}/slm"}
      config[:username]   = rally_info[:username]
      config[:password]   = rally_info[:password]
      config[:headers]    = headers #from RallyAPI::CustomHttpHeader.new()

      @rally              = RallyAPI::RallyRestJson.new(config)
    end

    def gather_config_info
      user = @rally.user.read({:fetch => "Subscription,Workspaces"})
      workspaces = []
      user["Subscription"]["Workspaces"].each do |workspace|
        workspace.read({:fetch => "Projects,ObjectID,Name"})
        ws_meta = {:name => workspace["Name"], :id => workspace["ObjectID"]}
        projects = []
        workspace["Projects"].each do |proj|
          projects.push({:name => proj["Name"], :id => proj["ObjectID"]})
        end
        ws_meta[:projects] = projects
        workspaces.push(ws_meta)
        return workspaces
      end

    end


  end

end

