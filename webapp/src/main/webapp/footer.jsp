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
        <table>
            <tr>
                <td><a target="_new" href="https://usda.gov/" title="USDA"><img style="border:0" src="model/images/USDA-92x67.png"/></a></td>
                <td>
                    The <a  target="_new" href="https://legumeinfo.org/">Legume Information System (LIS)</a> is a research project of the <br/>
                    <a target="_new" href="https://www.ars.usda.gov/midwest-area/ames/cicgru/" title="USDA-ARS">USDA-ARS:Corn Insects and Crop Genetics Research</a>
                    in Ames, IA.
                </td>
                <td><a target="_new" href="https://nsf.gov/" title="NSF"><img style="border:0" src="model/images/nsf1.png"/></a></td>
                <td>
                    Mine development is also supported by the <a  target="_new" href="https://legumefederation.org/">Legume Federation</a>, <br/>
                    an <a target="_new" href="https://nsf.gov/">NSF</a> project to federate legume resources around the world.
                </td>
            </tr>
        </table>
        <table>
            <tr>
                <td>
                    <!-- LegFed member -->
                    <a target="_new" href="https://legumefederation.org/" title="Legume Federation"><img src="https://mines.legumeinfo.org/legfed-member.png"/></a>
                </td>
                <td>
                    <!-- powered -->
                    Powered by <a target="new" href="http://intermine.org/" title="InterMine"><img src="images/icons/intermine-footer-logo.png" alt="InterMine logo" /></a>
                </td>
            </tr>
        </table>
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

        <!-- LIS/LegFed mines -->
        <li><a href="http://mines.legumeinfo.org/beanmine/begin.do" target="_blank">LIS BeanMine (common bean)</a></li>
        <li><a href="http://mines.legumeinfo.org/chickpeamine/begin.do" target="_blank">LIS ChickpeaMine (desi and kabuli varieties)</a></li>
        <li><a href="http://mines.legumeinfo.org/cowpeamine/begin.do" target="_blank">LIS CowpeaMine</a></li>
        <li><a href="http://mines.legumeinfo.org/legumemine/begin.do" target="_blank">LIS LegumeMine (various legumes)</a></li>
        <li><a href="http://mines.legumeinfo.org/peanutmine/begin.do" target="_blank">LIS PeanutMine (arachis, duranensis, hypogaea)</a></li>
        <li><a href="http://mines.legumeinfo.org/soymine/begin.do" target="_blank">LIS SoyMine (soybean)</a></li>
        <li><a href="http://medicmine.jcvi.org/medicmine/begin.do" target="_blank">JCVI MedicMine (Medicago)</a></li>
        
    </ul>

    <p class="footer-copy">InterMine &copy; 2002 - 2017 Department of Genetics, University of Cambridge, Downing Street, Cambridge CB2 3EH, United Kingdom</p>

    <div style="clear:both"></div>
</div>
<!-- /footer.jsp -->
