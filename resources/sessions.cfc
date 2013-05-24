<cfcomponent>
  <cffunction name="signin" access="remote" returntype="any" returnformat="json">
    <cfargument name="data" required="true" type="any">
    <cfset attr = StructNew()>
    <cfset attr.next_ws = "next_ws.">
    <cftry>
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="doLogin" returnvariable="user_info" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getMenuPrincipal" returnvariable="main_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="ventas_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="1">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="compras_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="2">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="embarques_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="8">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="inventario_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="9">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="servicios_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="10">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="cxc_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="4">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="cxp_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="6">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="bancos_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="7">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="merlin_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="16">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="contabilidad_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="471">
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="instalaciones_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="893">
      <!--- <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="multinivel_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="592"> --->
      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="multinivel_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="579">

      <cfinvoke component="#attr.next_ws#nx_utilerias" method="getSubMenu" returnvariable="reportes_menu" user="#data.username#" passw="#data.password#" dns="#data.ds#" emp_id="#data.company_id#" top="15"> 
      <cfcatch type="any">
        <cfheader statuscode="500" statustext="Internal Server Error">
        <cfreturn #cfcatch.message# & "<br/>" & #cfcatch.detail#>
      </cfcatch>
    </cftry>
    <cfscript>
      res = ArrayNew(1);
      response = structNew();
      if(main_menu.ventas EQ 1)
        arrayAppend(res, menu_item("Ventas", ventas_menu, 0));
      if(main_menu.compras EQ 1)
        arrayAppend(res, menu_item("Compras", compras_menu, 0));
      if(main_menu.cxc EQ 1 OR main_menu.cxp EQ 1 OR main_menu.bancos EQ 1) {
        finanzas_menu = ArrayNew(1);
        if(main_menu.cxc EQ 1)
          arrayAppend(finanzas_menu, menu_item("Cuentas por cobrar", cxc_menu, 1));
        if(main_menu.cxp EQ 1)
          arrayAppend(finanzas_menu, menu_item("Cuentas por pagar", cxp_menu, 1));
        if(main_menu.bancos EQ 1)
          arrayAppend(finanzas_menu, menu_item("Bancos", bancos_menu, 1));
        arrayAppend(res, menu_item("Finanzas", finanzas_menu, 0));
      }
      if(main_menu.contabilidad EQ 1)
        arrayAppend(res, menu_item("Contabilidad", contabilidad_menu, 0));
      if(main_menu.inventario EQ 1)
        arrayAppend(res, menu_item("Inventario", inventario_menu, 0));
      if(main_menu.embarques EQ 1)
        arrayAppend(res, menu_item("Embarques", embarques_menu, 0));
      if(main_menu.instalaciones EQ 1)
        arrayAppend(res, menu_item("Instalaciones", instalaciones_menu, 0));
      if(main_menu.reportes EQ 1)
        arrayAppend(res, menu_item("Reportes", reportes_menu, 0));
      if(main_menu.servicios EQ 1)
        arrayAppend(res, menu_item("Servicios", servicios_menu, 0));
      if(main_menu.multinivel EQ 1) {
        if (isDefined('multinivel_menu')) {
          arrayAppend(res, menu_item("Multinivel", multinivel_menu, 0));
        }
      }
      if(main_menu.merlin EQ 1)
        arrayAppend(res, menu_item("Merlin", merlin_menu, 0));
    </cfscript>
    <cfset structInsert(user_info, "menu", #res#)>
    <cfset structInsert(user_info, "username", data.username)>
    <cfset structInsert(user_info, "ds", data.ds)>
    <cfset response = user_info>
    <cfset json=serializeJSON(response)>
    <cfreturn response>
  </cffunction>
  <!---menu_item--->
  <cffunction name="menu_item" access="remote" returntype="any" output="true" returnformat="json">
    <cfargument name="name" required="true" type="string">
    <cfargument name="items" required="true" type="any">
    <cfargument name="submenu_flag" required="true" type="string">
    <cfset item = structNew()>
    <cfif submenu_flag>
      <cfset structInsert(item, "obj_descrip", name)>
      <cfset structInsert(item, "obj_subs", items)>
      <cfreturn item>
      <cfelse>
        <cfset structInsert(item, "icon", lCase(name))>
        <cfset structInsert(item, "name", name)>
        <cfset structInsert(item, "items", items)>
        <cfreturn item>
    </cfif>
  </cffunction>
</cfcomponent>