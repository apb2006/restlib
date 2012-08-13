(:~ 
: user /auth  application 
: @author andy bunce
: @since jun 2012
:)

module namespace users = 'apb.users.app';
declare default function namespace 'apb.users.app';

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
    $userDb/users/user[@name=$username and login/@password=hash:md5($password) ]
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
     let $d:=<user id="{next-id($userDb)}" name="{$name}">
               <stats created="{fn:current-dateTime()}" last="{fn:current-dateTime()}" logins="1" />
               <login password="{hash:md5($password)}" role="user" />
               <data>
                 <ace theme="dawn" /> 
               </data>        
        </user>
    return  (insert node $d into $userDb/users ,incr-id($userDb) )
};

(:~
: update login stats
:)
declare updating function update-stats($userDb,$uid as xs:string)                           
{    
    let $d:= $userDb/users/user[@id=$uid]
    return  (replace value of node $d/stats/@last with fn:current-dateTime(),
             replace value of node $d/stats/@logins with 1+$d/stats/@logins)
};