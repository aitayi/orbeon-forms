/**
 *  Copyright (C) 2009 Orbeon, Inc.
 *
 *  This program is free software; you can redistribute it and/or modify it under the terms of the
 *  GNU Lesser General Public License as published by the Free Software Foundation; either version
 *  2.1 of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 *  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *  See the GNU Lesser General Public License for more details.
 *
 *  The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
 */
package org.orbeon.oxf.xforms.itemset;

import org.orbeon.oxf.common.ValidationException;
import org.orbeon.oxf.pipeline.api.PipelineContext;
import org.orbeon.oxf.xml.dom4j.LocationData;
import org.orbeon.saxon.om.FastStringBuffer;
import org.xml.sax.ContentHandler;
import org.xml.sax.SAXException;

import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;

/**
  * Represents an itemset.
 */
public class Itemset implements ItemContainer {

    private final List<Item> children = new ArrayList<Item>();

    public void addChildItem(Item childItem) {
        childItem.setLevel(0);
        children.add(childItem);
        childItem.setParent(this);
    }

    public List<Item> getChildren() {
        return children;
    }

    public ItemContainer getParent() {
        return null;
    }

    public void pruneNonRelevantChildren() {
        if (hasChildren()) {
            // Depth-first search
            for (Iterator<Item> i = children.iterator(); i.hasNext();) {
                final Item item = i.next();
                item.pruneNonRelevantChildren();
                if (!item.hasChildren() && item.getValue() == null) {
                    // Leaf item with null value must be pruned
                    i.remove();
                }
            }
        }
    }

    public boolean hasChildren() {
        return children.size() > 0;
    }

    /**
     * Visit the entire itemset.
     *
     * @param contentHandler        optional ContentHandler object, or null if not used
     * @param listener              TreeListener to call back
     */
    public void visit(ContentHandler contentHandler, ItemsetListener listener) throws SAXException {
        listener.startLevel(contentHandler, true);
        boolean first = true;
        for (Item item: children) {
            listener.startItem(contentHandler, item, first);
            item.visit(contentHandler, listener);
            listener.endItem(contentHandler);
            first = false;
        }
        listener.endLevel(contentHandler);
    }

    /**
     * Return the list of items as a JSON tree.
     *
     * @param controlValue  current value of the control (to determine selected item) or null
     * @param many          whether multiple selection is allowed (to determine selected item)
     * @return              String representing a JSON tree
     */
    public String getJSONTreeInfo(final PipelineContext pipelineContext, final String controlValue, final boolean many, LocationData locationData) {
        // Produce a JSON fragment with hierachical information
        if (getChildren().size() > 0) {
            final FastStringBuffer sb = new FastStringBuffer(100);
            sb.append("[");
            try {
                visit(null, new ItemsetListener() {
                    public void startLevel(ContentHandler contentHandler, boolean topLevel) throws SAXException {
                    }

                    public void endLevel(ContentHandler contentHandler) throws SAXException {
                    }

                    public void startItem(ContentHandler contentHandler, Item item, boolean first) throws SAXException {
                        final String value = item.getValue();

                        if (!first)
                            sb.append(',');
                        sb.append("[");

                        sb.append('"');
                        sb.append(item.getExternalJSLabel());
                        sb.append("\",\"");
                        sb.append(item.getExternalJSValue(pipelineContext));
                        sb.append('\"');

                        if (controlValue != null) {
                            // We allow the value to be null when this method is used just to produce the structure of the tree without selection
                            sb.append(',');
                            sb.append(Boolean.toString((value != null) && XFormsItemUtils.isSelected(many, controlValue, value)));
                        }
                    }

                    public void endItem(ContentHandler contentHandler) throws SAXException {
                        sb.append("]");
                    }
                });
            } catch (SAXException e) {
                throw new ValidationException("Error while creating itemset tree", e, locationData);
            }
            sb.append("]");

            return sb.toString();

        } else {
            // Safer to return an empty array rather than en empty string
            return "[]";
        }
    }

    /**
     * Return the entire itemset as a flat list.
     *
     * @return  list of items
     */
    public List<Item> toList() {
        final List<Item> result = new ArrayList<Item>();
        for (Item item: children) {
            item.addToList(result);
        }
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof Itemset))
            return false;

        final Itemset other = (Itemset) obj;

        if (children.size() != other.children.size())
            return false;

        final Iterator<Item> otherIterator = other.children.iterator();
        for (Item item: children) {
            final Item otherItem = otherIterator.next();
            if (!item.equals(otherItem))
                return false;
        }

        return true;
    }
}
