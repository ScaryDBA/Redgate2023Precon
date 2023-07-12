# connect to the database
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server=adw.c2ek9ilzyxhz.us-east-1.rds.amazonaws.com;Database=AdventureWorks;trusted_connection=false;user=admin;password=$cthulhu1988'


#Load up Personnel data
$EmployeeListCmd = New-Object System.Data.SqlClient.SqlCommand
$EmployeeListCmd.CommandText = "SELECT  e.BusinessEntityID,
        e.OrganizationNode,
        e.LoginID,
        e.JobTitle,
        e.HireDate,
        e.CurrentFlag
FROM    HumanResources.Employee AS e;"
$EmployeeListCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $EmployeeListCmd
$EmployeeList = New-Object System.Data.DataSet
$SqlAdapter.Fill($EmployeeList)


# Modify Employee Logins
$UpdateLogin = New-Object System.Data.SqlClient.SqlCommand
$UpdateLogin.CommandText = "HumanResources.uspUpdateEmployeeLogin
    @BusinessEntityID = @BEID,
    @OrganizationNode = @OrgNode,
    @LoginID = @LID,
    @JobTitle = @Title,
    @HireDate = @Hire,
    @CurrentFlag = @Flag;"
$UpdateLogin.Parameters.Add("@BEID",[System.Data.SqlDbType]"Int")
##$UpdateLogin.Parameters.Add("@OrgNode",[System.Data.SqlDbType]"HIERARCHYID")
$UpdateLogin.Parameters.Add("@OrgNode",[System.Data.SqlDbType]"udt")
$UpdateLogin.Parameters["@OrgNode"].UDTTypeName = "HIERARCHYID"
#$UpdateLogin.Parameters.Add("@LID",[System.Data.SqlDbType]"VARCHAR(256)")
$UpdateLogin.Parameters.Add("@LID",[System.Data.SqlDbType]"varchar")
$UpdateLogin.Parameters.Add("@Title",[System.Data.SqlDbType]"varCHAR")
$UpdateLogin.Parameters.Add("@Hire",[System.Data.SqlDbType]"DATETIME")
$UpdateLogin.Parameters.Add("@Flag",[System.Data.SqlDbType]"BIT")
$UpdateLogin.Connection = $SqlConnection

# Load Product data
$ProdCmd = New-Object System.Data.SqlClient.SqlCommand
$ProdCmd.CommandText = "SELECT ProductID FROM Production.Product"
$ProdCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $ProdCmd
$ProdDataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($ProdDataSet)

# Load the Employee data
$EmpCmd = New-Object System.Data.SqlClient.SqlCommand
$EmpCmd.CommandText = "SELECT BusinessEntityID FROM HumanResources.Employee"
$EmpCmd.Connection = $SqlConnection
$SqlAdapter.SelectCommand = $EmpCmd
$EmpDataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($EmpDataSet)

# Set up the procedure to be run
$WhereCmd = New-Object System.Data.SqlClient.SqlCommand
$WhereCmd.CommandText = "dbo.uspGetWhereUsedProductID @StartProductID = @ProductId, @CheckDate=NULL"
$WhereCmd.Parameters.Add("@ProductID",[System.Data.SqlDbType]"Int")
$WhereCmd.Connection = $SqlConnection

# And another one
$BomCmd = New-Object System.Data.SqlClient.SqlCommand
$BomCmd.CommandText = "dbo.uspGetBillOfMaterials @StartProductID = @ProductId, @CheckDate=NULL"
$BomCmd.Parameters.Add("@ProductID",[System.Data.SqlDbType]"Int")
$BomCmd.Connection = $SqlConnection

# And one more
$ManCmd = New-Object System.Data.SqlClient.SqlCommand
$ManCmd.CommandText = "dbo.uspGetEmployeeManagers @BusinessEntityID =@EmpId"
$ManCmd.Parameters.Add("@EmpId",[System.Data.SqlDbType]"Int")
$ManCmd.Connection = $SqlConnection

# query with a missing index
$MissCmd = New-Object System.Data.SqlClient.SqlCommand
$MissCmd.CommandText = "SELECT A.PostalCode
FROM Person.ADDRESS AS A
WHERE A.StateProvinceID = 42;"
$MissCmd.Connection = $SqlConnection

# compile doesn't help
$CompileCmd = New-Object System.Data.SqlClient.SqlCommand
$CompileCmd.CommandText = "EXEC dbo.CustomerList @CustomerID = 30118;"
$CompileCmd.Connection = $SqlConnection

while(1 -ne 0)
{



        foreach($row in $EmployeeList.Tables[0])
{

    #$UpdateLogin.Parameters["@BEID"].Value = $row["BusinessEntityID"]
    #$UpdateLogin.Parameters["OrgNode"].Value = $row["OrganizationNode"]
	$SqlConnection.Open()
	$UpdateLogin.Parameters["@BEID"].Value = $row[0]
    $UpdateLogin.Parameters["@OrgNode"].Value = $row[1]
    $UpdateLogin.Parameters["@LID"].Value = $row[2]
    $UpdateLogin.Parameters["@Title"].Value = $row[3]
    $UpdateLogin.Parameters["@Hire"].Value = get-date
    $UpdateLogin.Parameters["@Flag"].Value = $row[5]
	$UpdateLogin.ExecuteNonQuery() | Out-Null
	$SqlConnection.Close()
		
foreach($row in $ProdDataSet.Tables[0])
	{
		$SqlConnection.Open()
		$ProductId = $row[0]
		$WhereCmd.Parameters["@ProductID"].Value = $ProductId
		$WhereCmd.ExecuteNonQuery() | Out-Null
		$SqlConnection.Close()
		
		foreach($row in $EmpDataSet.Tables[0])
		{
			$SqlConnection.Open()
			$EmpId = $row[0]
			$ManCmd.Parameters["@EmpID"].Value = $EmpId
			$ManCmd.ExecuteNonQuery() | Out-Null
			$SqlConnection.Close()
		}
		
		$SqlConnection.Open()
		$BomCmd.Parameters["@ProductID"].Value = $ProductId
		$BomCmd.ExecuteNonQuery() | Out-Null
		$SqlConnection.Close()
	}


	$SqlConnection.Open()
	$UpdateLogin.Parameters["@BEID"].Value = $row[0]
    $UpdateLogin.Parameters["@OrgNode"].Value = $row[1]
    $UpdateLogin.Parameters["@LID"].Value = $row[2]
    $UpdateLogin.Parameters["@Title"].Value = $row[3]
    $UpdateLogin.Parameters["@Hire"].Value = $row[4]
    $UpdateLogin.Parameters["@Flag"].Value = $row[5]
	$UpdateLogin.ExecuteNonQuery() | Out-Null
	$SqlConnection.Close()

    $SqlConnection.open()
    $MissCmd.ExecuteNonQuery() | Out-Null
    $SqlConnection.Close()

    $SqlConnection.Open()
    $CompileCmd.ExecuteNonQuery() | Out-Null
    $SqlConnection.Close()

}

}