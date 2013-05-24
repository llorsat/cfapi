<!---
== basic handler for api resources ==

global variables:

* ws
* route
* datasource
* company
* username
* token
* resource
* id
* REQ - data into request
--->
<cfcomponent>

    <cfset verb = cgi.request_method>
    <cfset uri = cgi.PATH_INFO>
    <cfset uriComponents = uri.split('/')>

    <cfset ws = 'next_ws'>
    <cfset route = 'nextapi'>
    <cfset password = ''>
    
    <cfif arrayLen(uriComponents) GT 2>
        <cfset datasource = uriComponents[2]>
        <cfset company = uriComponents[3]>
        <cfset username = uriComponents[4]>
        <cfset token = uriComponents[5]>
        <cfset resource = uriComponents[6]>
        <cfif arrayLen(uriComponents) GTE 7>
            <cfset id = uriComponents[7]>
        </cfif>
    </cfif>

    <!--- TODO: Borrar cuando ninguna aplicacion utilice attr variables --->
    <cfset attr = StructNew()>
    <cfset attr.next_ws = "#ws#.">
    <cfset attr.route = "#route#.">
    <cfset attr.password = password>
    <cfif arrayLen(uriComponents) GT 1>
        <cfset attr.ds = datasource>
        <cfset attr.company_id = company>
        <cfset attr.username = username>
        <cfset attr.token = token>
        <cfset attr.resource = resource>
        <cfif arrayLen(uriComponents) GTE 7>
            <cfset attr.id = id>
        </cfif>
    </cfif>
    <!--- / --->

    <cfif verb EQ "GET" or verb EQ "DELETE">
        <cfset REQ = URL>
    </cfif>
    <cfif verb EQ "POST">
        <cfif isDefined("MODEL")>
            <cfset REQ = deserializeJSON(MODEL)>
        <cfelse>
            <cfset MODEL = FORM>
            <cfset REQ = MODEL>
        </cfif>
    </cfif>
    <cfif verb EQ "PUT">
        <cfset MODEL = deserializeJSON(removeChars(urlDecode(getHTTPRequestData().content), 1, 6))>
        <cfset REQ = MODEL>
    </cfif>

    <cfset REQ.user = username>
    <cfset REQ.passw = password>
    <cfset REQ.dns = datasource>
    <cfset REQ.emp_id = company>

    <cffunction name="mapArray" output="false">
        <cfargument name="oldarray" type="array" required="true">
        <cfargument name="map" type="struct" required="true">
        <cfset newArray = arrayNew(1)>
        <cfloop array="#oldarray#" index="row">
            <cfset a = arrayAppend(newArray, this.mapStruct(row, map))>
        </cfloop>
        <cfreturn newArray>
    </cffunction>

    <cffunction name="mapStruct" output="false">
        <cfargument name="oldStruct" type="struct" required="true">
        <cfargument name="map" type="struct" required="true">
        <cfset newStruct = structNew()>
        <cfloop collection="#map#" item="oldName">
            <cfif structKeyExists(oldStruct, oldName) >
                <cfset a = structInsert(newStruct, map[oldName], oldStruct[oldName])>
            </cfif>
        </cfloop>
        <cfreturn newStruct>
    </cffunction>

    <cffunction name="queryToStruct" access="public" returntype="any" output="false">
        <cfargument name="Query" type="query" required="true" />
        <cfargument name="Row" type="numeric" required="false" default="0" />

        <cfscript>

            var LOCAL = StructNew();
            if (ARGUMENTS.Row){
                LOCAL.FromIndex = ARGUMENTS.Row;
                LOCAL.ToIndex = ARGUMENTS.Row;
            } else {
                LOCAL.FromIndex = 1;
                LOCAL.ToIndex = ARGUMENTS.Query.RecordCount;
            }
            LOCAL.Columns = ListToArray( ARGUMENTS.Query.ColumnList );
            LOCAL.ColumnCount = ArrayLen( LOCAL.Columns );
            LOCAL.DataArray = ArrayNew( 1 );

            for (LOCAL.RowIndex = LOCAL.FromIndex ; LOCAL.RowIndex LTE LOCAL.ToIndex ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
                ArrayAppend( LOCAL.DataArray, StructNew() );
                LOCAL.DataArrayIndex = ArrayLen( LOCAL.DataArray );

                for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE LOCAL.ColumnCount ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
                    LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
                    LOCAL.DataArray[ LOCAL.DataArrayIndex ][ LOCAL.ColumnName ] = ARGUMENTS.Query[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
                }
            }

            if (ARGUMENTS.Row){
                return( LOCAL.DataArray[ 1 ] );
            } else {
                return( LOCAL.DataArray );
            }

        </cfscript>
    </cffunction>

    <cffunction name="cleanStruct" output="false">
        <cfargument name="struct" type="struct" required="true">
        <cfset newStruct = structNew()>
        <cfloop collection="#struct#" item="index">
            <cfset value = this.cleanValue(struct[index])>
            <cfset a = structInsert(newStruct, "#index#", value)>
        </cfloop>
        <cfreturn newStruct>
    </cffunction>

    <cffunction name="cleanArray" output="false">
        <cfargument name="array" >
        <cfset newArray = arrayNew(1)>
        <cfloop array="#array#" index="value">
            <cfset a = arrayAppend(newArray, this.cleanValue(value))>
        </cfloop>
        <cfreturn newArray>
    </cffunction>

    <cffunction name="cleanValue">
        <cfargument name="value">
        <cfif isStruct(value)>
            <cfreturn this.cleanStruct(value)>  
        <cfelseif isArray(value) >
            <cfreturn this.cleanArray(value)>
        <cfelseif isBinary(value) or isBoolean(value) or isObject(value) or isQuery(value) or isXmlDoc(value)>
            <cfreturn value>
        <cfelse>
            <cfreturn TRIM(RTRIM(LTRIM(value)))>
        </cfif>
    </cffunction>

    <cfscript>
        function converToDate(stringDate){
          parts = listToArray(stringDate, " /:");
          day = parts[1];
          month = parts[2];
          year = parts[3];

          hour = 0;
          if( arrayLen(parts) > 3 ){
            hour = parts[4];
          }

          minute = 0;
          if( arrayLen(parts) > 3 ){
            minute = parts[5];
          }

          second = 0;
          if( arrayLen(parts) > 3 ){
            second = parts[6];
          }
          return createDateTime(year, month, day, hour, minute, second);
        }
    </cfscript>
    

</cfcomponent>