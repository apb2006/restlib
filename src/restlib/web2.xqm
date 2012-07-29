(:~ 
:  web application utilities
: @author andy bunce
: @since apr 2012
:)

module namespace web = 'apb.web.utils';
declare default function namespace 'apb.web.utils'; 
import module namespace request = "http://exquery.org/ns/restxq/Request";
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
: update template from map @TODO
: @return updated doc with xsltforms processing instructions
:)
declare function render($file as xs:string,$map as map(*)) as xs:string
{
     let $t:= fn:doc("auth/views/profile.xml")
    let $s:="profile not working!"
    return web:layout2(fn:doc("layout.xml"),map{"content":= $t,"sidebar":=$s})
};

(:~
: update template from map
: @return updated doc with xsltforms processing instructions
:)
declare function layout($template,$map) {
    copy $page := $template
    modify (
       for $m in map:keys($map)
       let $v:=$map($m)
       return

       if("title"=$m)
       then   replace value of node  $page//*[@id="title"] with $v
       
       else if("model"=$m)
       then   insert node $v into $page//*[@id="head"] 
        
       else if("content"=$m)
       then   insert node $v into  $page//*[@id="content"]
       
	   else if("sidebar"=$m)
       then   insert node $v into  $page//*[@id="sidebar"]      	   
       else ()
        )
      return document { if(map:contains($map, "model"))
                        then $web:forms-pi
                        else ()
                       ,$page}     
};

(:~
: update template from map
: @return updated doc with xsltforms processing instructions
:)
declare function layout2($template,$map) {
    copy $page := $template
    modify (
       for $m in map:keys($map)
       let $v:=$map($m)
       return
       if(fn:starts-with($m,"="))
       then replace value of node  $page//*[@id=fn:substring($m,2)] with $v       
       else  insert node $v into  $page//*[@id=$m]          
        )
      return document { if(map:contains($map, "model"))
                        then $web:forms-pi
                        else ()
                       ,$page}     
};
(:~
: update template from map
: flash is put to session old is used
: @return updated doc with xsltforms processing instructions
:)
declare function layout3($template,$map,$req) {
    let $fnew:=map:get($map,"flash")
    let $fnew:=if(fn:empty($fnew))
               then <div/>
               else $fnew
    let $flast:=session-get($req,"flash","<div>EMPTY</div>")
    let $old:= try{
                 fn:parse-xml($flast)
               }catch * {
               <div>erro: {$flast}</div>
               }
    let $junk:=request:set-attribute($req,"flash",fn:serialize($fnew))

    let $map:=map:new(($map,map{"flash":=$old})) 
    
    return copy $page := $template
    modify (
       for $m in map:keys($map)
       let $v:=$map($m)
       return
       if(fn:starts-with($m,"="))
       then replace value of node  $page//*[@id=fn:substring($m,2)] with $v       
       else  insert node $v into  $page//*[@id=$m]          
        )
      return document { if(map:contains($map, "model"))
                        then $web:forms-pi
                        else ()
                       ,$page}     
};
(:~
: updating version of layout
:)
declare updating function output($template,$map) {
 db:output(layout($template,$map))
};

(:~
: show an image as a 404
: Adam's 'restxq examples has binary not raw
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

(:~
: redirect to ..
:)
declare function redirect($url as xs:string) 
 {
        <rest:response>         
           <http:response status="301" >
             <http:header name="Location" value="{$url}"/>
           </http:response>                      
       </rest:response>
};

(:~
: logout, clear cookie and redirect to ..
:)
declare function logout($url as xs:string) 
 {
        <rest:response>         
           <http:response status="301" >
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
     let $xsl:=fn:doc(fn:resolve-uri("restlib/xmlverbatim.xsl"))
     return 
         if(fn:empty($in))
         then ()
         else xslt:transform($in, $xsl)
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
: add a flash msg
:)
declare function flash($req,$type as xs:string,$msg as xs:string){
	let $f:=request:get-attribute($req,"flash")
	let $add:=<ul class="{$type}"><li>{$msg}</li></ul>
	let $new:=if(fn:empty($f))
			  then <div>{$add}</div>
			  else  <div>{fn:parse-xml($f)/*,$add}</div>

	return request:set-attribute($req,"flash",fn:serialize($new))
};

declare function flash2($req,$type as xs:string,$msg as xs:string){
	session-update($req,"flash","<div/>",
               function($v){
			   let $x:=fn:parse-xml($v)
			   let $target:=fn:head(($x/ul[@class=$type],$x))       
				let $insert:=if($target/self::ul)
						then <li>{$msg}</li>
						else  <ul class="{$type}"><li>{$msg}</li></ul>       
				let $r:=copy $r:=$x
						modify insert node $insert into $target
						return $r
				return 	fn:serialize($r)	
			   })
};			   

(:~
: session value with default
:)
declare function session-get($req,$name as xs:string,$default as xs:string){
	let $f:=request:get-attribute($req,$name)
    return if(fn:empty($f))
        then $default
        else $f
};

(:~
: update session value using function
:)
declare function session-update($req,$name as xs:string,$default as xs:string,$fn){
	let $f:=session-get($req,$name,$default)
	let $n:=$fn($f)
	return ($f,request:set-attribute($req,$name,$n))
};