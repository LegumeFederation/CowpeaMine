<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- footer.jsp -->

<div class="body" align="center" style="clear:both">

    <!-- contact form removed, can't send email -->

    <!-- funding -->
    <div id="funding-footer">
        <fmt:message key="funding" />
        <br/>
        <br/>
        <!-- powered -->
        Powered by <a target="new" href="http://intermine.org" title="InterMine"><img src="images/icons/intermine-footer-logo.png" alt="InterMine logo" /></a>
    </div>

</div>

<!-- removed cam logo -->
<div class="body bottom-footer">

    <ul class="footer-links">

        <!-- contact us form commented out - can't send email -->
        <!-- <li><a href="#" onclick="showContactForm();return false;">Contact Us</a></li> -->

        <c:set value="${WEB_PROPERTIES['header.links']}" var="headerLinks"/>
        <!-- web properties -->
        <c:forEach var="entry" items="${headerLinks}" varStatus="status">
            <c:set value="header.links.${entry}" var="linkProp"/>
            <c:choose>
                <c:when test="${!empty WEB_PROPERTIES[linkProp]}">
                    <li><a href="${WEB_PROPERTIES[linkProp]}">${entry}</a></li>
                </c:when>
                <c:otherwise>
                    <li><a href="${WEB_PROPERTIES['project.sitePrefix']}/${entry}.shtml">${entry}</a></li>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <!-- LegFed and relevant mines -->
        <li><a href="http://intermine.legumefederation.org/legumemine/begin.do" target="_blank">LegFed LegumeMine (various legumes)</a></li>
        <li><a href="http://mines.legumeinfo.org/beanmine/begin.do" target="_blank">LIS BeanMine (string bean)</a></li>
        <li><a href="http://mines.legumeinfo.org/soymine/begin.do" target="_blank">LIS Soymine (soybean)</a></li>
	<li><a href="http://mines.legumeinfo.org/peanutmine/begin.do" target="_blank">LIS PeanutMine (several peanut species)</a></li>
        <li><a href="http://medicmine.jcvi.org/medicmine/begin.do" target="_blank">JCVI MedicMine (Medicago)</a></li>

    </ul>

    <p class="footer-copy">InterMine &copy; 2002 - 2016 Department of Genetics, University of Cambridge, Downing Street, Cambridge CB2 3EH, United Kingdom</p>

    <div style="clear:both"></div>
</div>
<!-- /footer.jsp -->
