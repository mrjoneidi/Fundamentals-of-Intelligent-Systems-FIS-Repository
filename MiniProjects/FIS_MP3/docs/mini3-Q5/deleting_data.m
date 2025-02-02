% Read the Excel file into a table
data = readtable('AirQualityUCI.xlsx'); % Replace with your Excel file name

data = removevars(data, 'Time');
data = removevars(data, 'Date');
data = removevars(data, 'T');
data = removevars(data, 'RH');
data = removevars(data, 'NMHC_GT_');
data = removevars(data, 'PT08_S4_NO2_');

data = fillmissing(data, 'constant', mean(table2array(data), 'omitnan'));

writetable(data, 'new_dataAirQualityUCI.xlsx'); 