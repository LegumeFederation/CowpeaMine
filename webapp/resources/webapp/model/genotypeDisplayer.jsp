<!-- genotypeDisplayer.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.util.List,java.util.Map,java.text.DecimalFormat" %>
<html:xhtml />
<tiles:importAttribute />
<style>
 body { font-family:sans-serif;  font-size:12px; }
 table.dataTable thead th { padding:0px; border:0; background-color: white; }
 table.dataTable tbody td { padding:2px; font-size:8px; color:white; background-color: gray; }
 table.dataTable.no-footer { border-bottom:0; margin-bottom:5px; }
 .dt-buttons { margin-top:2px; }
 .dataTables_info { padding: 0 5px 0 0; }
 .b { font-weight: bold; }
 .ar { text-align: right; }
 .al { text-align: left; }
 .line { background-color:gray; color:white; font-size:8px; }
 .line a { text-decoration:none; color:white; font-weight:bold; }
 a.marker { text-decoration:none; color:white; font-weight: bold; }
 div#genotypes_wrapper { top: -26px; }
 div#tooltip {
     /* position: relative; */
     /* left: 160px; */
     /* top:  26px; */
     float: right;
     display:inline-block;
     width: 700px;
     padding: 2px 0;
     text-align: left;
     color: white;
     background-color: gray;
     border-width: 5px;
     border-style: solid;
     border-color: gray transparent transparent transparent;
     border-radius: 6px;
 }
</style>
<%
// constants
int markerLength = 25;
int markerAdvance = 20;

// data from GenotypeDisplayer
String mappingPopulation = (String) request.getAttribute("mappingPopulation");
List<Integer> linkageGroups = (List<Integer>) request.getAttribute("linkageGroups");
Map<Integer,Integer> linkageGroupCounts = (Map<Integer,Integer>) request.getAttribute("linkageGroupCounts");
List<String> qtls = (List<String>) request.getAttribute("qtls");
%>

<table>
    <tr>
        <td>
            QTL<br/>
            <select id="qtlSelect">
                <option value="">--QTL--</option>
                <% for (String qtl : qtls) { %><option value="<%=qtl%>"><%=qtl%></option><% } %>
            </select>
        </td>
        <td>
            Trait text search<br/>
            <input id="traitTerm"/><button id="traitButton">Search</button><button id="resetButton">Reset</button>
        </td>
    </tr>
</table>

<div id="tooltip">&nbsp;<br/>&nbsp;</div>

<table id="genotypes" class="cell-border" cellspacing="0" width="100%">
    <thead>
        <tr>
            <th></th>
            <% for (int i=0; i<markerLength; i++) { %><th></th><% } %>
            <th></th>
        </tr>
    </thead>
</table>

<p>
    <!-- This content should be stored in MappingPopulation somewhere, since symbols may differ. -->
    <span style="color:darkred">A = Parent A</span>, <span style="color:darkgreen">B = Parent B</span>. Lower case: genotype calls reversed based on parental alleles.
</p>

<script type="text/javascript">

// markers per page
var markerLength = <%=markerLength%>;

// advance this many markers per page jump (less so we have a little overlap)
var markerAdvance = <%=markerAdvance%>;

// initialize to first markers on load
var markerStart = 0;

// initialize to first linkage group on load
var linkageGroup = 1;

// initialize for QTL search, which doesn't happen if it's empty
var qtl = '';

// initialize for trait term search, which doesn't happen if it's empty
var traitTerm = '';

// store the old marker name so we don't do AJAX calls on vertical mouse motion within the same column
var oldMarkerName = "";

// store the linkage group counts (number of markers) in an array
var linkageGroupCounts = [ <% for (Integer lg : linkageGroupCounts.values()) out.print(lg+","); %> ];

$(document).ready(function() {

    var table = $('#genotypes').DataTable({
        "deferRender": true,
        "processing": true, 
        "serverSide": true,
        "scrollX": true,
        "autoWidth": false,
        "searching": false,
        "pageLength": 10,
        "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
        "pagingType": "simple_numbers",
        "language": {
            "lengthMenu": "Show _MENU_ lines",
            "paginate": {
                "previous": "Previous lines",
                "next": "Next lines"
            }
        },
        "order": [[0,'asc']],
        "columnDefs": [
            {
                "targets": [0],
                "className": "line ar",
                "orderable": false
            },
            {
                "targets": [-1],
                "className": "line al",
                "orderable": false
            },
            {
                "targets": '_all',
                "className": 'dt-center',
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
                "mappingPopulation": "<%=mappingPopulation%>",
                "markerLength": markerLength,
                "markerStart":  function() { return markerStart; },
                "linkageGroup": function() { return linkageGroup; },
                "qtl": function() { return qtl; },
                "traitTerm": function() { return traitTerm; }
            }
        },
        "dom": "lfrtipB",
        "buttons": {
            "buttons": [
                <% for (Integer lg : linkageGroups) { %>
                {
                    "text": "LG<%=lg%>",
                    "action": function (e, dt, node, config) {
                        if (qtl=='' && traitTerm=='' && linkageGroup!=<%=lg%>) {
                            linkageGroup = <%=lg%>;
                            markerStart = 0; // reset on new linkage group
                            dt.ajax.reload();
                        }
                    }
                },
                <% } %>
                {
                    "text": "Prev "+markerAdvance+" Markers",
                    "action": function (e, dt, node, config) {
                        if (markerStart>=markerAdvance) {
                            markerStart -= markerAdvance;
                            dt.ajax.reload();
                        }
                    }
                },
                {
                    "text": "Next "+markerAdvance+" Markers",
                    "action": function (e, dt, node, config) {
                        var d = dt.row(0).data();
                        var count = 0;
                        for (var i=0; i<d.length; i++) {
                            if (d[i].includes("href")) count++;
                        }
                        if (count==markerLength) {
                            var k = linkageGroup - 1;
                            if (markerStart<(linkageGroupCounts[k]-markerAdvance)) {
                                markerStart += markerAdvance;
                                dt.ajax.reload();
                            }
                        }
                    }
                }
            ]
        }
        
    });

    $('#genotypes tbody').on('mouseenter', 'td', function() {
        var colData = table.column(this).data();
        if (colData[0].includes('Marker') || colData[0]=='') {
            oldMarkerName = "";
            $('div#tooltip').html("&nbsp;<br/>&nbsp;"); // line columns
        } else {             
            var parts1 = colData[0].split(">");
            var parts2 = parts1[3].split("<");
            var markerName = parts2[0];
            if (markerName!=oldMarkerName) {
                oldMarkerName = markerName;
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
            }
        }
    });

    $('#qtlSelect').on('change', function() {
        qtl = $(this).val();
        traitTerm = '';
        $('#traitTerm').val('');
        markerStart = 0;
        table.ajax.reload();
    });

    $('#traitButton').on('click', function() {
        traitTerm = $('#traitTerm').val().trim();
        qtl = '';
        $('#qtlSelect').prop('selectedIndex', 0);
        markerStart = 0;
        table.ajax.reload();
    });
                
    $('#resetButton').on('click', function() {
        traitTerm = '';
        qtl = '';
        $('#qtlSelect').prop('selectedIndex', 0);
        markerStart = 0;
        table.ajax.reload();
    });

});

</script>
<!-- /genotypeDisplayer.jsp -->
