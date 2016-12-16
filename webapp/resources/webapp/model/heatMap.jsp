<!-- heatMap.jsp -->
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<html:xhtml />
<tiles:importAttribute />

<c:set var="MAX_CLUSTER" value="100" />
<c:set var="MAX_MAP" value="600" />
<c:set var="MAX_DEFAULT_OPEN" value="100" />

<div id="expression_div">

    <h2>${WEB_PROPERTIES['heatmap.heading']}</h2>
    <h3>${WEB_PROPERTIES['heatmap.subheading']}</h3>
    
    <div id="heatmap_div">

        <p>
            <i>
                Heatmap visualization powered by <a target="_blank" href="http://www.canvasxpress.org">canvasXpress</a>.
                Grab the edges with your mouse to resize the map. Zoom in/out on an area with your scroll wheel.
            </i>
        </p>

        <html:link linkName="#" styleId="bro" style="cursor:pointer">
            <div style="clear:both; padding-left:10px; font-weight:bold; background-color:gray; color:white;">
                <c:if test="${FeatureCount>MAX_DEFAULT_OPEN}">
                    Your list is big and there could be issues with the display:
                    click to see/hide the expression map<img src="images/undisclosed.gif" id="oc">
                </c:if>
                <c:if test="${FeatureCount<=MAX_DEFAULT_OPEN}">
                    Click to see/hide the expression map<img src="images/disclosed.gif" id="oc">
                </c:if>
            </div>
        </html:link>

        <div id="heatmapGraph" style="display:block">
            <div style="width:500px; margin:5px 0px 5px 100px;">
                
                <c:if test="${FeatureCount>MAX_CLUSTER}">
                    <p>
                        Please note that clustering functions are not available for lists with more than ${MAX_CLUSTER} transcripts.
                    </p>
                </c:if>
                
                <c:if test="${ConditionCount>MAX_CLUSTER}">
                    <p>
                        Please note that clustering functions are not available for more than ${MAX_CLUSTER} tissue samples.
                    </p>
                </c:if>
            
                <div style="width:350px; margin:auto; text-align:center; padding:3px; border:1px solid gray; background-color:#eee;">
                    <c:if test="${FeatureCount>4 && FeatureCount<=MAX_CLUSTER}">
                        Expression K-means:
                        <select id="smps-km">
                            <option value="2" selected>2</option>
                            <c:forEach begin="3" end="${FeatureCount}" var="val">
                                <option value="${val}">${val}</option>
                            </c:forEach>
                        </select>
                    </c:if>
                    <c:if test="${ConditionCount>4 && ConditionCount<=MAX_CLUSTER}">
                        Tissue K-means:
                        <select id="vars-km">
                            <option value="2" selected>2</option>
                            <c:forEach begin="3" end="${ConditionCount}" var="val">
                                <option value="${val}">${val}</option>
                            </c:forEach>
                        </select>
                    </c:if>
                </div>
                
            </div>
            
            <canvas id="canvasx" width="${WEB_PROPERTIES['heatmap.width']}" height="${WEB_PROPERTIES['heatmap.height']}"></canvas>
            
        </div>
    </div>
        
    <div id="description_div" style="clear:both; padding-left:10px; font-weight:bold; background-color:gray; color:white;">
        More information <img src="images/undisclosed.gif" id="co">
    </div>
    <div id="description" style="padding:5px">${WEB_PROPERTIES['heatmap.description']}</div>

</div>

