# connect to the database
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = 'Server=adw.c2ek9ilzyxhz.us-east-1.rds.amazonaws.com;Database=AdventureWorks;trusted_connection=false;user=admin;password=$cthulhu1988'

# gather values 
$RefCmd = New-Object System.Data.SqlClient.SqlCommand
$RefCmd.CommandText = "SELECT th.ReferenceOrderID,
       COUNT(th.ReferenceOrderID) AS RefCount
FROM Production.TransactionHistory AS th
GROUP BY th.ReferenceOrderID;"
$RefCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $RefCmd
$RefData = New-Object System.Data.DataSet
$SqlAdapter.Fill($RefData)

# Execute a stored procedure
$Sniffcmd = New-Object System.Data.SqlClient.SqlCommand
$Sniffcmd.CommandType = [System.Data.CommandType]'StoredProcedure'
$Sniffcmd.CommandText = "dbo.ProductTransactionHistoryByReference"
$Sniffcmd.Parameters.Add("@ReferenceOrderID",[System.Data.SqlDbType]"Int")
$Sniffcmd.Connection = $SqlConnection

# Optionally, clear the cache
$SniffFreecmd = New-Object System.Data.SqlClient.SqlCommand
$SniffFreecmd.CommandText = "DECLARE @plan_handle VARBINARY(64);

SELECT @plan_handle = deps.plan_handle
FROM sys.dm_exec_procedure_stats AS deps
WHERE deps.object_id = OBJECT_ID('dbo.ProductTransactionHistoryByReference');

DBCC FREEPROCCACHE(@plan_handle);"
$SniffFreecmd.Connection = $SqlConnection

# Count the executions
$x = 0
# Test, instead of counting, working off of time based cache clears
#$ts = New-TimeSpan -Minutes 7;
#$compareDate = (Get-Date) + $ts;
$timer = [System.Diagnostics.Stopwatch]::StartNew()
$timer.Elapsed
while(1 -ne 0)
{

foreach($row in $RefData.Tables[0])
        {

        # Establish an occasional wait
        $check = get-random -Minimum 7 -Maximum 20
        $wait = $x % $check

        if ($wait -eq 0)
        {
            #set a random sleep period in seconds
            $waittime = get-random -minimum 3 -maximum 13
            start-sleep -s $waittime
            $x = 0}

        # Up the count
        $x += 1

        # Execute the procedure
        $RefID = $row[0]
        $SqlConnection.Open()
        $Sniffcmd.Parameters["@ReferenceOrderID"].Value = $RefID
        $Sniffcmd.ExecuteNonQuery() | Out-Null
        $SqlConnection.Close()

        # clear the cache on each execution
        #$SqlConnection.Open()
        #$Freecmd.ExecuteNonQuery() | Out-Null
        #$SqlConnection.Close()
        
        # clear the cache based on random
        #$check = get-random -Minimum 18 -Maximum 40
        #$clear = $x % $check
        #if($clear -eq 4)
        #{
        #    $SqlConnection.Open()
        #    $SniffFreecmd.ExecuteNonQuery() | Out-Null
        #    $SqlConnection.Close()
        #}
        if($timer.Elapsed.Minutes > 17)
        {
            $SqlConnection.Open()
            $SniffFreecmd.ExecuteNonQuery() | Out-Null
            $SqlConnection.Close()
            $timer.Restart();
        }
    }
}