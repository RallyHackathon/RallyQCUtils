module RallyQCUtils
  class ExcelWriter
    def initialize(spreadsheet_name)
      @spreadsheet_name = spreadsheet_name
    end

    def write(sheetname, data)
      case sheetname
        when "Rally"
          puts "workspace name, workspace id, project name, project id"
          data.each do |values|
            workspace_name = values[:name]
            workspace_id = values[:id]
            begin
            values[:projects].each do |project|
              puts "#{workspace_name},#{workspace_id},#{project[:name]},#{project[:id]}"
            end
            rescue Exception => ex
              puts "exception was #{ex.message}"
            end
          end
        when "QC"
          data.each do |values|
            puts values
          end
      end
    end
  end
end
