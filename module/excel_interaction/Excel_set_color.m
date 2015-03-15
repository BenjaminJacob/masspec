%Excelset color
function Excel_set_color(filename,rows,cols)
xls=actxserver('Excel.Application');%start excel server
wb = xls.Workbook.Open(filename);  %open file
wb.Sheets.Item(1).Activate;      %activate sheet 1
as=wb.ActiveSheet;               %remember active sheet
%as.Range([col2excelchar(col) num2str(row)]).Value %wert  .Orientation
%as.Range([col2excellchar(col) num2str(row)]).Value %wert
l=length(rows);
for i=1:l
    disp(['marking critical match ' num2str(i) ' / ' num2str(l)])

    row=rows(i);
    col=cols(i);
as.Range([col2excellchar(1) num2str(row)]).Interior.ColorIndex=46;%set color
as.Range([col2excellchar(col) num2str(row)]).Interior.ColorIndex=46;%set color
end
wb.Save;
wb.Close;
delete(xls);
end