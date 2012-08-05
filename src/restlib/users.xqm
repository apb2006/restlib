(:~ 
: user /auth  application 
: @author andy bunce
: @since jun 2012
:)

module namespace users = 'apb.users.app';
declare default function namespace 'apb.users.app';
import module namespace request = "http://exquery.org/ns/restxq/Request";

declare function find-name($userDb,$username as xs:string)
{
    $userDb/users/user[@name=$username]
};

declare function find-id($userDb,$id as xs:string?)
{
    $userDb/users/user[@id=$id]
};

(:~
:
:)
declare function check-password($userDb,
                                $username as xs:string,
                                $password as xs:string)
{
    $userDb/users/user[@name=$username and @password=hash:md5($password) ]
};

(:~
: next id
:)
declare function next-id($userDb) as xs:integer
{
    $userDb/users/@nextid
};

(:~
: increment the file id
:)
declare updating function incr-id($userDb)
{
     replace value of node $userDb/users/@nextid with next-id($userDb)+1
};

(:~
: create new user
:)
declare updating function create($userDb,
                              $name as xs:string,
                              $password as xs:string)
{    
     let $d:=<user id="{next-id($userDb)}" created="{fn:current-dateTime()}"
              name="{$name}" password="{hash:md5($password)}">
                <ace theme="dawn" />
     
        </user>
    return  (insert node $d into $userDb/users ,incr-id($userDb) )
};

