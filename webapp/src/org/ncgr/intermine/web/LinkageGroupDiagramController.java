package org.ncgr.intermine.web;

/*
 * Copyright (C) 2002-2014 FlyMine
 *
 * This code may be freely distributed and modified under the
 * terms of the GNU Lesser General Public Licence.  This should
 * be distributed with the code.  See the LICENSE file for more
 * information or http://www.gnu.org/copyleft/lesser.html.
 *
 */

import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.tiles.ComponentContext;
import org.apache.struts.tiles.actions.TilesAction;

import org.intermine.api.InterMineAPI;
import org.intermine.api.profile.InterMineBag;
import org.intermine.api.profile.Profile;
import org.intermine.api.query.PathQueryExecutor;
import org.intermine.api.results.ExportResultsIterator;
import org.intermine.api.results.ResultElement;
import org.intermine.metadata.Model;
import org.intermine.objectstore.ObjectStore;
import org.intermine.objectstore.ObjectStoreException;
import org.intermine.pathquery.Constraints;
import org.intermine.pathquery.OrderDirection;
import org.intermine.pathquery.PathQuery;
import org.intermine.web.logic.session.SessionMethods;

import org.json.JSONObject;

/**
 * Class that generates linkage group diagram JSON data for a list of linkage groups.
 *
 * @author Sam Hokin
 */
public class LinkageGroupDiagramController extends TilesAction {
    
    protected static final Logger LOG = Logger.getLogger(LinkageGroupDiagramController.class);

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ComponentContext context, ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        
        // standard stuff that's in any controller
        HttpSession session = request.getSession();
        final InterMineAPI im = SessionMethods.getInterMineAPI(session);
        ObjectStore os = im.getObjectStore();
        InterMineBag bag = (InterMineBag) request.getAttribute("bag");
        Model model = im.getModel();
        Profile profile = SessionMethods.getProfile(session);
        PathQueryExecutor executor = im.getPathQueryExecutor(profile);

        // check that we've got a list of linkage groups and abort if not
        String expressionType = bag.getType();
        if (!expressionType.equals("LinkageGroup")) {
            LOG.error("called on a bag of type:"+expressionType);
            return null;
        }

        // get the linkage groups and find the maximum length
        double maxLGLength = 0.0;
        Map<Integer,Double> lgMap = new LinkedHashMap<Integer,Double>();
        PathQuery lgQuery = getLinkageGroupQuery(model, bag);
        ExportResultsIterator lgResult = getResults(executor, lgQuery);
        while (lgResult.hasNext()) {
            List<ResultElement> row = lgResult.next();
            Integer number = (Integer) row.get(0).getField();
            Double length = (Double) row.get(1).getField();
            lgMap.put(number, length);
            if ((double)length > maxLGLength) maxLGLength = (double)length;
        }

        // get the genetic markers per linkage group
        Map<Integer, Map<String,Double>> markerMap = new LinkedHashMap<Integer, Map<String,Double>>();
        for (Integer lg : lgMap.keySet()) {
            PathQuery markerQuery = getGeneticMarkerQuery(model, lg);
            ExportResultsIterator markerResult = getResults(executor, markerQuery);
            Map<String,Double> markers = new LinkedHashMap<String,Double>();
            while (markerResult.hasNext()) {
                List<ResultElement> row = markerResult.next();
                String primaryIdentifier = (String) row.get(0).getField();
                Double position = (Double) row.get(1).getField();
                markers.put(primaryIdentifier, position);
            }
            markerMap.put(lg, markers);
        }

        // get the QTLs per linkage group
        Map<Integer, Map<String,Double[]>> qtlMap = new LinkedHashMap<Integer, Map<String,Double[]>>();
        for (Integer lg : lgMap.keySet()) {
            PathQuery qtlQuery = getQTLQuery(model, lg);
            ExportResultsIterator qtlResult = getResults(executor, qtlQuery);
            Map<String,Double[]> qtls = new LinkedHashMap<String,Double[]>();
            while (qtlResult.hasNext()) {
                List<ResultElement> row = qtlResult.next();
                String primaryIdentifier = (String) row.get(0).getField();
                Double[] span = new Double[2];
                span[0] = (Double) row.get(1).getField();
                span[1] = (Double) row.get(2).getField();
                qtls.put(primaryIdentifier, span);
            }
            qtlMap.put(lg, qtls);
        }

