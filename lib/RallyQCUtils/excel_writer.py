
import xlwt
import sys
import os

class ExcelWriter(object):
    def __init__(self,file_name):
        self.file_name = file_name+".xlsx"
        self.current_row = {"Data" : 1, "Rally" : 1, "HPQC" : 1}
        self.create_file()
        
    def add_row(self,sheetname, row_data):
        self.current_row[sheetname] += 1
        self.write_row(sheetname,self.current_row[sheetname], row_data)
    
    def write_row(self, sheetname, row_num, row_data):
        col_count = 0
        for cellval in row_data:
            col_count += 1
            if sheetname == "Data":
               self.write_cell(self.sheet1,{"row" : row_num, "column" : col_count}, cellval)
            elif sheetname=="Rally":
               self.write_cell(self.sheet2,{"row" : row_num, "column" : col_count}, cellval)
            elif sheetname=="HPQC":
               self.write_cell(self.sheet3,{"row" : row_num, "column" : col_count}, cellval)
    
    def close_file(self):
        cwd = os.getcwd()
        self.book.save(cwd + "/" + self.file_name)
    
    def write(self,sheetname, data):
        if sheetname == "Rally":
            self.add_row("Rally",["workspace name", "workspace id", "project name", "project id"])
            for values in data:
                workspace_name = values["name"]
                workspace_id = values["id"]
                for project in values["projects"]:
                    self.add_row("Rally",[workspace_name,workspace_id,project["name"],project["id"]])
        elif sheetname== "HPQC":
            # write header row
            header_row = ["domain","project"]
            self.add_row("HPQC",header_row)
            for values in data:
                self.add_row("HPQC",values[0:2])
        elif sheetname == "Data":
            self.add_row("Data",data)
    
    def create_file(self):
        self.book = xlwt.Workbook()
        self.sheet1 = self.book.add_sheet("Data")
        self.sheet2 = self.book.add_sheet("Rally")
        self.sheet3 = self.book.add_sheet("HPQC")
            
    def write_cell(self,sheet, location, value):
        sheet.write(location["row"],location["column"], value)
        
def main():
    filename = sys.argv[1]
    rally_data = eval(sys.argv[2])
    hpqc_data= eval(sys.argv[3])
    data_data = eval(sys.argv[4])
    excel = ExcelWriter(filename)
    excel.write("Rally",rally_data)
    excel.write("HPQC",hpqc_data)
    excel.write("Data",data_data)
    
    excel.close_file()
    
if __name__ == '__main__':
    main()