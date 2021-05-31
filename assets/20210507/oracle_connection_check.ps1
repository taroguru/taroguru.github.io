add-type -AssemblyName System.Data.OracleClient

$username = "smail"
$password = "rnrmf9apps"
$data_source = "(DESCRIPTION=
                    (ADDRESS_LIST=
                        (ADDRESS=
                            (PROTOCOL=TCP)
                            (HOST=dauadm.donga.ac.kr)
                            (PORT=1522) 
                        )
                    )
                    (CONNECT_DATA=
                        (SERVICE_NAME=ora7)
                    )
                );"
$connection_string = "User Id=$username;Password=$password;Data Source=$data_source"

$statement = "select level, level + 1 as Test from dual CONNECT BY LEVEL <= 10"

try{
    $con = New-Object System.Data.OracleClient.OracleConnection($connection_string)

    $con.Open()

    $cmd = $con.CreateCommand()
    $cmd.CommandText = $statement

    $result = $cmd.ExecuteReader()
    # Do something with the results...

} catch {
    Write-Error ("Database Exception: {0}\n{1}" -f `
        $con.ConnectionString, $_.Exception.ToString())
} finally{
    if ($con.State -eq 'Open') { $con.close() }
}