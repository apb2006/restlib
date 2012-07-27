(:~ 
:  cookie utilities
: based on zorba http://www.28msec.com/html/doc/2.0/modules/28msec/http/cookie
: <cookie:cookie name="xs:string" 
:               expires="xs:datetime" 
:              domain="xs:string" 
:              path="xs:string" 
:              secure="xs:boolean">value</cookie:cookie>
: @author andy bunce
: @since apr 2012
:)

module namespace cookie = 'apb.web.cookie';
declare default function namespace 'apb.web.cookie'; 

declare namespace rest = 'http://exquery.org/ns/restxq';
declare namespace xf = 'http://www.w3.org/2002/xforms';
declare namespace xhtml = 'http://www.w3.org/1999/xhtml';
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:~
: Creates a client-side cookie named "_session", containing the $sessionData node value together with its signature.
:)
declare function create-session($sessionData as node()) as empty-sequence()
{"not yet"};

declare function create-session($sessionData as node(), $expires as xs:dateTime) as empty-sequence()
{"not yet"};
declare function create-session($sessionData as node(), $expires as xs:dateTime?, $path as xs:string?) as empty-sequence()
{"not yet"};

(:~
: Delete the "_session" cookie from the client.
:)
declare function delete-session()
{"not yet"};

declare function delete-session($path as xs:string?)
{"not yet"};


(:~
: Returns the cookie in the request having the given name or the empty sequence if no such cookie exists.
:)
declare function get($name as xs:string?) as element(cookie:cookie)*
{"not yet"};

(:
: Returns the cookies in the request having the given name.
:)
declare function get($name as xs:string?, $decode as xs:boolean) as element(cookie:cookie)*
{"not yet"};

(:
: Reads the "_session" cookie in the request and verifies if the signature matches the ad-hoc computed signature of the content of the session.
:)
declare function session-data() as node()
{"not yet"};

(:~
:Adds a Set-Cookie header to the response.
:)
declare function set($cookie as element(cookie:cookie)) as empty-sequence()
{"not yet"};

declare function set($cookie as element(cookie:cookie), $encode as xs:boolean) as empty-sequence()
{"not yet"};

(:~
: Reads the "_session" cookie in the request and verifies if the signature matches the ad-hoc computed signature of the content of the session.
:)
declare function validate-session() as xs:boolean
{"not yet"};

 
