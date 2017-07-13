cls
# db connection
$conn = new-object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "server=moon;database=oecentral2008-Import;User Id=sa;Password=system;"
# sql command
$cmd = new-object System.Data.SqlClient.SqlCommand
$cmd.CommandText = "select image from Image where ImageID = 'B6081C67-1D69-49FE-8658-FD2C25AB37B9'"
# create a db connection
$cmd.Connection = $conn
$adapter = new-object System.Data.SqlClient.SqlDataAdapter
$adapter.SelectCommand = $cmd
# create and fill a dataset
$ds = new-object System.Data.DataSet
$adapter.Fill($ds)
$conn.close()
$ds.Tables[0]



# zero based array
# Table 0 Row 0 Column 0
$bytes = $ds.Tables[0].Rows[0][0]

# using reflection load a System.IO.MemoryStream obj
[void][reflection.assembly]::LoadWithPartialName("System.IO")
$memoryStream = new-object System.IO.MemoryStream
$memoryStream.write($bytes,0,$bytes.Length)

# using reflection load a System.Windows.Form
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
$form = new-object Windows.Forms.Form
$form.Text = "Image Viewer"
$pictureBox = new-object Windows.Forms.PictureBox
#$pictureBox.SizeMode = PictureBoxSizeMode.StretchImage
$pictureBox.Width = 3000
$pictureBox.Height = 3000

# display the image in the form
$pictureBox.Image = [System.Drawing.Image]::FromStream($memoryStream)
$form.controls.add($pictureBox)
$form.Add_Shown( { $form.Activate() } )
$form.ShowDialog()
