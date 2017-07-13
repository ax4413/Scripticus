cls
$conn = new-object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "server=SQLPRODBASE;database=ClinicalImageLeightons;User Id=sa;Password=0pt1c5##;"
$cmd = new-object System.Data.SqlClient.SqlCommand
$cmd.CommandText = "SELECT TOP 10 [ClinicalImageIntID]
      ,[FullClinicalImage]
      ,[CreateTime]
  FROM [ClinicalImageLeightons].[Leightons].[ClinicalImageCentralFS]
  WHERE IsFundus = 1"
$cmd.Connection = $conn
$adapter = new-object System.Data.SqlClient.SqlDataAdapter
$adapter.SelectCommand = $cmd
$ds = new-object System.Data.DataSet
$adapter.Fill($ds)
$conn.close()
$ds.Tables[0]


while(1)
{
	$val = read-host "Select a ROW NUMBER or press q to quit"
	if($val -eq "q") { return }

	$val = [int] $val

	$bytes = $ds.Tables[0].Rows[$val][1]

	[void][reflection.assembly]::LoadWithPartialName("System.IO")
	$memoryStream = new-object System.IO.MemoryStream
	#$memoryStream.write($bytes,78,$bytes.Length - 78)
	$memoryStream.write($bytes,0,$bytes.Length)

	[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
	$form = new-object Windows.Forms.Form
	$form.Text = "Image Viewer"
	$pictureBox = new-object Windows.Forms.PictureBox
	$pictureBox.Width = 3000
	$pictureBox.Height = 3000

	$pictureBox.Image = [System.Drawing.Image]::FromStream($memoryStream)
	$form.controls.add($pictureBox)
	$form.Add_Shown( { $form.Activate() } )
	$form.ShowDialog()
}