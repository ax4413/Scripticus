# Convert a csv file to a xlsx file
# the xlsx file is saved to teh same loaction as teh csv file

# Define a file for converion 
$csvpath= 'C:\Users\syeadon\Desktop\test.csv'
# new up a excel obj
$xl=New-Object -com "Excel.Application" 
# Access the workbook
$wb=$xl.workbooks.open($csvpath)
# Define the location to save the xlsx file
$xlout=$csvpath.Replace('.csv','.xlsx') 
# Save the file
$wb.SaveAs($xlOut,51) 
# close the excel doc
$xl.Quit()