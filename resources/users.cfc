<!---    
@resource users
@description user resource description 
@tags Usuarios,Nexth5
@module Finanzas
--->
<cfcomponent extends="resource">

  <!--- 
  @path /{id} 
  @method GET 
  @description get a user
  @tags nx_usuarios.datos_grales_usu,users 
  --->
  <cffunction name="get">
    <cfinvoke component="#attr.next_ws#nx_usuarios" method="datos_grales_usu" returnvariable="std" 
    user="#attr.username#" passw="#attr.password#" dns="#attr.ds#" emp_id="#attr.company_id#" 
    usuario="#id#">

    <cfset a = structInsert(std, "almacenes", this.queryToStruct(std.almacenes), true)>
    <cfset a = structInsert(std, "departamentos", this.queryToStruct(std.departamentos), true)>
    <cfset a = structInsert(std, "empresa", this.queryToStruct(std.empresa), true)>
    <cfset a = structInsert(std, "lenguaje", this.queryToStruct(std.lenguaje), true)>
    <cfset a = structInsert(std, "puestos", this.queryToStruct(std.puestos), true)>
    <cfset a = structInsert(std, "tipos", this.queryToStruct(std.tipos), true)>
    <cfset a = structInsert(std, "datos", this.queryToStruct(std.datos, 1), true)>
    <cfreturn deserializeJSON(serializeJSON(std))>
  </cffunction>
  
  <!--- 
  @path / 
  @method GET 
  @description get a list of users 
  @tags nx_usuarios.bsqUsuario,users 
  --->
  <cffunction name="get_all">
    <cfparam name="only_actives" default="0" type="numeric">
    <cfparam name="url.from" default="" type="string">
    <cfset response = StructNew()>
    <cfset users = ArrayNew(1)>

    <cfif only_actives EQ 1>
      <cfquery datasource="#dns#" name="usuarios">          
          SELECT usu_id as data, RTRIM(usu_nombre) + ' ' + RTRIM(usu_apellidos) AS label
          FROM usuarios_adm WITH (NOLOCK) WHERE usu_estado = 1
          ORDER BY label
      </cfquery>
      <cfset structInsert(response, "object_list", this.queryToStruct(usuarios))>
      <cfreturn response>
    </cfif>    

    <cfif url.from eq "catalogs">
      <cfinvoke component="#attr.next_ws#nx_catalogos" method="getUsuarios" 
        user="#attr.username#" passw="#attr.password#" dns="#attr.ds#" emp_id="#attr.company_id#" 
        returnvariable="users">
      <cfset users = this.queryToStruct(users)>
    <cfelse>
      <cfinvoke component="#attr.next_ws#nx_usuarios" method="bsqUsuario" returnvariable="users_query" 
        user="#attr.username#" passw="#attr.password#" dns="#attr.ds#" emp_id="#attr.company_id#" 
        usuID="#id#" razon_soc="#company_name#" departamento="#department#" puesto="#position#" 
        almacen="#stock#">
      
      <cfset startrow = (page*count)-(count-1)>
      <cfset endrow = (page*count)>
      <cfloop query="users_query" startrow="#startrow#" endrow="#endrow#">
        <cfinvoke method="get_user_struct" row="#users_query#" returnvariable="user_obj">
        <cfset arrayAppend(users, user_obj)>
      </cfloop>
      <cfscript>
        if(endrow LT users_query.RecordCount) {
          structInsert(response, "next_page", true);
        }
        else {
          structInsert(response, "next_page", false);
        }
        if(startrow GT 1) {
          structInsert(response, "previous_page", true);
        }
        else {
          structInsert(response, "previous_page", false);
        }
        num_pages = round(users_query.RecordCount / count);
        structInsert(response, "num_pages", num_pages);
      </cfscript>
    </cfif>

    <cfset structInsert(response, "object_list", users) />
    <cfreturn response>
  </cffunction>

  <!--- 
  @path / 
  @method POST
  @description create a user 
  @tags nx_usuarios.agregarUsu,users 
  @args from : string : [usuarios|articulos]
  @args actives : boolean
  --->
  <cffunction name="create">
    <cfargument name="data" required="true">
    <cfset model = deserializeJSON(data.model)>
    <cfinvoke component="#ws#.nx_usuarios" method="agregarUsu" returnvariable="userId" 
    user="#username#" passw="#token#" dns="#datasource#" emp_id="#company#" empresa="#company#"
    argumentcollection="#model#"
    >
    <cfset a = structInsert(model, "id", userId)>
    <cfreturn deserializeJSON(serializeJSON(model))>
  </cffunction>

  <!--- 
  @path /{id} 
  @method PUT
  @description update a user 
  @tags nx_usuarios.actualizar_usu,users 
  @args from : string : [usuarios|articulos] : descripcion con varias lineas
  @args actives : boolean : [true|false] : solo activos
  --->
  <cffunction name="update">
    <cfinvoke component="#ws#.nx_usuarios" method="actualizar_usu" returnvariable="userId" 
    user="#username#" passw="#token#" dns="#datasource#" emp_id="#company#" empresa="#company#"
    argumentcollection="#model#"
    >
    <cfreturn this.get()>
  </cffunction>

  <!--- Helpers --->
  <cfscript>
    function get_user_struct(row) {
      user_struct = structNew();
      structInsert(user_struct, "id", row.USU_ID, false);
      structInsert(user_struct, "name", row.USU_NOMBRE, false);
      structInsert(user_struct, "department", row.DEPARTAMENTO, false);
      structInsert(user_struct, "position", row.PUE_DESCRIP, false);
      structInsert(user_struct, "stock", row.ALM_DESCRIP, false);
      return user_struct;
    }
  </cfscript>

</cfcomponent>