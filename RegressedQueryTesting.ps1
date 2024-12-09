# connect to the database
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server=adw.c2ek9ilzyxhz.us-east-1.rds.amazonaws.com;Database=AdventureWorks;trusted_connection=false;user=admin;password=$cthulhu1988'


# Execute a stored procedure
$Regresscmd = New-Object System.Data.SqlClient.SqlCommand
$Regresscmd.CommandType = [System.Data.CommandType]'StoredProcedure'
$Regresscmd.CommandText = "dbo.AddressByCity"
$Regresscmd.Parameters.Add("@City",[System.Data.SqlDbType]"VARCHAR")
$Regresscmd.Connection = $SqlConnection

# Optionally, clear the cache
$Freecmd = New-Object System.Data.SqlClient.SqlCommand
$Freecmd.CommandText = "DECLARE @plan_handle VARBINARY(64);

SELECT @plan_handle = deps.plan_handle
FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.AddressByCity');

IF @plan_handle IS NOT NULL
BEGIN
DBCC FREEPROCCACHE(@plan_handle);
END"
$Freecmd.Connection = $SqlConnection



while(1 -ne 0)
{
        # clear the cache on each execution
        $SqlConnection.Open()
        $Freecmd.ExecuteNonQuery() | Out-Null
        $SqlConnection.Close()

        For ($i=1; $i -lt 100; $i++)  
    {
        $SqlConnection.Open()
        $Regresscmd.Parameters["@City"].Value = 'Mentor'
        $Regresscmd.ExecuteNonQuery() | Out-Null
        $SqlConnection.Close()
    }


    }