<script type="text/javascript">

 var feature_count = parseInt(${FeatureCount});
 var condition_count = parseInt(${ConditionCount});
 var max_cluster = ${MAX_CLUSTER};
 var max_map = ${MAX_MAP};
 var max_default_open = ${MAX_DEFAULT_OPEN};

 jQuery(document).ready(
     function () {
         if (feature_count>max_default_open) {
             jQuery("#heatmapGraph").hide();
         } else {
             jQuery("#heatmapGraph").show();
         }
         jQuery("#bro").click(
             function () {
                 if (jQuery("#heatmapGraph").is(":hidden")) {
                     jQuery("#oc").attr("src", "images/disclosed.gif");
                 } else {
                     jQuery("#oc").attr("src", "images/undisclosed.gif");
                 }
                 jQuery("#heatmapGraph").toggle("slow");
             }
         );
     }
 );

 if (${fn:length(expressionValueJSON)}<10) {
     
     jQuery('#heatmap_div').remove();
     jQuery('#expression_div').html('<i>Expression values are not available</i>');

 } else {

     if (feature_count>max_map) {
         jQuery('#heatmap_div').remove();
         jQuery('#expression_div').html('<i>Too many elements: please select a subset to see the heat maps.</i>');
     }

     jQuery("#description").hide();

     jQuery("#description_div").click(
         function () {
             if (jQuery("#description").is(":hidden")) {
                 jQuery("#co").attr("src", "images/disclosed.gif");
             } else {
                 jQuery("#co").attr("src", "images/undisclosed.gif");
             }
             jQuery("#description").toggle("slow");
         }
     );


     var hm = new CanvasXpress("canvasx",
                               ${expressionValueJSON},
                               {
                                   "graphType": "Heatmap",
                                   "title": "${WEB_PROPERTIES['heatmap.title']} : "+feature_count+" transcripts",
                                   "xAxisTitle": "",
                                   "fontName": "Arial",
                                   "smpLabelScaleFontFactor": ${WEB_PROPERTIES['heatmap.smpLabelScaleFontFactor']},
                                   "smpLabelFontStyle": "${WEB_PROPERTIES['heatmap.smpLabelFontStyle']}",
                                   "smpLabelFontColor": "${WEB_PROPERTIES['heatmap.smpLabelFontColor']}",
                                   "varLabelScaleFontFactor": ${WEB_PROPERTIES['heatmap.varLabelScaleFontFactor']},
                                   "varLabelFontStyle": "${WEB_PROPERTIES['heatmap.varLabelFontStyle']}",
                                   "varLabelFontColor": "${WEB_PROPERTIES['heatmap.varLabelFontColor']}",
                                   "varLabelRotate": ${WEB_PROPERTIES['heatmap.varLabelRotate']},
                                   "colorSpectrum": [ ${WEB_PROPERTIES['heatmap.colorSpectrum']} ],
                                   "colorSpectrumBreaks": [ ${WEB_PROPERTIES['heatmap.colorSpectrumBreaks']} ],
                                   "isLogData": ${WEB_PROPERTIES['heatmap.isLogData']},
                                   "heatmapCellBox": true,
                                   "showHeatMapIndicator": true,
                                   "heatmapIndicatorPosition": "top",
                                   "heatmapIndicatorHistogram": ${WEB_PROPERTIES['heatmap.heatmapIndicatorHistogram']},
                                   "heatmapIndicatorHeight": ${WEB_PROPERTIES['heatmap.heatmapIndicatorHeight']},
                                   "heatmapIndicatorWidth": ${WEB_PROPERTIES['heatmap.heatmapIndicatorWidth']},
                                   "showSmpDendrogram": false,
                                   "showVarDendrogram": false,
                                   "kmeansSmpClusters": 2,
                                   "kmeansVarClusters": 2,
                                   "samplesClustered": false,
                                   "samplesKmeaned": false,
                                   "variablesClustered": false,
                                   "variablesKmeaned": false
                               },
                               {
                                   click: function(o) {
                                       var featureId = o.y.smps;
                                       var condition = o.y.vars;
                                       var query = '<query name="" model="genomic" view="ExpressionValue.mRNA.primaryIdentifier ExpressionValue.expressionSample.primaryIdentifier ExpressionValue.value" sortOrder="ExpressionValue.expressionSample.num asc" constraintLogic="A and B"><constraint path="ExpressionValue.mRNA" code="B" op="LOOKUP" value="'+featureId+'" extraValue=""/><constraint path="ExpressionValue.expressionSample" code="A" op="LOOKUP" value="'+condition+'"/></query>';
                                       var encodedQuery = encodeURIComponent(query);
                                       encodedQuery = encodedQuery.replace("%20", "+");
                                       window.open("/${WEB_PROPERTIES['webapp.path']}/loadQuery.do?skipBuilder=true&query="+encodedQuery+"%0A++++++++++++&trail=|query&method=xml");
                                   }
                               }
     );

     // show k-means on features if enough features and less than max_cluster; else disable
     if (feature_count>4 && feature_count<=max_cluster) {
         hm.kmeansSamples(true);
     } else {
         jQuery("#smps-km").attr('disabled', true);
     }

     // show k-means on conditions if enough and less than max_cluster; else disable
     if (condition_count>4 && condition_count<=max_cluster) {
         hm.kmeansVariables(true);
     } else {
         jQuery("#vars-km").attr('disabled', true);
     }

     // respond to smps-km change (features)
     jQuery("#smps-km").change(
         function() {
             hm.kmeansSmpClusters = parseInt(this.value);
             hm.kmeansSamples(true);
         }
     );

     // respond to vars-km change (conditions)
     jQuery("#vars-km").change(
         function() {
             hm.kmeansVarClusters = parseInt(this.value);
             hm.kmeansVariables(true);
         }
     );

 }

</script>
<!-- /heatMap.jsp -->
