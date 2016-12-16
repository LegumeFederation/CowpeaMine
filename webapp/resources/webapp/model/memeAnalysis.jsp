<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ page import="java.net.URLEncoder" language="java" %>

<!-- memeAnalysis.jsp -->
<html:xhtml />
<tiles:importAttribute />

<c:if test="${errorMessage!=null}">
    <c:if test="${errorMessage!='---'}">
        <div style="border:1px solid gray; padding:20px;">
            <h3>MEME Analysis</h3>
            <p>
                ${errorMessage}
            </p>
        </div>
    </c:if>
</c:if>

<c:if test="${errorMessage==null}">
        
    <div id="memeFrame_toggle" style="clear:both; padding-left:10px; font-weight:bold; background-color:gray; color:white;">
        Click to toggle MEME frame <img src="images/disclosed.gif" id="memeToggle" />
    </div>
    
    <iframe id="memeFrame" sandbox="allow-scripts"
            src="${WEB_PROPERTIES['meme.hostURI']}/${jobID}/meme_out/meme.html"
            width="${WEB_PROPERTIES['meme.iframeWidth']}" height="${WEB_PROPERTIES['meme.iframeHeight']}">
        You don't have frames!
    </iframe>
    <p>
        MEME jobID:${jobID} submissionTime:${submissionTime} completionTime:${completionTime}
    </p>
    
    <script type="text/javascript">
     jQuery("#memeFrame_toggle").click(
         function () {
             if (jQuery("#memeFrame").is(":hidden")) {
                 jQuery("#memeToggle").attr("src", "images/disclosed.gif");
             } else {
                 jQuery("#memeToggle").attr("src", "images/undisclosed.gif");
             }
             jQuery("#memeFrame").toggle("slow");
         }
     );
    </script>
    
</c:if>
<!-- /memeAnalysis.jsp -->
