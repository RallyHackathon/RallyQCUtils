require "win32ole"

module RallyQCUtils

  class ExcelWriter
    
      attr_reader :file_name, :current_row
    
      def initialize(file_name)
        begin
          @file_name = "#{file_name}.xlsx"
          @xl = WIN32OLE.new('Excel.Application')
          @book = nil
          @current_row = {"Data" => 1, "Rally"=>1, "HPQC" => 1}
          create_file
        rescue Exception => ex
          excel_rescue(ex.message)
        end
      end
    
      #def write_header_row(row_data)
      #  write_row(1, row_data)
      #end
    
      def add_row(sheetname, row_data)
        @current_row[sheetname] += 1
        write_row(sheetname,@current_row[sheetname], row_data)
      end
    
      def write_row(sheetname, row_num, row_data)
        col_count = 0
        row_data.each do |cellval|
          col_count += 1
          case sheetname
            when "Data"
               write_cell(@sheet1,{"row" => row_num, "column" => col_count}, cellval)
            when "Rally"
               write_cell(@sheet2,{"row" => row_num, "column" => col_count}, cellval)
            when "HPQC"
              write_cell(@sheet3,{"row" => row_num, "column" => col_count}, cellval)
          end
        end
      end
    
      def close_file
        @sheet1.Columns.Autofit
        @book.Save
        @book.Close
        @xl.Quit
        @book = nil
      end
    
def write(sheetname, data)
  case sheetname
    when "Rally"
      add_row("Rally",["workspace name", "workspace id", "project name", "project id"])
      data.each do |values|
        workspace_name = values[:name]
        workspace_id = values[:id]
        begin
        values[:projects].each do |project|
          add_row("Rally",["#{workspace_name}","#{workspace_id}","#{project[:name]}","#{project[:id]}"])
        end
        rescue Exception => ex
          puts "exception was #{ex.message}"
        end
      end
    when "QC"
      header_data = ["domain","project"].concat(data[0].slice(2..data.size))
      add_row("HPQC",header_data)
      data.each do |values|
        add_row("HPQC",[values[0], values[1]])
      end
  end
end

#------------------------------------------------------------------------------------
    
      private
    
      def create_file
        @book = @xl.Workbooks.Add
        @sheet1 = @book.WorkSheets(1)
        @sheet2 = @book.WorkSheets(2)
        @sheet3 = @book.WorkSheets(3)
        @sheet1.Name = "Data"
        @sheet2.Name = "Rally"
        @sheet3.Name= "HPQC"
        
        current_dir = Dir.pwd.gsub("/","\\")
        puts "#{current_dir}\\#{file_name} - created."
        @book.SaveAs("#{current_dir}\\#{@file_name}")
      end
    
      def write_cell(sheet, location, value)
        begin
          sheet.Cells(location["row"],location["column"]).Value = value
        rescue Exception => ex
          excel_rescue(ex.message)
          puts ex.backtrace
        end
      end
    
      def excel_rescue(msg)
        puts "An error occurred working with Excel - the message was:  #{msg}"
      end
    

  end
end
