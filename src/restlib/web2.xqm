(:~ 
:  web application utilities
: privides templates, users, http utils 
: @author andy bunce
: @since apr 2012
:)

module namespace web = 'apb.web.utils';
declare default function namespace 'apb.web.utils'; 
import module namespace request = "http://exquery.org/ns/request";
import module namespace session = "http://basex.org/modules/session";
import module namespace users = "apb.users.app" at "users.xqm";
declare namespace rest = 'http://exquery.org/ns/restxq';
declare namespace xf = 'http://www.w3.org/2002/xforms';
declare namespace xhtml = 'http://www.w3.org/1999/xhtml';
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

 

(:~
: xsltforms processing-instructions
:)
declare variable $web:forms-pi:=(
     processing-instruction{"xml-stylesheet"} {'href="/lib/xsltforms/xsltforms.xsl" type="text/xsl"'},
     processing-instruction{"css-conversion"} {'no'},
     processing-instruction{"xsltforms-options"} {'debug="no"'}
);

(:~
: template function
: @return updated doc from map
:)
declare function render($map as map(*),$layout as xs:string,$file as xs:string) 
{
    let $content:=render($map,$file)
    let $map:=map:new(($map,map{"body":=$content}))
    return render($map,$layout)  
	
};

(:~
: template function
: @return updated doc from map
:)
declare function render($map as map(*),$layout as xs:string) 
{
    
   let $map:=map:new(($map,map{"partial":=partial(?,?,?,$map,$layout)}))
   return xquery:invoke($layout,$map)  

};

(:~
: partial template function: evaluate part for each value in sequence
: @return updated doc from map
:)
declare function partial($part as xs:string,$name,$seq,$map,$base) 
{
  for $s in $seq
  let $map:=map:new(($map,map{$name:=$s}))
  return render($map,fn:resolve-uri($part,$base))  
};

(:~
: swap flash entry between session and map
: @return updated map
:)
declare function flash-swap($map) {
    let $fnew:=map:get($map,"messages")
    let $old:=session-flash($fnew)    
    return map:new(($map,map{"messages":=$old})) 
};


(:~
: show an image as a 404
: Adam's 'restxq example has binary not raw
:)
declare function page404($image){
  <rest:response>
           <output:serialization-parameters>
                <output:method value="raw"/>
           </output:serialization-parameters>
           <http:response status="404" reason="not found">
           
              <http:header name="Content-Type" value="image/jpeg"/>
              
           </http:response>
       </rest:response>,
      file:read-binary($image)
};


