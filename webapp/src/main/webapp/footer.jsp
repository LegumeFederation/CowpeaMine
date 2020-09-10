<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="/WEB-INF/struts-tiles.tld" prefix="tiles" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!-- footer.jsp -->

<div class="body" align="center" style="clear:both">

  <!-- contact -->
  <c:if test="${pageName != 'contact'}">
    <div id="contactFormDivButton">
      <im:vspacer height="11" />
      <div class="contactButton">
        <a href="#" onclick="showContactForm();return false">
          <b><fmt:message key="feedback.title"/></b>
        </a>
      </div>
    </div>
    <div id="contactFormDiv" style="display:none;">
      <im:vspacer height="11" />
      <tiles:get name="contactForm" />
    </div>
  </c:if>
  
  <!-- logos -->
  <div style="padding:0px;">
    <div style="float:left; width:33%; margin:auto; height:71px; padding-top:4px;">
      <!-- USDA-ARS -->
      <a target="_new" href="https://usda.gov/" title="USDA"><img src="model/images/USDA-92x67.png" alt="USDA"/></a>
    </div>
    <div style="float:left; width:33%; margin:auto; height:73px; padding-top:2px;">
      <!-- LegFed member -->
      <a target="_new" href="https://legumefederation.org/" title="Legume Federation"><img src="https://mines.legumeinfo.org/legfed-member.png" alt="Legume Federation"/></a>
    </div>
    <div style="float:right; width:33%; margin:auto; height:50px; padding-top:25px;">
      <!-- powered by InterMine-->
      <a target="new" href="http://intermine.org/" title="InterMine"><img src="images/icons/intermine-footer-logo.png" alt="InterMine logo" /></a>
    </div>
    <div style="clear:both"></div>
  </div>

  <div>
    The <a target="_new" href="https://legumeinfo.org/">Legume Information System (LIS)</a> is a research project of the
    <a target="_new" href="https://www.ars.usda.gov/midwest-area/ames/cicgru/" title="USDA-ARS">USDA-ARS:Corn Insects and Crop Genetics Research</a>
    in Ames, IA.
  </div>

  <!-- LIS/LegFed mines -->
  <div style="align:center; padding:5px;">
    <a href="/beanmine/begin.do" target="_blank">BeanMine</a> |
    <a href="/chickpeamine/begin.do" target="_blank">ChickpeaMine</a> |
    <a href="/cowpeamine/begin.do" target="_blank">CowpeaMine</a> |
    <a href="/lupinmine/begin.do" target="_blank">LupinMine</a> |    
    <a href="/peanutmine/begin.do" target="_blank">PeanutMine</a> |
    <a href="/soymine/begin.do" target="_blank">SoyMine</a> |
    <a href="/medicmine/begin.do" target="_blank">MedicMine</a> |
    <a href="/legumemine/begin.do" target="_blank">LegumeMine</a>
  </div>
    
  <!-- copyright -->
  <div>
    InterMine &copy; 2002 - 2020 Department of Genetics, University of Cambridge, Downing Street, Cambridge CB2 3EH, United Kingdom
  </div>

</div>
<!-- /footer.jsp -->
