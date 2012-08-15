xquery version "3.0";
(:~ 
: database admin tasks
: @author andy bunce
: @since aug 2012
:)

module namespace dbadmin = 'apb.restlib.dbadmin';
declare default function namespace 'apb.restlib.dbadmin';
declare namespace client="http://basex.org/modules/client";

 
(:~ 
: ensure db exists
:) 
declare function create($dbname as xs:string,$loadpath as xs:string){
    let $c := connect()
    let $path:=fn:resolve-uri($loadpath)
    let $path:=file:path-to-native($path)

	let $cmd:="CREATE DB " || $dbname || " " || $path	
    return 

        if (db:exists($dbname))
        then "Database found."
        else  fn:string-join((client:execute($c, "SET CHOP FALSE"), 
		       client:execute($c, $cmd),
			   "Database created.")) 
};

(:~ 
: drop database
:) 
declare function drop($dbname as xs:string){
    let $c := connect()
	return (client:execute($c, "DROP DB "|| $dbname),"Database dropped")  
};

(:~
: backup database
:) 
declare function backup($dbname as xs:string){
    let $c := connect()
    return (client:execute($c, "CREATE BACKUP "|| $dbname),"Database backed up")  
};

(:~
: restore database
:) 
declare function restore($dbname as xs:string){
    let $c := connect()
    return (client:execute($c, "RESTORE "|| $dbname),"Database restored")  
};

(:~
: export database
:) 
declare function export($dbname as xs:string,$path as xs:string){
    let $c := connect()
    return (client:execute($c, "OPEN "|| $dbname),
            client:execute($c, "EXPORT "|| $path),
           "Database exported")  
};

(:~ 
:connect
: @return connection handle
:)
declare function connect(){
   client:connect('localhost', 1984, 'admin', 'admin')
};
