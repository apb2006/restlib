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
  let $s:="login here!"
  let $map:=web:flash-swap($req,map{"sidebar":=$s})
  return render($req,$map,"restlib/views/login.xml")
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
        let $msg:=web:flash-msg("error","Logged failed, check username and passsword.")
        return (request:set-attribute($req,"flash",fn:serialize($msg)),
                web:redirect("./login")
                )
 
};

declare 
%rest:path("xqwebdoc/auth/register") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function register($req)
{
    let $s:="register here!"
     let $map:=web:flash-swap($req,map{"sidebar":=$s})   
    return render($req,$map,"restlib/views/register.xml")
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
        let $t:= $username || " is aready registered!"
        let $s:="Choose a different name!"
        return db:output(render($req,map{"content":= $t,"sidebar":=$s}))
    else
        let $msg:=web:flash-msg("success",$username || "your registration was successful. " 
                            || "Please login now! ")
        return (
            users:create($auth:userdb,$username,$password),
           (: request:set-attribute($req,"flash",fn:serialize($msg)), :)
            db:output(
            (request:set-attribute($req,"flash",fn:serialize($msg)),
            web:redirect("../."))
            )
    )
};

declare 
%rest:path("xqwebdoc/auth/logout") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function logout($req) {
 let $msg:=web:flash-msg("success","You are now Logged out.")
 return  (request:set-attribute($req,"flash",fn:serialize($msg)),
          request:set-attribute($req,"uid","-"),
          web:redirect("../.")
         )   
};

declare 
%rest:path("xqwebdoc/auth/changepassword") 
%rest:GET 
%output:method("html5")
%restxq:request("{$req}")
function changepassword($req) {
  let $s:="changepassword not working!"
  let $map:=web:flash-swap($req,map{"sidebar":=$s})   
  return render($req,$map,"restlib/views/changepassword.xml")
};

declare 
%rest:path("xqwebdoc/auth/changepassword") 
%rest:POST 
%output:method("html5")
%restxq:request("{$req}")
function changepassword-post($req) {
  let $t:= "post changepassword"
  let $s:="changepassword not working!"
 return render($req,map{"content":= $t,"sidebar":=$s})
};

declare function render($req,$map) {    
     web:render(mapfix($req,$map),$auth:layout)
};

declare function render($req,$map,$file as xs:string) {    
     web:render(mapfix($req,$map),$auth:layout,fn:resolve-uri($file))
};

declare function mapfix($req,$map) {
 let $default:=map{"sidebar":="Sidebar...",
                   "usermenu":=(),
                   "title":=request:path($req)}   
  return map:new(($default,$map))  
};