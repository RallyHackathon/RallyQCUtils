require "csv"

module RallyQCUtils

  class ExcelCsvReader

    #QC Domain	QC Project	Rally Workspace	Rally Workspace ID	Rally Project	Rally Project ID	RQ_REQ_NAME	RQ_REQ_COMMENT	RQ_USER_01
    #DomainA	ProjectA	TestWorkspace	12345	Team1	987	Name	Description	Custom1
    #DomainA	ProjectB	TestWorkspace	12345	Team2	654	Name	Description	Custom1
    def initialize(file_name)
      file_name << ".csv"
      begin
        @csv = CSV.read(file_name)
      rescue Exception => ex
        puts "Error reading csv #{ex.message}.\n#{ex.backtrace.join("\n")}"
        raise ex
      end
      @csv
    end

    def read_rows()
      @headers = get_headers
      @data = @csv.slice(1..@csv.length)
    end

    def get_headers
      @csv[0]
    end

    def gather_info
      configs = []
      @data.each do |row|
        #gather_rally
        rally_info = { 'WorkspaceName' => row[2], 'Projects' => [row[4]] }
        #gather_qc
        qc_info = { 'Domain' => row[0], 'Project' => row[1] }
        #gather_fields
        fields = {}
        object_id_found   = false
        formatted_id_found = false
        row(6..row.length).each_with_index do |rally_field, index|
          next if rally_field.empty?
          qc_field = @headers[index]
          if (rally_field == "FormattedID")
            formatted_id_found = true
            qc_info['ExternalEndUserIDField'] = qc_field
            next
          end
          if (rally_field == "ObjectID")
            object_id_found = true
            qc_info['ExternalIDField'] = qc_field
            next
          end
          fields[rally_field] = qc_field
        end

        unless object_id_found
          puts "Error mapping QC Domain:#{qc_info['Domain']} - Project:#{qc_info['Project']}. Missing ObjectID mapping"
          next
        end

        unless formatted_id_found
          puts "Error mapping QC Domain:#{qc_info['Domain']} - Project:#{qc_info['Project']}. Missing FormattedID mapping"
          next
        end

        configs.push({:rally => rally_info, :qc => qc_info, :fields => fields})
      end

    end

  end

end
