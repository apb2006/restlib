(:~ 
: auth for xquery documentation web application 
: @author andy bunce
: @since jul 2012
:)

module namespace auth = 'apb.restlib.auth';
declare default function namespace 'apb.restlib.auth'; 

import module namespace web = 'apb.web.utils' at "restlib/web2.xqm";
import module namespace users = 'apb.users.app' at "restlib/users.xqm";
import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";
declare namespace rest = 'http://exquery.org/ns/restxq';
declare option db:chop "no";
declare variable $auth:layout:=fn:resolve-uri("xqwebdoc/views/layout.xml");
declare variable $auth:userdb:=db:open('xqwebdoc',"users.xml");


declare 
%rest:GET %rest:path("{$app}/auth/login") 
%output:method("html5")
function login($app) {
  let $s:="You will need to register before you can log in!"
  let $map:=web:flash-swap(map{"app":=$app,"sidebar":=$s})
  return render($map,"restlib/views/login.xml")
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
        let $msg:=web:flash-msg("success","Logged in as "|| $username)
        return (
		   users:update-stats($auth:userdb,$u/@id), 
			db:output((
                session:set("uid", $u/@id/fn:string()),
                web:redirect("../.",$msg)
                ))
				)
     else
        let $msg:=web:flash-msg("error","Logged failed, check username and passsword.")
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
    return render($map,"restlib/views/register.xml")
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
        let $t:= $username || " is aready registered!"
        let $s:="Choose a different name!"
        return db:output(render(map{"content":= $t,"sidebar":=$s}))
    else
        let $msg:=web:flash-msg("success",$username || " your registration was successful. " 
                            || "Please login now! ")
        return (
            users:create($auth:userdb,$username,$password),
           (: request:attribute("flash",fn:serialize($msg)), :)
            db:output(
            web:redirect("../.",$msg) 
            )
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
  let $s:="changepassword not working!"
  let $map:=web:flash-swap(map{"sidebar":=$s})   
  return render($map,"restlib/views/changepassword.xml")
};

declare 
%rest:POST %rest:path("{$app}/auth/changepassword") 
%output:method("html5")
function changepassword-post($app) {
  let $t:= "post changepassword"
  let $s:="changepassword not working!"
 return render(map{"content":= $t,"sidebar":=$s})
};

declare 
%rest:GET %rest:path("{$app}/auth/lostpassword") 
%output:method("html5")
function lostpassword($app) {
  let $s:="lost password not working!"
  let $map:=web:flash-swap(map{"sidebar":=$s})   
  return render($map,"restlib/views/lostpassword.xml")
};

declare function render($map) {    
     web:render(mapfix($map),$auth:layout)
};

declare function render($map,$file as xs:string) {    
     web:render(mapfix($map),$auth:layout,fn:resolve-uri($file))
};

declare function mapfix($map) {
 let $default:=map{"sidebar":="Sidebar...",
                   "usermenu":=(),
                   "title":=request:path()}   
  return map:new(($default,$map))  
};