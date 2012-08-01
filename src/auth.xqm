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
declare variable $auth:layout:="xqwebdoc/views/layout.xml";
declare variable $auth:userdb:=db:open('xqwebdoc',"users.xml");


declare 
%rest:path("xqwebdoc/auth/login") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function login($req) {
 let $t:= doc("restlib/views/login.xml")
  let $s:="login not working!"
 return layout(map{"content":= $t,"sidebar":=$s})
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
        let $msg:=web:flash-msg("success","logged in as "|| $username)
        return (request:set-attribute($req,"flash",fn:serialize($msg)),
                web:redirect("../.")
                )
     else
        let $msg:=web:flash-msg("error","logged failed")
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
    let $t:= doc("restlib/views/register.xml")
    let $s:="register not working!"
    
    return layout(map{"content":= $t,"sidebar":=$s})
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
        return db:output(layout(map{"content":= $t,"sidebar":=$s}))
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
  let $t:= doc("restlib/views/profile.xml")
  let $s:="profile not working!"
 return layout(map{"content":= $t,"sidebar":=$s})
};

declare 
%rest:path("xqwebdoc/auth/profile") 
%rest:POST 
%output:method("html5")
%restxq:request("{$req}")
function profile-post($req) {
  let $t:= "post profile"
  let $s:="profile not working!"
 return layout(map{"content":= $t,"sidebar":=$s})
};

declare function layout($map) {    
     web:layout2(doc($auth:layout), $map)    
};

declare function doc($url){
 let $u:=fn:resolve-uri($url)
 return fn:doc($u)
};