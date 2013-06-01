import xlrd
import sys
def main():
   workbook_name = eval(sys.argv[1])
   sheet_name = eval(sys.argv[2])
   f = open(sheet_name + ".csv","w")
   workbook = xlrd.open_workbook(workbook_name+".xlsx")
   sheet = workbook.sheet_by_name("Data")
   num_rows = sheet.nrows - 1
   num_cells = sheet.ncols - 1
   curr_row = -1
   while curr_row < num_rows:
       curr_row += 1
       row_is_empty = True
       row = sheet.row(curr_row)
       curr_cell = -1
       row_array = []
       while curr_cell < num_cells:
           curr_cell += 1
           # Cell Types: 0=Empty, 1=Text, 2=Number, 3=Date, 4=Boolean, 5=Error, 6=Blank
           cell_type = sheet.cell_type(curr_row, curr_cell)
           cell_value = sheet.cell_value(curr_row, curr_cell)
           if cell_type == 0:
               row_array.append('')
           elif cell_type ==1:
               row_is_empty = False
               row_array.append(str(cell_value))
           elif cell_type > 1:
               row_is_empty = False
               row_array.append(str(int(cell_value)))
       if not row_is_empty:
           f.write( ",".join(row_array)+"\n")
if __name__ == '__main__':
    main()