declare function response($type){
(: http://john.snelson.org.uk/interesting-use-case-for-the-xquery-11-switch :)
    switch(fn:true())
    case "xml"=$type return response("xml","application/xml") 
    case "text"=$type return response("text","text/plain")
    case "html"=$type return response("html","text/html")
    default return  response("xml","application/xml")             
};

declare function response($method as xs:string,$mimetype as xs:string){
    <rest:response>
           <output:serialization-parameters>
                <output:method value="{$method}"/>
           </output:serialization-parameters>
            <http:response>
            <http:header name="Content-Type" value="{$mimetype}"/>              
           </http:response>
       </rest:response>
};

declare function download($filename as xs:string){
 <rest:response>
           <output:serialization-parameters>
                <output:method value="raw"/>
           </output:serialization-parameters>
            <http:response>
            <http:header name="Content-Disposition" value='attachment;filename="{$filename}"'/>              
           </http:response>
       </rest:response>
};

(:~
: redirect to ..
:)
declare function redirect($url as xs:string) 
 {
        <rest:response>         
           <http:response status="303" >
             <http:header name="Location" value="{$url}"/>
           </http:response>                      
       </rest:response>
};

(:~
: redirect with flash msg
:)
declare function redirect($url as xs:string,$msg) 
 {
 (session:set("flash",fn:serialize($msg)),
    <rest:response>         
       <http:response status="303" >
         <http:header name="Location" value="{$url}"/>
       </http:response>                      
   </rest:response>
   )
};
(:~
: logout, clear cookie and redirect to ..
:)
declare function logout($url as xs:string) 
 {
        <rest:response>         
           <http:response status="303" >
             <http:header name="Location" value="{$url}"/>
			 <http:header name="Set-Cookie" value="JSESSIONID=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT"/>
           </http:response>                      
       </rest:response>
};

(:~
 : return html representation of xml
 :)
declare function xml2html($in)
 {
     (: @TODO better way to get path :)
     let $xsl:=fn:resolve-uri("xmlverbatim.xsl")
     return 
         if(fn:empty($in))
         then ()
         else try{ 
                    xslt:transform($in, $xsl) 
              }
              catch * {
               <div>Error in xml2html: {$xsl}</div>
              }
 };
 
(:~
: return http representation of cookie
: based on zorba http://www.28msec.com/html/doc/2.0/modules/28msec/http/cookie
: <cookie name="xs:string" 
:              expires="xs:datetime"  o/p as  Thu, 2 Aug 2001 20:47:11 UTC
:              domain="xs:string"  
:              path="xs:string" 
:              secure="xs:boolean">value</cookie>
:)
declare function cookies($cookie as element(cookie)) as element(http:header)
 {
 let $x:=fn:concat($cookie/@name,"=",$cookie/fn:string(),";")
 let $d:=fn:current-dateTime()+xs:dayTimeDuration('PT3H')
 let $d:=fn:format-dateTime($d, "[FNn,*-3], [D01] [MNn,*-3] [Y] [H01]:[m01]:[s01] GMT")
 return  <http:header name="Set-Cookie" value="{$x}"/>            
 };
 
(:~
: return a flash msg
:)
declare function flash-msg($type as xs:string,$msg as xs:string) as element(div)
{
	<div class="alert alert-{$type}" >
            <a class="close" data-dismiss="alert">×</a>
            {$msg}
            </div>
            
};

(:~
: set a flash msg
:)
declare function flash-msg($type as xs:string,$msg as xs:string,$req)
{
  session-flash(flash-msg($type,$msg))           
};	   

(:~
: session value with default
:)
declare function session-get($name as xs:string,$default as xs:string){
	let $f:=session:get($name)
    return if(fn:empty($f))
        then $default
        else $f
};

(:~
: update session value using function
:)
declare function session-update($name as xs:string,$default as xs:string,$fn){
	let $f:=session-get($name,$default)
	let $n:=$fn($f)
	return ($f,session:set($name,$n))
};

(:~
: update session value flash value
: @return old
:)
declare function session-flash($fnew){
   let $fnew:=if(fn:empty($fnew))
               then <div/>
               else $fnew
    let $flast:=session-get("flash","<div/>")
    let $old:= try{
                 fn:parse-xml($flast)
               }catch * {
               <div>erro: {$flast}</div>
               }
    let $junk:=session:set("flash",fn:serialize($fnew))
    return $old
};

(:~ user name or guest
:)
declare function session-username($userdb) as xs:string{
    let $uid:=session:get("uid")
    return if($uid)
	       then users:find-id($userdb,$uid)/@name/fn:string()
           else "(guest)"
};

declare function session-has-role($userdb,$role) as xs:boolean{
    let $uid:=session:get("uid") 
    return if(fn:empty($uid))
           then fn:false()
           else users:find-id($userdb,$uid)/login/@role=$role
};

(:~
: friendly datetime catching missing 
:)
declare function format-dateTime($dt as xs:string){
    try{ 
        <time class="relative-date" datetime="{$dt}" title="{$dt}">
        {fn:format-dateTime(xs:dateTime($dt), "[H01]:[m01] on [FNn,*-3], [D01] [MNn,*-3] [Y]")}
        </time>
    }
    catch * {
        $dt
    }
};
