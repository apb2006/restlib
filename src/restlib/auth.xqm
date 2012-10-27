(:~ 
: auth for xquery documentation web application 
: @author andy bunce
: @since jul 2012
:)

module namespace auth = 'apb.restlib.auth';
declare default function namespace 'apb.restlib.auth'; 

import module namespace web = 'apb.web.utils' at "web2.xqm";
import module namespace config="apb.config" at "lib/config.xqm";
import module namespace users = 'apb.users.app' at "users.xqm";

import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";
declare namespace rest = 'http://exquery.org/ns/restxq';
declare option db:chop "no";
declare variable $auth:layout:=fn:resolve-uri("views/layout.xml");
declare variable $auth:userdb:=db:open('xqwebdoc',"users.xml");


declare 
%rest:GET %rest:path("{$app}/auth/login") 
%output:method("html5")
function login($app) {
  let $s:=<div>You must have <a href="auth/register">registered</a>
          before you can log in.</div>
  let $map:=web:flash-swap(map{"app":=$app,"sidebar":=$s})
  return render($app,$map,"views/login.xml")
};

declare 
%rest:POST %rest:path("{$app}/auth/login") 
%output:method("html5")
%rest:form-param("username", "{$username}")
%rest:form-param("password", "{$password}")
%rest:form-param("rememberme", "{$rememberme}")
updating function login-post($app,$username,$password,$rememberme)
{
 let $u:=users:check-password($auth:userdb,$username,$password)
 return 
     if($u)
     then
        let $msg:=web:flash-msg("success","Welcome back "|| $username)
        return (
		   users:update-stats($auth:userdb,$u/@id), 
			db:output((
                session:set("uid", $u/@id/fn:string()),
                web:redirect("../.",$msg)
                ))
				)
     else
        let $msg:=web:flash-msg("error","Login failed,please check username and passsword.")
        return db:output(
                web:redirect("./login",$msg)
				)
 
};

declare 
%rest:GET %rest:path("{$app}/auth/register") 
%output:method("html5")
function register($app)
{
    let $s:="This is where you register."
     let $map:=web:flash-swap(map{"app":=$app,"sidebar":=$s})   
    return render($app,$map,"views/register.xml")
};

declare 
%rest:POST %rest:path("{$app}/auth/register") 
%output:method("html5")
%rest:form-param("username", "{$username}")
%rest:form-param("password", "{$password}")
updating function register-post($app,$username,$password)
{
    if(users:find-name($auth:userdb,$username))
    then 
        let $t:= "The name '" || $username || "' is already registered, please choose different name."
        let $msg:=web:flash-msg("error",$t)
        return db:output(
                          web:redirect("./register" ,$msg) 
                         )
    else
        let $msg:=web:flash-msg("success",$username || " your registration was successful. " 
                            || "Please login now! ")
        return (
            users:create($auth:userdb,$username,$password),
            
           (: request:attribute("flash",fn:serialize($msg)), :)
            db:output((
            session:set("uid", fn:string(users:next-id($auth:userdb))),
            web:redirect("../.",$msg) 
            ))
    )
};

declare 
%rest:POST %rest:path("{$app}/auth/logout") 
%output:method("html5")
function logout($app) {
 let $msg:=web:flash-msg("success","You are now Logged out.")
 return  (
          session:set("uid",""),
          web:redirect("../.",$msg)
         )   
};

declare 
%rest:GET %rest:path("{$app}/auth/changepassword")

%output:method("html5")
function changepassword($app) {
  let $map:=web:flash-swap(map{ "sidebar":="Change your password here."})   
  return render($app,$map,"views/changepassword.xml")
};

declare 
%rest:POST %rest:path("{$app}/auth/changepassword")
%rest:form-param("oldpassword", "{$oldpass}")
%rest:form-param("newpassword", "{$newpass}")  
%output:method("html5")
updating function changepassword-post($app,$oldpass,$newpass) {
  try{
     let $user:=web:session-username($auth:userdb)
     let $msg:=web:flash-msg("success","Password changed")
     return (users:new-password($auth:userdb,$user,$oldpass,$newpass),
        db:output( web:redirect("../" ,$msg)) 
              )    
  }catch *{
     let $msg:=web:flash-msg("error","Failed to change password.")
     return db:output(web:redirect("../" ,$msg))                            
  } 
};

declare 
%rest:GET %rest:path("{$app}/auth/lostpassword") 
%output:method("html5")
function lostpassword($app) {
  let $s:="lost password not working!"
  let $map:=web:flash-swap(map{"sidebar":=$s})   
  return render($app,$map,"views/lostpassword.xml")
};

(:~
: layout for current app
:)
declare function layout($app as xs:string) {    
    fn:resolve-uri( "../" || $app || "/views/layout.xml")
};

declare function render($app,$map) {    
     web:render(mapfix($map),layout($app))
};

declare function render($app,$map,$file as xs:string) {    
     web:render(mapfix($map),layout($app),fn:resolve-uri($file))
};

declare function mapfix($map) {
 let $default:=map{"sidebar":="Sidebar...",
                   "usermenu":=(),
                   "title":=request:path(),
                    "libserver":=$config:libserver}   
  return map:new(($default,$map))  
};