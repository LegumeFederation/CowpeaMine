<!-- genotypeDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.util.List, java.util.ArrayList" %>
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
 .ar { text-align: right; }
 .markers a { background-color:gray; color:white; font-size:8px; text-decoration:none; }
 div#tooltip {
     position: relative;
     left: 160px;
     top:  26px;
     text-align: left;
     width: 1000px;
     padding: 5px 0;
     color: #fff;
     background-color: #555;
     border-width: 5px;
     border-style: solid;
     border-color: #555 transparent transparent transparent;
     border-radius: 6px;
 }
</style>
<%
// the mapping population
String mappingPopulation = (String) request.getAttribute("mappingPopulation");

// the portal URL for links to genetic markers
String markerURL = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getServletContext().getContextPath()+"/portal.do?class=GeneticMarker&externalids=";

// the genotyping lines for this mapping population
List<String> lines = (List<String>) request.getAttribute("lines");
%>
<div id="tooltip">&nbsp;<br/>&nbsp;</div>

<table id="genotypes" class="cell-border" cellspacing="0" width="100%">
    <thead>
        <tr>
            <th>Marker</th>
            <th>LG</th>
            <th>Pos</th>
            <% for (String line : lines) { %><th><%=line.replace('-',' ')%></th><% } %>
            <th>Pos</th>
            <th>LG</th>
            <th>Marker</th>
        </tr>
    </thead>
    <tfoot>
        <tr>
            <th>Marker</th>
            <th>LG</th>
            <th>Pos</th>
            <% for (String line : lines) { %><th><%=line.replace('-',' ')%></th><% } %>
            <th>Pos</th>
            <th>LG</th>
            <th>Marker</th>
        </tr>
    </tfoot>
</table>

<!-- this should be stored in MappingPopulation somewhere -->
<p>
    <span style="color:darkred">A = Parent A</span>, <span style="color:darkgreen">B = Parent B</span>, Lower case: genotype calls reversed based on parental alleles.
</p>

<script type="text/javascript"> 
 $(document).ready(function() {
     
     var table = $('#genotypes').DataTable({
         "deferRender": true,
         "processing": true, 
         "serverSide": true,
         "scrollX": true,
         "autoWidth": false,
         "searching": false,
         "pageLength": 10,
         "order": [[1,'asc'],[2,'asc']],
         "columnDefs": [
             {
                 "name": "marker",
                 "targets": [0,-1],
                 "className": "markers b",
                 "orderable": true,
                 "createdCell": function (td, cellData, rowData, row, col) {
                     $(td).html("<a href='<%=markerURL%>"+cellData+"'>"+cellData+"</a>");
                 }
             },
             {
                 "name": "LG",
                 "targets": [1,-2],
                 "className": "markers b ar",
                 "orderable": true
             },
             {
                 "name": "position",
                 "targets": [2,-3],
                 "className": "markers b ar",
                 "orderable": true
             },
             {
                 "targets": '_all',
                 "className": 'dt-center b',
                 "orderable": false,
                 "createdCell": function (td, cellData, rowData, row, col) {
                     if (cellData=='A' || cellData=='a') {
                         $(td).css("background-color", "darkred");
                     } else if (cellData=='B' || cellData=='b') {
                         $(td).css("background-color", "darkgreen");
                     }
                 }
             }
         ],
         "ajax": {
             "url": "model/genotypeJSON.jsp",
             "type": "POST",
             "data": {
                 "mappingPopulation": "<%=mappingPopulation%>"
             }
         },         
     });

     $('#genotypes tbody').on('mouseover', 'tr', function() {
         var rowData = table.row(this).data();
         var markerName = rowData[0];
         $.get("model/markerJSON.jsp",
               { markerName: markerName },
               function(data) {
                   var str = "<b>"+markerName+"</b>";
                   if (data.linkageGroups!="") {
                       str += " on <b>"+data.linkageGroups+"</b> at "+data.positions+" cM";
                   }
                   str += "<br/>";
                   if (data.QTLs!="") {
                       str += "Associated with ";
                       for (var i=0; i<data.QTLs.length; i++) {
                           str += "<b>"+data.QTLs[i]+"</b>";
                           if (data.traits[i]!="") str += ":"+data.traits[i];
                           str += " ";
                       }
                   }
                   str += "&nbsp;";
                   $('div#tooltip').html(str);
               },
               "json");
     });

     // $('#genotypes tbody').on('mouseout', 'tr', function() {
     //     $('div#tooltip').html('&nbsp;<br/>&nbsp;');
     // });

 }); 
</script>
<!-- /genotypeDisplayer.jsp -->
