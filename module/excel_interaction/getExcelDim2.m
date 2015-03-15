function [rowEnd colEnd]=getExcelDim2(filename,sheet)

excelObj = actxserver ('Excel.Application');

% Full path to your file required
fileObj = excelObj.Workbooks.Open(filename);

sheetObj = excelObj.Worksheets.get('Item', sprintf('Sheet%i',sheet));

% Row end, appears to work for rectangular data in sheet.
rowEnd = sheetObj.Range('A1').End('xlDown').Row;
% Column end for first row
colEnd = sheetObj.Range('A1').End('xlToRight').Column;

%
%excelObj.Workbooks.Close;
fileObj.Close
delete(fileObj);