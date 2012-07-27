(:~ 
: auth for xquery documentation web application 
: @author andy bunce
: @since jun 2012
:)

module namespace auth = 'apb.restlib.auth';
declare default function namespace 'apb.restlib.auth'; 

import module namespace web = 'apb.web.utils' at "restlib/web2.xqm";
import module namespace users = 'apb.users.app' at "restlib/users.xqm";
import module namespace request = "http://exquery.org/ns/restxq/Request";
declare namespace rest = 'http://exquery.org/ns/restxq';

declare variable $auth:layout:="xqwebdoc/views/layout.xml";

declare 
%rest:path("auth/profile") 
%rest:GET 
%output:method("html5")
function profile() {
  let $t:= doc("restlib/views/profile.xml")
  let $s:="profile not working!"
 return web:layout2(doc($auth:layout),map{"content":= $t,"sidebar":=$s})
};

declare 
%rest:path("auth/profile") 
%rest:POST 
%output:method("html5")
function profile-post() {
  let $t:= "post profile"
  let $s:="profile not working!"
 return web:layout2(doc($auth:layout),map{"content":= $t,"sidebar":=$s})
};


declare 
%rest:path("auth/login") 
%rest:GET 
%output:method("html5")
function login() {
 let $t:= doc("restlib/views/login.xml")
  let $s:="login not working!"
 return web:layout2(doc($auth:layout),map{"content":= $t,"sidebar":=$s})
};

declare 
%rest:path("auth/login") 
%rest:POST 
%output:method("html5")
function login-post() {
  let $t:= "post login"
  let $s:="profile not working!"
 return web:layout2(doc($auth:layout),map{"content":= $t,"sidebar":=$s})
};

declare 
%rest:path("auth/register") 
%rest:GET 
%output:method("html5")
function register() {
    let $t:= doc("restlib/views/register.xml")
    let $s:="register not working!"
    return web:layout2(doc($auth:layout),map{"content":= $t,"sidebar":=$s})
};

declare 
%rest:path("auth/register") 
%rest:POST 
%output:method("html5")
function register-post() {
    let $t:= "POST register not working!"
    let $s:="POST register not working!"
    return web:layout2(doc($auth:layout),map{"content":= $t,"sidebar":=$s})
};

declare 
%rest:path("auth/logout") 
%rest:GET 
%output:method("html5")
function logout() {
    web:logout("./") 
   
};

declare function doc($url){
 let $u:=fn:resolve-uri($url)
 return fn:doc($u)
};
