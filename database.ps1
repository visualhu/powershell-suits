function New-SqlConnection([string]$connectionStr){
    $SqlConnection=New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString=$connectionStr

    try{
        $SqlConnection.Open()
        Write-Host 'Connected to sql server...'
        return $SqlConnection
    }
    catch [exception]{
        Write-Warning ('Connect to database failed with error message:{0}',$_)
        $SqlConnection.Dispose()
        return $null
    }
}

function Get-SqlDataTable{
    param(
        [System.Data.SqlClient.SqlConnection]$SqlConnection,
        [string]$query
    )

    $dataSet=New-Object "System.Data.DataSet" 
    $dataAdapter=New-Object "System.Data.SqlClient.SqlDataAdapter" ($query,$SqlConnection)
    $dataAdapter.Fill($dataSet) |Out-Null

    return $dataSet.Tables  | Format-Table -Auto   
}

function Execute-SqlCommandNonQuery{
    param(
        [System.Data.SqlClient.SqlConnection]$SqlConnection,
        [string]$Comman
    )
    $cmd=$SqlConnection.CreateCommand()
    try{
        $cmd.CommandText=$Comman
        $cmd.ExecuteNonQuery()| Out-Null
        return $true
    }
    catch [exception]{
        Write-Warning ('Execute Sql command failed with error message:{0}' -f $_)
        return $false

    }
    finally{
        $SqlConnection.Dispose()
    }
}

function Execute-SqlCommandsNonQuery{
    param(
        [System.Data.SqlClient.SqlConnection]$SqlConnection,
        [string[]]$Commans
    )
    $transaction =$SqlConnection.BeginTransaction()
    $cmd=$SqlConnection.CreateCommand()
    $cmd.Transaction=$transaction
    try{
        foreach($c in $Commans){
            $cmd.CommandText=$c
            $cmd.ExecuteNonQuery()
        }

        $transaction.Commit()
        return $true
    }
    catch [exception]{
        Write-Warning ('Execute Sql command failed with error message:{0}' -f $_)
        return $false

    }
    finally{
        $SqlConnection.Dispose()
    }
}

$Database           ="cnmdb"
$Server             ="uatinstance.cszyq4yedzjj.ap-southeast-1.rds.amazonaws.com"
$UserName           ="uatinstance"
$Password           ="Sunshine01"

$SqlQuery           ="select top 10 * from customerprofile"

[string]$connectionStr      ="Data Source=$server;Initial Catalog=$Database;user id=$UserName;pwd=$Password"

$connection=New-SqlConnection $connectionStr

Get-SqlDataTable $connection $SqlQuery
