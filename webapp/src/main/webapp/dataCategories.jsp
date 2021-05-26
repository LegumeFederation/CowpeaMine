<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im" %>
<%@ page import="java.util.List,java.util.ArrayList,java.util.Map,java.util.LinkedHashMap" %>
<%@ page import="org.intermine.api.InterMineAPI" %>
<%@ page import="org.intermine.api.results.ExportResultsIterator,org.intermine.api.results.ResultElement" %>
<%@ page import="org.intermine.api.profile.Profile,org.intermine.api.query.PathQueryExecutor" %>
<%@ page import="org.intermine.objectstore.ObjectStore,org.intermine.objectstore.ObjectStoreException" %>
<%@ page import="org.intermine.metadata.Model" %>
<%@ page import="org.intermine.pathquery.Constraints,org.intermine.pathquery.OrderDirection,org.intermine.pathquery.PathQuery" %>
<%@ page import="org.intermine.web.logic.session.SessionMethods" %>
<!-- dataCategories -->
<c:set var="note1" value="This is note1, e.g. Only genes that have been mapped to the genome have been loaded."/>
<html:xhtml/>
<%
InterMineAPI im = SessionMethods.getInterMineAPI(session);
ObjectStore os = im.getObjectStore();
Model model = im.getModel();
Profile profile = SessionMethods.getProfile(session);
PathQueryExecutor executor = im.getPathQueryExecutor(profile);

Map<Integer,String> sourceIdsNames = new LinkedHashMap<>();
PathQuery sourcesQuery = new PathQuery(model);
sourcesQuery.addView("DataSource.id");   // 1
sourcesQuery.addView("DataSource.name"); // 0
sourcesQuery.addOrderBy("DataSource.name", OrderDirection.ASC);
ExportResultsIterator sourcesResult = executor.execute(sourcesQuery);
while (sourcesResult.hasNext()) {
    // grab the fields
    List<ResultElement> sourceRow = sourcesResult.next();
    Integer sourceId = (Integer) sourceRow.get(0).getField();   // 0 DataSource.id
    String sourceName = (String) sourceRow.get(1).getField();   // 1 DataSource.name
    sourceIdsNames.put(sourceId, sourceName);
}

Map<Integer,List<String>> sourcesSetNames = new LinkedHashMap<>(); // keyed by DataSource.name
Map<String,String> setDescriptions = new LinkedHashMap<>();       // keyed by DataSet.name
Map<String,String> setUrls = new LinkedHashMap<>();               // keyed by DataSet.name
for (Integer sourceId : sourceIdsNames.keySet()) {
    List<String> setNames = new ArrayList<>();
    PathQuery setsQuery = new PathQuery(model);
    setsQuery.addView("DataSet.name");        // 0
    setsQuery.addView("DataSet.description"); // 1
    setsQuery.addView("DataSet.url");         // 2
    setsQuery.addConstraint(Constraints.eq("DataSet.dataSource.id", String.valueOf(sourceId)));
    setsQuery.addOrderBy("DataSet.name", OrderDirection.ASC);
    ExportResultsIterator setsResult = executor.execute(setsQuery);
    while (setsResult.hasNext()) {
	// grab the fields
	List<ResultElement> setRow = setsResult.next();
	String setName = (String) setRow.get(0).getField();          // 0 DataSet.name
	String setDescription = (String) setRow.get(1).getField();   // 1 DataSet.description
	String setUrl = (String) setRow.get(2).getField();           // 2 DataSet.url
	setNames.add(setName);
	setDescriptions.put(setName, setDescription);
	setUrls.put(setName, setUrl);
    }
    sourcesSetNames.put(sourceId, setNames);
}
%>
<div class="body">
  <h1>Data Sources and their Data Sets</h1>
  <%
    for (Integer sourceId : sourceIdsNames.keySet()) {
	String sourceName = sourceIdsNames.get(sourceId);
	List<String> setNames = sourcesSetNames.get(sourceId);
    %>
  <div class="dataSource"><%=sourceName%></div>
  <div class="dataSet-row">
    <% for (String setName : setNames) { %>
    <div class="dataSet-name"><%=setName%></div>
    <div class="dataSet-description"><%=setDescriptions.get(setName)%></div>
    <div class="dataSet-link">
      <% if (setUrls.get(setName)!=null) { %>
      <a target="_blank" href="<%=setUrls.get(setName)%>">LINK</a>
      <% } %>
    </div>
    <% } %>
  </div>
  <%
    }
    %>
</div>
<!-- /dataCategories -->
