package org.intermine.bio.web.displayer;

/*
 * Copyright (C) 2002-2016 FlyMine
 *
 * This code may be freely distributed and modified under the
 * terms of the GNU Lesser General Public Licence.  This should
 * be distributed with the code.  See the LICENSE file for more
 * information or http://www.gnu.org/copyleft/lesser.html.
 *
 */

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.intermine.api.beans.ObjectDetails;
import org.intermine.api.beans.PartnerLink;
import org.intermine.api.mines.Mine;
import org.intermine.api.mines.ObjectRequest;
import org.intermine.pathquery.Constraints;
import org.intermine.pathquery.OrderDirection;
import org.intermine.pathquery.PathQuery;
import org.intermine.metadata.Util;
import org.intermine.web.displayer.InterMineLinkGenerator;
import org.intermine.webservice.server.core.Predicate;

/**
 * Helper class for intermine links generated on report and lists pages
 *
 * @author Julie Sullivan
 */
public final class FriendlyMineLinkGenerator implements InterMineLinkGenerator {

    private class MustBeIn implements Predicate<List<Object>> {

        private final Set<String> collection;

        MustBeIn(Set<String> coll) {
            this.collection = coll;
        }

        @Override
        public Boolean call(List<Object> row) {
            return (row != null) && collection.contains(row.get(2));
        }

    }

    private static final Logger LOG = Logger.getLogger(FriendlyMineLinkGenerator.class);

    /**
     * Constructor
     */
    public FriendlyMineLinkGenerator() {
        super();
    }

    @Override
    public Collection<PartnerLink> getLinks(Mine thisMine, Mine mine, ObjectRequest req) {

        String organismShortName = req.getDomain();
        String primaryIdentifier = req.getIdentifier();

        if (StringUtils.isEmpty(organismShortName) || StringUtils.isEmpty(primaryIdentifier)) {
            return Collections.emptySet();
        }

        // FIXME temporarily ignoring lists with more than one organism
        if (organismShortName.contains(",")) {
            return Collections.emptySet();
        }

        // Wrapping up in a sub object means we don't need a messy web of static calls.
        LinkFetcher fetcher = new LinkFetcher(thisMine, mine);
        return fetcher.fetch(req);
    }

    private class LinkFetcher {

        private final Mine thisMine, thatMine;
        private MustBeIn predicate;

        LinkFetcher(Mine thisMine, Mine mine) {
            this.thisMine = thisMine; // The local mine, where the idents come from
            this.thatMine = mine;     // The remote mine, where we want to find things.
            this.predicate = new MustBeIn(thatMine.getDefaultValues());
        }

        Collection<PartnerLink> fetch(ObjectRequest req) {

            // SPECIAL CASE: query the local mine for genes associated with this genetic marker!
            LOG.info("Executing search for associated genes on friendly mines...");
            Map<String, Set<ObjectDetails>> genes = localAssociatedGeneStrategy(req);
            if (genes==null) LOG.info("No genes returned"); else LOG.info("Returned genes.size()="+genes.size());
            
            return toLinks(genes);
        }

        /**
         * Look for associated genes in the local mine.
         * @param req The definition of the thing we are looking for.
         * @return A mapping from organisms to groups of identifiers.
         */
        private Map<String, Set<ObjectDetails>> localAssociatedGeneStrategy(ObjectRequest req) {
            PathQuery q = getAssociatedGeneQuery(thisMine, req);
            return runQuery(thisMine, q);
        }

        /**
         * Find genes associated with the current genetic marker
         */
        private PathQuery getAssociatedGeneQuery(Mine mine, ObjectRequest req) {
            // DEBUG START
            LOG.info("ObjectRequest.getIdentifier()="+req.getIdentifier());
            LOG.info("ObjectRequest.getDomain()="+req.getDomain());
            // DEBUG END
            PathQuery q = new PathQuery(mine.getModel());
            q.addViews(
                       "GeneticMarker.associatedGenes.primaryIdentifier",
                       "GeneticMarker.associatedGenes.symbol",
                       "GeneticMarker.associatedGenes.organism.shortName"
                       );
            q.addOrderBy("GeneticMarker.associatedGenes.organism.shortName", OrderDirection.ASC);
            q.addConstraint(Constraints.lookup("GeneticMarker", req.getIdentifier(), req.getDomain()));
            return q;
        }

        /**
         * Processes the results of queries which have three views: Gene.primaryIdentifier, Gene.symbol, Organism.shortName
         * @param mine The data source
         * @param q The query
         * @return
         */
        private Map<String, Set<ObjectDetails>> runQuery(Mine mine, PathQuery q) {
            Map<String, Set<ObjectDetails>> retval = new HashMap<String, Set<ObjectDetails>>();

            List<List<Object>> results = mine.getRows(q);
            
            for (List<Object> row: results) {
                if (!predicate.call(row)) {
                    continue;
                }
                ObjectDetails details = new ObjectDetails();
                details.setType("Gene");
                if (row.get(1) != null) {
                    details.setName((String) row.get(1));
                }
                if (row.get(0) != null) {
                    details.setIdentifier((String) row.get(0));
                }
                
                Util.addToSetMap(retval, String.valueOf(row.get(2)), details);
            }
            return retval;
        }

        /*
         * Turn the orthologueMapping into a collection of PartnerLinks
         */
        private Collection<PartnerLink> toLinks(Map<String, Set<ObjectDetails>> orthologueMapping) {
            Set<PartnerLink> retVal = new HashSet<PartnerLink>();
            for (Entry<String, Set<ObjectDetails>> entry : orthologueMapping.entrySet()) {
                String organismName = entry.getKey();
                Set<ObjectDetails> genes = entry.getValue();
                PartnerLink link = new PartnerLink();
                link.setDomain(organismName);
                link.setObjects(genes);
                retVal.add(link);
            }
            return retVal;
        }

        /*****************************************************************************************
                    GENES
         *****************************************************************************************/

        private PathQuery getGeneQuery(Mine mine, ObjectRequest req) {
            PathQuery q = new PathQuery(mine.getModel());
            q.addViews("Gene.primaryIdentifier", "Gene.symbol", "Gene.organism.shortName");
            q.addOrderBy("Gene.symbol", OrderDirection.ASC);
            q.addConstraint(Constraints.lookup("Gene", req.getIdentifier(), req.getDomain()));
            return q;
        }

    }


}
