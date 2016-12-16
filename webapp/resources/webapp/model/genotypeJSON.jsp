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

// initialization - ought to be a better way!
String serviceRoot = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getServletContext().getContextPath()+"/service";
ServiceFactory factory = new ServiceFactory(serviceRoot);
QueryService service = factory.getQueryService();
Model model = factory.getModel();

// DataTables request parameters
int draw = Integer.parseInt(request.getParameter("draw"));     // increases monotonically on each page draw
int start = Integer.parseInt(request.getParameter("start"));   // starting row, zero-based: 0, 25, 50, ...
int length = Integer.parseInt(request.getParameter("length")); // number of rows: 25

// column ordering
Map<String,String> orderMap = new LinkedHashMap<String,String>();
int m = 0;
while (request.getParameter("order["+m+"][column]")!=null) {
    String col = request.getParameter("order["+m+"][column]");
    String dir = request.getParameter("order["+m+"][dir]").toUpperCase(); // for OrderDirection.valueOf()
    String name = request.getParameter("columns["+col+"][name]");
    orderMap.put(name,dir);
    m++;
}

// map that will get converted to a JSONObject for output
Map<String,Object> jsonMap = new LinkedHashMap<String,Object>();
    
try {
        
    // paging
    Page markerPage = new Page(start, length);
        
    // query markers and their IDs for this page for values query
    PathQuery markerQuery = new PathQuery(model);
    markerQuery.addViews(
        "GeneticMarker.primaryIdentifier",
        "GeneticMarker.id",
        "GeneticMarker.linkageGroupPositions.linkageGroup.number",
        "GeneticMarker.linkageGroupPositions.position"
    );
    markerQuery.addConstraint(Constraints.eq("GeneticMarker.mappingPopulations.primaryIdentifier", mappingPopulation));
    for (String name : orderMap.keySet()) {
        String dir = orderMap.get(name);
        switch (name) {
            case "marker": markerQuery.addOrderBy("GeneticMarker.primaryIdentifier", OrderDirection.valueOf(dir)); break;
            case "LG": markerQuery.addOrderBy("GeneticMarker.linkageGroupPositions.linkageGroup.number", OrderDirection.valueOf(dir)); break;
            case "position": markerQuery.addOrderBy("GeneticMarker.linkageGroupPositions.position", OrderDirection.valueOf(dir)); break;
            default: break;
        }
    }
    List<List<String>> markerResults = service.getResults(markerQuery, markerPage);
    List<String> markers = new ArrayList<String>();
    List<Integer> markerIDs = new ArrayList<Integer>();     // Bag for values query
    List<Integer> markerLGs = new ArrayList<Integer>();     // LinkageGroup.number is int
    List<String> markerPositions = new ArrayList<String>(); // String for consistent formatting xxx.xx
    for (List<String> result : markerResults) {
        markers.add(result.get(0));
        markerIDs.add(Integer.parseInt(result.get(1)));
        markerLGs.add(Integer.parseInt(result.get(2)));
        markerPositions.add(df.format(Double.parseDouble(result.get(3))));
    }
    int recordsTotal = service.getCount(markerQuery);
        
    // query values for this list of markers, be sure to order by line
    PathQuery valueQuery = new PathQuery(model);
    valueQuery.addViews(
        "GenotypeValue.value",
        "GenotypeValue.marker.primaryIdentifier", // for ordering
        "GenotypeValue.line.primaryIdentifier"    // for ordering
    );
    valueQuery.addConstraint(Constraints.eq("GenotypeValue.line.mappingPopulation.primaryIdentifier", mappingPopulation));
    valueQuery.addConstraint(Constraints.inIds("GenotypeValue.marker", markerIDs));
    valueQuery.addOrderBy("GenotypeValue.marker.primaryIdentifier", OrderDirection.ASC);
    valueQuery.addOrderBy("GenotypeValue.line.primaryIdentifier", OrderDirection.ASC);
    List<List<String>> valueResults = service.getAllResults(valueQuery);
    List<String> values = new ArrayList<String>();
    for (List<String> result : valueResults) {
        values.add(result.get(0));
    }
            
    // unwrap the values into data rows with marker, LG, position at left and repeat position, LG, marker at end
    int n = 0;
    int numLines = values.size()/markers.size();
    List<Object> dataList = new ArrayList<Object>();
    for (int i=0; i<markers.size(); i++) {
        List<Object> valueList = new ArrayList<Object>();
        valueList.add(markers.get(i));         // marker in first column
        valueList.add(markerLGs.get(i));       // LG in second column
        valueList.add(markerPositions.get(i)); // LG position in third column
        for (int j=0; j<numLines; j++) {
            valueList.add(values.get(n++));    // values in rest of columns, until
        }
        valueList.add(markerPositions.get(i)); // LG position again in third to last column
        valueList.add(markerLGs.get(i));       // LG again in next to last column
        valueList.add(markers.get(i));         // marker again in last column
        dataList.add(valueList.toArray());
    }

    // create the JSON response using the Map to JSON utility
    jsonMap.put("draw", draw);
    jsonMap.put("recordsTotal", recordsTotal);
    jsonMap.put("recordsFiltered", recordsTotal); // FIX THIS
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
