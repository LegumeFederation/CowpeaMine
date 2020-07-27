<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="im"%>

<!-- htmlHead.jsp -->

<tiles:importAttribute name="htmlPageTitle" ignore="true"/>
<tiles:importAttribute name="pageName" ignore="true"/>

<link href="${WEB_PROPERTIES['project.rss']}" rel="alternate" type="application/rss+xml" title="${WEB_PROPERTIES['project.title']} | News" />

<im:headResources section="all"/>

<!-- jquery.dataTables plugin and buttons extension; having trouble with CDN so installed locally -->
<link rel="stylesheet" type="text/css" href="css/jquery.dataTables.min.css" />
<link rel="stylesheet" type="text/css" href="css/buttons.dataTables.min.css" />
<script type="text/javascript" charset="utf8" src="js/jquery.dataTables.min.js"></script>
<script type="text/javascript" charset="utf8" src="js/dataTables.buttons.min.js"></script>

<!-- canvasXpress -->
<link rel="stylesheet" href="css/canvasXpress-old.css" type="text/css" />
<script type="text/javascript" src="js/canvasXpress-old.min.js"></script>

<%
/* In Safari, loading a css that doesnt exist causes weirdness */
String pageName = (String) request.getAttribute("pageName");
if(new java.io.File(application.getRealPath("/css")+"/"+pageName+".css").exists()) {
    request.setAttribute("pageCSS","true");
}
if(new java.io.File(application.getRealPath("/js")+"/"+pageName+".js").exists()) {
    request.setAttribute("pageJS","true");
}
%>

<!-- page: ${pageName} -->

<c:if test="${pageName != 'begin'}">
    <c:if test="${pageName == 'results' || pageName == 'bagDetails' || pageName == 'report'}">
        <im:headResources section="results"/>
    </c:if>

    <c:if test="${pageName == 'results' || pageName == 'query' || pageName == 'templates' || pageName == 'bagDetails' || pageName == 'bag' || pageName == 'mymine'}">
        <im:headResources section="query"/>  
    </c:if>
    
    <c:if test="${pageName == 'bagDetails'}">
        <im:headResources section="bagDetails"/>
    </c:if>

    <c:if test="${pageName == 'query' || pageName == 'exportOptions'}">
        <im:headResources section="query|export"/>
    </c:if>

    <script type="text/javascript">
     // comment this out since it seems to break Datatables
     // jQuery.noConflict();
    </script>

    <%-- this (crap, utter crap) has to live after jQuery.  do not move --%>
    <c:if test="${pageName != 'report' && pageName != 'mymine' && pageName != 'bagDetails' && pageName != 'results' && pageName != 'bagUploadConfirm'}">
        <script type="text/javascript" src="<html:rewrite page='/js/prototype.js'/>"></script>
    </c:if>
</c:if>

<!--[if lt IE 7.]>
    <script defer type="text/javascript" src="pngfix.js"></script>
<![endif]-->

<c:if test="${pageJS == 'true'}">
    <script type="text/javascript" src="<html:rewrite page='/js/${pageName}.js'/>"/></script>
</c:if>

<meta content="${WEB_PROPERTIES['meta.keywords']}" name="keywords"/>
<meta content="${WEB_PROPERTIES['meta.description']}" name="description"/>
<meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type"/>

<!-- print stylesheet -->
<c:if test="${pageName == 'bagDetails' || pageName == 'results'}">
    <link rel="stylesheet" href="<html:rewrite page='/css/print.css'/>" type="text/css" media="print" />
</c:if>

<title>
    <c:choose>
        <c:when test="${empty pageName}">
            <c:out value="${WEB_PROPERTIES['project.title']}" escapeXml="false"/>
        </c:when>
        <c:otherwise>
            <c:out value="${WEB_PROPERTIES['project.title']}: ${htmlPageTitle}" escapeXml="false"/>
        </c:otherwise>
    </c:choose>
</title>


<!-- this is here because it needs to be higher priority than anything else imported -->
<link rel="stylesheet" type="text/css" href="<html:rewrite page='/css/webapp.css'/>"/>

<c:if test="${pageCSS == 'true'}">
    <link rel="stylesheet" type="text/css" href="<html:rewrite page='/css/${pageName}.css'/>"/>
</c:if>

<c:set var="theme" value="${WEB_PROPERTIES['theme']}"/>
<link rel="stylesheet" type="text/css" href="<html:rewrite page='/themes/${theme}/theme.css'/>"/>

<!-- propagate cdn.location to runtime -->
<script type="text/javascript">
jQuery && jQuery(function() {
    if (typeof intermine !== 'undefined' && intermine.options) {
        intermine.options.CDN.server = "${WEB_PROPERTIES['head.cdn.location']}";
    }
});
</script>
<!-- /htmlHead.jsp -->
