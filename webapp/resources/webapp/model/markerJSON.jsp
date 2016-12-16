<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="org.intermine.metadata.Model" %>
<%@ page import="org.intermine.pathquery.Constraints, org.intermine.pathquery.OrderDirection, org.intermine.pathquery.PathQuery" %>
<%@ page import="org.intermine.webservice.client.core.ServiceFactory, org.intermine.webservice.client.services.QueryService, org.intermine.webservice.client.results.Page" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.util.Map, java.util.LinkedHashMap, java.util.List, java.util.ArrayList" %>
<%
// output JSON map
Map<String,Object> jsonMap = new LinkedHashMap<String,Object>();

// get requested marker
String markerName = request.getParameter("markerName");
if (markerName==null) {
    jsonMap.put("error", "markerName missing in markerJSON request.");
    JSONObject json = new JSONObject(jsonMap);
    json.write(response.getWriter());
    return;
}

// initialization - ought to be a better way!
String serviceRoot = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getServletContext().getContextPath()+"/service";
ServiceFactory factory = new ServiceFactory(serviceRoot);
QueryService service = factory.getQueryService();
Model model = factory.getModel();

try {

    // query QTLs for requested marker (if any)
    PathQuery qtlQuery = new PathQuery(model);
    qtlQuery.addViews(
        "GeneticMarker.QTLs.primaryIdentifier",
        "GeneticMarker.QTLs.secondaryIdentifier"
    );
    qtlQuery.addConstraint(Constraints.eq("GeneticMarker.primaryIdentifier", markerName));
    qtlQuery.addOrderBy("GeneticMarker.QTLs.primaryIdentifier", OrderDirection.ASC);
    List<List<String>> qtlResults = service.getAllResults(qtlQuery);
    List<String> qtls = new ArrayList<String>();
    List<String> traits = new ArrayList<String>();
    for (List<String> result : qtlResults) {
        qtls.add(result.get(0));
        traits.add(result.get(1));
    }

    // query linkage group positions for requested marker (if any)
    PathQuery lgQuery = new PathQuery(model);
    lgQuery.addViews(
        "GeneticMarker.linkageGroupPositions.linkageGroup.primaryIdentifier",
        "GeneticMarker.linkageGroupPositions.position"
    );
    lgQuery.addConstraint(Constraints.eq("GeneticMarker.primaryIdentifier", markerName));
    lgQuery.addOrderBy("GeneticMarker.linkageGroupPositions.linkageGroup.primaryIdentifier", OrderDirection.ASC);
    List<List<String>> lgResults = service.getAllResults(lgQuery);
    List<String> linkageGroups = new ArrayList<String>();
    List<Double> positions = new ArrayList<Double>();
    for (List<String> result : lgResults) {
        linkageGroups.add(result.get(0));
        positions.add(new Double(result.get(1)));
    }

    // create the JSON response using the Map to JSON utility
    jsonMap.put("linkageGroups", linkageGroups);
    jsonMap.put("positions", positions);
    jsonMap.put("QTLs", qtls);
    jsonMap.put("traits", traits);

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
