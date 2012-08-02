(:~ 
: auth for xquery documentation web application 
: @author andy bunce
: @since jul 2012
:)

module namespace auth = 'apb.restlib.auth';
declare default function namespace 'apb.restlib.auth'; 

import module namespace web = 'apb.web.utils' at "restlib/web2.xqm";
import module namespace users = 'apb.users.app' at "restlib/users.xqm";
import module namespace request = "http://exquery.org/ns/restxq/Request";
declare namespace rest = 'http://exquery.org/ns/restxq';
declare option db:chop "no";
declare variable $auth:layout:=fn:resolve-uri("xqwebdoc/views/layout.xml");
declare variable $auth:userdb:=db:open('xqwebdoc',"users.xml");


declare 
%rest:path("xqwebdoc/auth/login") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function login($req) {
  let $s:="login not working!"
  return render(map{"sidebar":=$s},"restlib/views/login.xml")
};

declare 
%rest:path("xqwebdoc/auth/login") 
%rest:POST 
%output:method("html5")
%restxq:request("{$req}")
%rest:form-param("username", "{$username}")
%rest:form-param("password", "{$password}")
%rest:form-param("rememberme", "{$rememberme}")
function login-post($req,$username,$password,$rememberme)
{
 let $u:=users:check-password($auth:userdb,$username,$password)
 return 
     if($u)
     then
        let $msg:=web:flash-msg("success","Logged in as "|| $username)
        return (request:set-attribute($req,"flash",fn:serialize($msg)),
                request:set-attribute($req,"uid", $u/@id/fn:string()),
                web:redirect("../.")
                )
     else
        let $msg:=web:flash-msg("error","Logged failed")
        return (request:set-attribute($req,"flash",fn:serialize($msg)),
                web:redirect("../.")
                )
 
};

declare 
%rest:path("xqwebdoc/auth/register") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function register($req)
{
    let $s:="register not working!"   
    return render(map{"sidebar":=$s},"restlib/views/register.xml")
};

declare 
%rest:path("xqwebdoc/auth/register") 
%rest:POST 
%output:method("html5")
%restxq:request("{$req}")
%rest:form-param("username", "{$username}")
%rest:form-param("password", "{$password}")
updating function register-post($req,$username,$password)
{
    if(users:find-name($auth:userdb,$username))
    then 
        let $t:= "User exists!"
        let $s:="POST register not working!"
        return db:output(render(map{"content":= $t,"sidebar":=$s}))
    else
        let $msg:=web:flash-msg("info","Created")
        return (
            users:create($auth:userdb,$username,$password),
          (:  request:set-attribute($req,"flash",fn:serialize($msg)), :)
            db:output(web:redirect("../../"))
    )
};

declare 
%rest:path("xqwebdoc/auth/logout") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function logout($req) {
    web:logout("../") 
   
};

declare 
%rest:path("xqwebdoc/auth/profile") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function profile($req) {
  let $s:="profile not working!"
 return render(map{"sidebar":=$s},"restlib/views/profile.xml")
};

declare 
%rest:path("xqwebdoc/auth/profile") 
%rest:POST 
%output:method("html5")
%restxq:request("{$req}")
function profile-post($req) {
  let $t:= "post profile"
  let $s:="profile not working!"
 return render(map{"content":= $t,"sidebar":=$s})
};

declare function render($map) {    
     web:render(mapfix($map),$auth:layout)
};

declare function render($map,$file as xs:string) {    
     web:render(mapfix($map),$auth:layout,fn:resolve-uri($file))
};

declare function mapfix($map) {    
     if(map:contains($map,"sidebar"))
     then $map
     else map:new(($map,map{"sidebar":="Authorization..."}))
};