        // JSON data - non-labeled array - order matters!
        List<Object> trackData = new LinkedList<Object>();
        for (Integer lg : lgMap.keySet()) {
            
            // LINKAGE GROUP TRACK
            Map<String,Object> lgTrack = new LinkedHashMap<String,Object>();
            lgTrack.put("type", "box");
            // linkage group track data array
            List<Object> lgDataArray = new LinkedList<Object>();
            // the single data item
            Map<String,Object> lgData = new LinkedHashMap<String,Object>();
            lgData.put("id", lg);
            lgData.put("fill", "purple");
            lgData.put("outline", "black");
            // linkage group box positions = array of one pair
            List<Object> lgPositionsArray = new LinkedList<Object>();
            double[] length = new double[2];
            length[0] = 0.0;
            length[1] = (double) lgMap.get(lg);
            lgPositionsArray.add(length);
            lgData.put("data", lgPositionsArray);
            lgDataArray.add(lgData);
            lgTrack.put("data", lgDataArray);
            trackData.add(lgTrack);

            // MARKERS TRACK
            Map<String,Object> markersTrack = new LinkedHashMap<String,Object>();
            markersTrack.put("type", "triangle");
            // markers track data array
            List<Object> markersDataArray = new LinkedList<Object>();
            Map<String,Double> markers = markerMap.get(lg);
            for (String markerPI : markers.keySet()) {
                Map<String,Object> markerData = new LinkedHashMap<String,Object>();
                markerData.put("id", markerPI);
                markerData.put("fill", "darkred");
                markerData.put("outline", "black");
                markerData.put("offset", markers.get(markerPI));
                markersDataArray.add(markerData);
            }
            markersTrack.put("data", markersDataArray);
            trackData.add(markersTrack);
            
            // QTLS TRACK
            Map<String,Object> qtlsTrack = new LinkedHashMap<String,Object>();
            qtlsTrack.put("type", "box");
            // QTLs track data array
            List<Object> qtlsDataArray = new LinkedList<Object>();
            Map<String,Double[]> qtls = qtlMap.get(lg);
            for (String qtlPI : qtls.keySet()) {
                Map<String,Object> qtlData = new LinkedHashMap<String,Object>();
                qtlData.put("id", qtlPI);
                qtlData.put("fill", "yellow");
                qtlData.put("outline", "black");
                // QTL box positions = array of one pair
                List<Object> qtlPositionsArray = new LinkedList<Object>();
                Double[] span = qtls.get(qtlPI);
                double[] coords = new double[2];
                coords[0] = (double) span[0];
                coords[1] = (double) span[1];
                qtlPositionsArray.add(coords);
                qtlData.put("data", qtlPositionsArray);
                qtlsDataArray.add(qtlData);
            }
            qtlsTrack.put("data", qtlsDataArray);
            trackData.add(qtlsTrack);
                        
        }

        // output scalar vars
        request.setAttribute("tracksCount", lgMap.size());
        request.setAttribute("maxLGLength", maxLGLength);

        // entire thing is in a single tracks JSON array
        Map<String,Object> tracks = new LinkedHashMap<String,Object>();
        tracks.put("tracks", trackData);
        request.setAttribute("tracksJSON", new JSONObject(tracks).toString());

        return null;
    }

    /**
     * To encode '(' and ')', which canvasExpress uses as separator in the cluster tree building
     * also ':' that gives problem in the clustering
     * @param symbol
     * @return a fixed symbol
     */
    String fixSymbol(String symbol) {
        symbol = symbol.replace("(", "%28");
        symbol = symbol.replace(")", "%29");
        symbol = symbol.replace(":", "%3A");
        return symbol;
    }

    /**
     * Create a path query to retrieve linkage groups from a bag.
     *
     * @param model the model
     * @param bag   the bag of query linkage groups
     * @return the path query
     */
    PathQuery getLinkageGroupQuery(Model model, InterMineBag bag) {
        PathQuery query = new PathQuery(model);
        query.addViews(
                       "LinkageGroup.number",
                       "LinkageGroup.length"
                       );
        query.addConstraint(Constraints.in("LinkageGroup", bag.getName()));
        query.addOrderBy("LinkageGroup.number", OrderDirection.ASC);
        return query;
    }

    /**
     * Create a path query to retrieve genetic markers associated with a given linkage group.
     *
     * @param model the model
     * @param lg    the linkage group number
     * @return the path query
     */
    PathQuery getGeneticMarkerQuery(Model model, Integer lg) {
        PathQuery query = new PathQuery(model);
        query.addViews(
                       "GeneticMarker.primaryIdentifier",
                       "GeneticMarker.linkageGroupPositions.position"
                       );
        query.addConstraint(Constraints.eq("GeneticMarker.linkageGroupPositions.linkageGroup.number", String.valueOf(lg)));
        query.addOrderBy("GeneticMarker.linkageGroupPositions.position", OrderDirection.ASC);
        return query;
    }

    /**
     * Create a path query to retrieve QTLs associated with a given linkage group.
     *
     * @param model the model
     * @param lg    the linkage group number
     * @return the path query
     */
    PathQuery getQTLQuery(Model model, Integer lg) {
        PathQuery query = new PathQuery(model);
        query.addViews(
                       "QTL.primaryIdentifier",
                       "QTL.linkageGroupRanges.begin",
                       "QTL.linkageGroupRanges.end"
                       );
        query.addConstraint(Constraints.eq("QTL.linkageGroupRanges.linkageGroup.number", String.valueOf(lg)));
        query.addOrderBy("QTL.linkageGroupRanges.begin", OrderDirection.ASC);
        return query;
    }

    /**
     * Execute a query, returning an ExportResultsIterator
     *
     * @param executor the PathQueryExecutor
     * @param query the PathQuery
     * @return the ExportResultsIterator
     */
    ExportResultsIterator getResults(PathQueryExecutor executor, PathQuery query) {
        ExportResultsIterator result;
        try {
            result = executor.execute(query);
        } catch (ObjectStoreException e) {
            LOG.error("Error retrieving query results: "+e.getMessage());
            throw new RuntimeException("Error retrieving query results.", e);
        }
        return result;
    }


}
