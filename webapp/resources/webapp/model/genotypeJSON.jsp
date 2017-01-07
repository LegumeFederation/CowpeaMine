<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.intermine.metadata.Model" %>
<%@ page import="org.intermine.pathquery.Constraints,org.intermine.pathquery.OrderDirection,org.intermine.pathquery.PathQuery" %>
<%@ page import="org.intermine.webservice.client.core.ServiceFactory,org.intermine.webservice.client.services.QueryService,org.intermine.webservice.client.results.Page" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.Comparator,java.util.Enumeration,java.util.Map,java.util.LinkedHashMap,java.util.List,java.util.Set,java.util.TreeSet,java.util.ArrayList,java.util.Arrays" %>
<%@ page import="java.text.DecimalFormat" %>
<%
// marker position formatting
DecimalFormat df = new DecimalFormat("0.00");

// requested mapping population
String mappingPopulation = request.getParameter("mappingPopulation");
if (mappingPopulation==null) {
    out.println("<p>mappingPopulation missing in genotypeJSON call.</p>");
    return;
}

// requested markers are in a comma-separated string, because can't seem to get DataTables to pass an array
// String markerString = request.getParameter("markers");
// if (markerString==null) {
//     out.println("<p>markers missing in genotypeJSON call.</p>");
//     return;
// }
// List<String> markers = Arrays.asList(markerString.split(","));

// initialization - ought to be a better way!
String serviceRoot = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getServletContext().getContextPath()+"/service";
ServiceFactory factory = new ServiceFactory(serviceRoot);
QueryService service = factory.getQueryService();
Model model = factory.getModel();

// DataTables paging request parameters
int draw = Integer.parseInt(request.getParameter("draw"));     // increases monotonically on each page draw
int start = Integer.parseInt(request.getParameter("start"));   // starting row, zero-based: 0, 25, 50, ...
int length = Integer.parseInt(request.getParameter("length")); // number of rows: 25, 50, etc. -1 means "all"

// linkage group choice
int linkageGroup = Integer.parseInt(request.getParameter("linkageGroup"));

// markers IM paging
int markerStart = Integer.parseInt(request.getParameter("markerStart"));
int markerLength = Integer.parseInt(request.getParameter("markerLength"));

// optional QTL search
String qtl = request.getParameter("qtl");
boolean qtlSearch = (qtl!=null && qtl.length()>0);

// optional trait term search
String traitTerm = request.getParameter("traitTerm");
boolean traitSearch = (traitTerm!=null && traitTerm.length()>0);

// // column ordering
// Map<String,String> orderMap = new LinkedHashMap<String,String>();
// int m = 0;
// while (request.getParameter("order["+m+"][column]")!=null) {
//     String col = request.getParameter("order["+m+"][column]");
//     String dir = request.getParameter("order["+m+"][dir]").toUpperCase(); // for OrderDirection.valueOf()
//     String name = request.getParameter("columns["+col+"][name]");
//     orderMap.put(name,dir);
//     m++;
// }

// map that will get converted to a JSONObject for output
Map<String,Object> jsonMap = new LinkedHashMap<String,Object>();
    
