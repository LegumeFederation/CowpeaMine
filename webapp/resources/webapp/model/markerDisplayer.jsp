<!-- markerDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.util.Map,java.net.URLEncoder" %>
<html:xhtml />
<tiles:importAttribute />
<style>
 body { font-family:sans-serif;  font-size:12px; }
 table.dataTable thead th, table.dataTable thead td {
     padding:2px; vertical-align:bottom; background-color:gray; color:white; font-size:8px; width:30px; border-right:1px solid #ddd; border-bottom:1px solid #ddd; border-top:0;
 }
 table.dataTable tfoot th, table.dataTable tfoot td {
     padding:2px; vertical-align:bottom; background-color:gray; color:white; font-size:8px; width:30px; border-right:1px solid #ddd; border-bottom:0; border-top:0;
 }
 table.dataTable tbody td {
     padding:2px; font-size:8px; color:white; background-color: gray;
 }
 table.dataTable tbody tr:hover {background-color:gray !important; color:white !important; }
 .highlight { background-color:gray !important; color:white !important; }
 .b { font-weight: bold; }
 .markers a { background-color:gray; color:white; font-size:8px; text-decoration:none; }
</style>
<%
// url to link mapping population report
String mappingPopulationURL = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getServletContext().getContextPath()+"/portal.do?class=MappingPopulation&externalids=";

// the mappingPopulations containing this marker, along with lines and values in their own map
Map<String,Map<String,String>> mappingPopulationMap = (Map<String,Map<String,String>>) request.getAttribute("mappingPopulationMap");

for (String mappingPopulationName : mappingPopulationMap.keySet()) {
    Map<String,String> valuesMap = mappingPopulationMap.get(mappingPopulationName);
    String tableID = mappingPopulationName.replaceAll(" ","");
%>
<div style="padding:5px; border:1px solid gray; margin-bottom:2px;">
    <div style="margin:2px 0;">
        <a href="<%=mappingPopulationURL+URLEncoder.encode(mappingPopulationName,"UTF-8")%>"><%=mappingPopulationName%></a>
    </div>

    <table id="<%=tableID%>" class="cell-border" cellspacing="0" width="100%">
        <thead>
            <tr>
                <% for (String line : valuesMap.keySet()) { %>
                    <th><%=line.replace('-',' ')%></th>
                <% } %>
            </tr>
        </thead>
        <tbody>
            <tr>
                <% for (String value : valuesMap.values()) { %>
                    <td><%=value%></td>
                <% } %>
            </tr>
        </tbody>
    </table>
    <!-- this should be stored in MappingPopulation somewhere -->
    <p>
        <span style="color:darkred">A = Parent A</span>, <span style="color:darkgreen">B = Parent B</span>, Lower case: genotype calls reversed based on parental alleles.
    </p>
</div>

<script type="text/javascript"> 
 $(document).ready(function() {
     var table = $('#<%=tableID%>').DataTable({
         "scrollX": true,
         "autoWidth": false,
         "info": false,
         "paging": false,
         "searching": false,
         "columnDefs": [ {
             "targets": '_all',
             "className": 'dt-center b',
             "orderable": false,
             "createdCell": function (td, cellData, rowData, row, col) {
                 if (cellData=='A' || cellData=='a') {
                     $(td).css('background-color', 'darkred')
                 } else if (cellData=='B' || cellData=='b') {
                     $(td).css('background-color', 'darkgreen')
                 }
             }
         }]
     });     
 }); 
</script> 
    
<%
} // loop over mapping populations
%>
<!-- /markerDisplayer.jsp -->
