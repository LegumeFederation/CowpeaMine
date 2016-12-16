<!-- markerGenotypes.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.util.Map,java.util.List,java.net.URLEncoder" %>
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
</style>
<%
// marker linkage group number and position
Map<String,Integer> markerLinkageGroups = (Map<String,Integer>) request.getAttribute("markerLinkageGroups");
Map<String,Double> markerPositions = (Map<String,Double>) request.getAttribute("markerPositions");

// the mapping populations
Map<String,Integer> mappingPopulations = (Map<String,Integer>) request.getAttribute("mappingPopulations");

// the markers for each mapping population
Map<String, Map<String,Integer>> mappingPopulationMarkers = (Map<String, Map<String,Integer>>) request.getAttribute("mappingPopulationMarkers");

// the lines for each mapping population
Map<String, Map<String,Integer>> mappingPopulationLines = (Map<String, Map<String,Integer>>) request.getAttribute("mappingPopulationLines");

// the values for each marker/line for each mapping population
Map<String, Map<String,char[]>> mappingPopulationValues = (Map<String, Map<String,char[]>>) request.getAttribute("mappingPopulationValues");

// loop over mapping populations
for (String mp : mappingPopulations.keySet()) {
    String tableID = mp.replaceAll(" ","");
    Map<String,Integer> markers = mappingPopulationMarkers.get(mp);
    Map<String,Integer> lines = mappingPopulationLines.get(mp);
    Map<String,char[]> markersValues = mappingPopulationValues.get(mp);
%>
<!-- have to put table inside a div to limit its width -->
<div style="width:1000px; padding:5px; border:1px solid gray; margin-bottom:2px;">
    <div style="margin:2px 0;">
        Mapping Population: <a href="report.do?id=<%=mappingPopulations.get(mp)%>"><%=mp%></a>
    </div>
    <table id="<%=tableID%>" class="cell-border" cellspacing="0" width="100%">
        <thead>
            <tr>
                <th>Marker</th>
                <th>LG</th>
                <th>Pos</th>
                <% for (String line : lines.keySet()) { %><th><%=line.replace('-',' ')%></th><% } %>
                <th>Pos</th>
                <th>LG</th>
                <th>Marker</th>
            </tr>
        </thead>
        <tbody>
            <%
            for (String marker : markers.keySet()) {
                char[] values = markersValues.get(marker);
            %>
            <tr>
                <td><a href="report.do?id=<%=markers.get(marker)%>"><%=marker%></a></td>
                <td><%=markerLinkageGroups.get(marker)%></td>
                <td><%=markerPositions.get(marker)%></td>
                <% for (int i=0; i<values.length; i++) { %><td><%=values[i]%></td><% } %>
                <td><%=markerPositions.get(marker)%></td>
                <td><%=markerLinkageGroups.get(marker)%></td>
                <td><a href="report.do?id=<%=markers.get(marker)%>"><%=marker%></a></td>
            </tr>
            <%
            }
            %>
        </tbody>
        <tfoot>
            <tr>
                <th>Marker</th>
                <th>LG</th>
                <th>Pos</th>
                <% for (String line : lines.keySet()) { %><th><%=line.replace('-',' ')%></th><% } %>
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
</div>

<script type="text/javascript"> 
 $(document).ready(function() {

     var table = $('#<%=tableID%>').DataTable({
         "processing": true,
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
                 "orderable": true
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
                         $(td).css('background-color', 'darkred')
                     } else if (cellData=='B' || cellData=='b') {
                         $(td).css('background-color', 'darkgreen')
                     }
                 }
             }
         ]
     });

 });
</script>
<%
} // loop over mapping populations
%>
<!-- /markerGenotypes.jsp -->