try {
        
    // query lines for this line page
    PathQuery lineQuery = new PathQuery(model);
    lineQuery.addViews(
        "GenotypingLine.primaryIdentifier",
        "GenotypingLine.id"
    );
    lineQuery.addConstraint(Constraints.eq("GenotypingLine.mappingPopulation.primaryIdentifier", mappingPopulation));
    // for (String name : orderMap.keySet()) {
    //     String dir = orderMap.get(name);
    //     switch (name) {
    //         case "marker": lineQuery.addOrderBy("GeneticMarker.primaryIdentifier", OrderDirection.valueOf(dir)); break;
    //         case "LG": lineQuery.addOrderBy("GeneticMarker.linkageGroupPositions.linkageGroup.number", OrderDirection.valueOf(dir)); break;
    //         case "position": lineQuery.addOrderBy("GeneticMarker.linkageGroupPositions.position", OrderDirection.valueOf(dir)); break;
    //         default: break;
    //     }
    // }
    lineQuery.addOrderBy("GenotypingLine.number", OrderDirection.ASC);
    lineQuery.addOrderBy("GenotypingLine.primaryIdentifier", OrderDirection.ASC);
    List<List<String>> lineResults;
    if (length>0) {
        Page linePage = new Page(start, length);
        lineResults = service.getResults(lineQuery, linePage);
    } else {
        lineResults = service.getAllResults(lineQuery);
    }
    List<String> lines = new ArrayList<String>();
    Map<String,Integer> lineIDs = new LinkedHashMap<String,Integer>();
    for (List<String> result : lineResults) {
        String line = result.get(0);
        Integer id = new Integer(Integer.parseInt(result.get(1)));
        lines.add(line);
        lineIDs.put(line, id);
    }
    int recordsTotal = service.getCount(lineQuery) + 1; // for DataTables pagination, add the header row!

    // query markers, linkage groups and positions for this marker page
    // NOTE: this breaks for multiple genetic maps (multiple linkage groups per marker)!!!
    PathQuery markerQuery = new PathQuery(model);
    markerQuery.addViews(
        "GeneticMarker.primaryIdentifier",
        "GeneticMarker.id",
        "GeneticMarker.linkageGroupPositions.linkageGroup.number",
        "GeneticMarker.linkageGroupPositions.position"
    );
    markerQuery.addConstraint(Constraints.eq("GeneticMarker.mappingPopulations.primaryIdentifier", mappingPopulation));
    if (traitSearch) {
        markerQuery.addConstraint(Constraints.contains("GeneticMarker.QTLs.secondaryIdentifier", traitTerm));
    } else if (qtlSearch) {
        markerQuery.addConstraint(Constraints.eq("GeneticMarker.QTLs.primaryIdentifier", qtl));
    } else {
        markerQuery.addConstraint(Constraints.eq("GeneticMarker.linkageGroupPositions.linkageGroup.number", String.valueOf(linkageGroup)));
    }
    markerQuery.addOrderBy("GeneticMarker.linkageGroupPositions.linkageGroup.number", OrderDirection.ASC); // in case we have multiple LGs from a search
    markerQuery.addOrderBy("GeneticMarker.linkageGroupPositions.position", OrderDirection.ASC);
    markerQuery.addOrderBy("GeneticMarker.primaryIdentifier", OrderDirection.ASC); // for two markers at the same position, which is common
    Page markerPage = new Page(markerStart, markerLength);
    List<List<String>> markerResults = service.getResults(markerQuery, markerPage);
    List<String> markers = new ArrayList<String>();
    Map<String,Integer> markerIDs = new LinkedHashMap<String,Integer>();
    Map<String,Integer> linkageGroups = new LinkedHashMap<String,Integer>();
    Map<String,Double> positions = new LinkedHashMap<String,Double>();
    for (List<String> result : markerResults) {
        String marker = result.get(0);
        Integer id = new Integer(Integer.parseInt(result.get(1)));
        Integer lg = Integer.parseInt(result.get(2));
        Double position = Double.parseDouble(result.get(3));
        markers.add(marker);
        markerIDs.put(marker, id);
        linkageGroups.put(marker, lg);
        positions.put(marker, position);
    }

    // query values for each line, for the given markers
    // NOTE: this breaks for multiple genetic maps (multiple linkage groups per marker)!!!
    Map<String,char[]> valuesMap = new LinkedHashMap<String,char[]>();
    for (String line : lines) {
        PathQuery valueQuery = new PathQuery(model);
        valueQuery.addViews(
                            "GenotypeValue.value",
                            "GenotypeValue.marker.primaryIdentifier",
                            "GenotypeValue.marker.linkageGroupPositions.linkageGroup.number",
                            "GenotypeValue.marker.linkageGroupPositions.position"
                            );
        valueQuery.addConstraint(Constraints.lookup("GenotypeValue.line", line, ""));
        valueQuery.addConstraint(Constraints.oneOfValues("GenotypeValue.marker.primaryIdentifier", markers));
        valueQuery.addOrderBy("GenotypeValue.marker.linkageGroupPositions.linkageGroup.number", OrderDirection.ASC);
        valueQuery.addOrderBy("GenotypeValue.marker.linkageGroupPositions.position", OrderDirection.ASC);
        valueQuery.addOrderBy("GenotypeValue.marker.primaryIdentifier", OrderDirection.ASC); // for two markers at the same position, which is common
        List<List<String>> valueResults = service.getAllResults(valueQuery);
        char[] values = new char[valueResults.size()];
        int i = 0;
        for (List<String> result : valueResults) {
            values[i++] = result.get(0).charAt(0); // NOTE: only applies to single-character values!
        }
        valuesMap.put(line, values);
    }

    // this object will become the JSON data
    List<Object> dataList = new ArrayList<Object>();

    // unwrap the markers for the first row
    List<Object> markersRow = new ArrayList<Object>();
    markersRow.add("LG<br/>Position<br/><b>Marker</b>"); // leading line column
    for (String marker : markers) {
        String heading = linkageGroups.get(marker)+"<br/>"+df.format(positions.get(marker))+"<br/>"+"<a class='marker' href='report.do?id="+markerIDs.get(marker)+"'>"+marker+"</a>";
        markersRow.add(heading);
    }
    // buffer if less than markerLength values
    int bufferNum = markerLength - markers.size();
    if (bufferNum>0) {
        for (int i=0; i<bufferNum; i++) {
            markersRow.add("");
        }
    }
    markersRow.add("LG<br/>Position<br/><b>Marker</b>"); // trailing line column
    dataList.add(markersRow.toArray());
        
    // unwrap the values into data rows with line at left and repeat line at end
    for (String line : lines) {
        List<Object> valuesRow = new ArrayList<Object>();
        char[] values = valuesMap.get(line);
        String heading = "<a href='report.do?id="+lineIDs.get(line)+"'>"+line+"</a>";
        valuesRow.add(heading);              // leading line
        for (int j=0; j<values.length; j++) {
            valuesRow.add(values[j]);        // values in rest of columns, until
        }
        // buffer empty cells
        if (bufferNum>0) {
            for (int i=0; i<bufferNum; i++) {
                valuesRow.add(' ');
            }
        }
        valuesRow.add(heading);              // trailing line
        dataList.add(valuesRow.toArray());
    }

    // create the JSON response using the Map to JSON utility
    jsonMap.put("draw", draw);
    jsonMap.put("recordsTotal", recordsTotal);
    jsonMap.put("recordsFiltered", recordsTotal); // no filtering yet
    jsonMap.put("data", dataList.toArray());

} catch (Exception ex) {

    jsonMap.put("error", ex.toString());

}

// write the JSON to the response
try {
    JSONObject json = new JSONObject(jsonMap);
    json.write(response.getWriter());
} catch (Exception ex) {
    throw new RuntimeException(ex);
}
%>
