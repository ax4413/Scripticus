function Show-BarChart($Title, $xAxisName, $yAxisName, $data, $height = 400, $width = 400){
    # http://blogs.technet.com/b/richard_macdonald/archive/2009/04/28/3231887.aspx

    # load the appropriate assemblies
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

    # create chart object
    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $Chart.Width = $width
    $Chart.Height = $height
    $Chart.Left = 10
    $Chart.Top = 10

    # create a chartarea to draw on and add to chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    # add title and axes labels
    [void]$Chart.Titles.Add($Title)
    $ChartArea.AxisX.Title = $xAxisName
    $ChartArea.AxisY.Title = $yAxisName

    $Chart.ChartAreas.Add($ChartArea)

    # add data to chart
    [void]$Chart.Series.Add("Data")
    $Chart.Series["Data"].Points.DataBindXY($data.Keys, $data.Values)

    # Find point with max/min values and change their colour
    $maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue()
    $maxValuePoint.Color = [System.Drawing.Color]::Red

    $minValuePoint = $Chart.Series["Data"].Points.FindMinByValue()
    $minValuePoint.Color = [System.Drawing.Color]::Green

    # make bars into 3d cylinders
    $Chart.Series["Data"]["DrawingStyle"] = "Cylinder"

    # display the chart on a form
    $Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
                    [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
    $Form = New-Object Windows.Forms.Form
    $Form.Text = $Title
    $Chart.BackColor = [System.Drawing.Color]::Transparent
    $Form.Width = ($width  + 50)
    $Form.Height = ($height  + 50)
    $Form.controls.add($Chart)
    $Form.Add_Shown({$Form.Activate()})
    $Form.ShowDialog()
}