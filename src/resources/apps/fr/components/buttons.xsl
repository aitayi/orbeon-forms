<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright (C) 2008 Orbeon, Inc.

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<xsl:stylesheet version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xforms="http://www.w3.org/2002/xforms"
        xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"
        xmlns:exforms="http://www.exforms.org/exf/1-0"
        xmlns:fr="http://orbeon.org/oxf/xml/form-runner"
        xmlns:xhtml="http://www.w3.org/1999/xhtml"
        xmlns:xi="http://www.w3.org/2001/XInclude"
        xmlns:xxi="http://orbeon.org/oxf/xml/xinclude"
        xmlns:ev="http://www.w3.org/2001/xml-events"
        xmlns:PipelineFunctionLibrary="org.orbeon.oxf.processor.pipeline.PipelineFunctionLibrary">

    <xsl:template match="fr:refresh-button">
        <!-- Display a "refresh" button only in noscript mode -->
        <xforms:trigger ref=".[property('xxforms:noscript')]">
            <xforms:label>
                <xhtml:img width="11" height="16" src="/apps/fr/style/images/silk/arrow_refresh.png" alt=""/>
                <xforms:output value="$fr-resources/summary/labels/refresh"/>
            </xforms:label>
            <xforms:action ev:event="DOMActivate">
                <!-- NOP -->
            </xforms:action>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:back-button">
        <!-- Display a "close" button as it's clearer for users -->
        <xforms:trigger>
            <xforms:label>
                <xhtml:img width="11" height="16" src="/apps/fr/style/close.gif" alt=""/>
                <xforms:output value="$fr-resources/detail/labels/close"/>
            </xforms:label>
            <xforms:action ev:event="DOMActivate">
                <xforms:dispatch target="fr-persistence-model" name="fr-goto-summary"/>
            </xforms:action>
        </xforms:trigger>
        <xsl:if test="false()">
            <!-- Trigger shown to go back if the data is dirty -->
            <xforms:trigger ref="instance('fr-persistence-instance')[data-status = 'dirty']">
                <xforms:label>
                    <xhtml:img width="16" height="16" src="/apps/fr/style/images/silk/house.png" alt=""/>
                    <xhtml:span><xforms:output value="$fr-resources/detail/labels/discard"/></xhtml:span>
                </xforms:label>
                <xforms:action ev:event="DOMActivate">
                    <xforms:dispatch target="fr-persistence-model" name="fr-goto-summary"/>
                </xforms:action>
            </xforms:trigger>
            <!-- Trigger shown to go back if the data is clean -->
            <xforms:trigger ref="instance('fr-persistence-instance')[data-status = 'clean']">
                <xforms:label>
                    <xhtml:img width="16" height="16" src="/apps/fr/style/images/silk/house.png" alt=""/>
                    <xhtml:span><xforms:output value="$fr-resources/detail/labels/return"/></xhtml:span>
                </xforms:label>
                <xforms:action ev:event="DOMActivate">
                    <xforms:dispatch target="fr-persistence-model" name="fr-goto-summary"/>
                </xforms:action>
            </xforms:trigger>
        </xsl:if>
    </xsl:template>

    <xsl:template match="fr:clear-button">
        <xforms:trigger>
            <xforms:label><xhtml:img width="16" height="16" src="/apps/fr/style/clear.gif" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/clear"/></xhtml:span>
            </xforms:label>
            <xforms:action ev:event="DOMActivate">
                <xforms:setvalue ref="xxforms:instance('errors-state')/submitted">true</xforms:setvalue>
                <xxforms:show dialog="fr-clear-confirm-dialog"/>
            </xforms:action>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:print-button">
        <xforms:trigger>
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/images/silk/printer.png" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/print"/></xhtml:span>
            </xforms:label>
            <xforms:action ev:event="DOMActivate">
                <xforms:send submission="fr-print-submission"/>
            </xforms:action>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:pdf-button">
        <!-- Show button only if there is no PDF template -->
        <xforms:trigger model="fr-persistence-model"
                        ref=".[instance('fr-source-form-instance')/xhtml:head/xforms:model/xforms:instance[@id = 'fr-form-attachments']/*/pdf = '']">
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/pdf.png" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/print-pdf"/></xhtml:span>
            </xforms:label>
            <xforms:action ev:event="DOMActivate">
                <xforms:send submission="fr-pdf-submission"/>
            </xforms:action>
        </xforms:trigger>
        <!-- Show button only if there is a PDF template -->
        <xforms:trigger model="fr-persistence-model"
                        ref=".[instance('fr-source-form-instance')/xhtml:head/xforms:model/xforms:instance[@id = 'fr-form-attachments']/*/pdf != '']">
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/pdf.png" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/print-pdf"/></xhtml:span>
            </xforms:label>
            <xforms:action ev:event="DOMActivate">
                <xforms:send submission="fr-pdf-template-submission"/>
            </xforms:action>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:take-offline">
        <xforms:trigger id="take-offline-button" ref="if (xxforms:instance('fr-offline-instance')/is-online = 'true') then . else ()">
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/take-offline.gif" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/offline"/></xhtml:span>
            </xforms:label>
            <xxforms:offline ev:event="DOMActivate"/>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:take-online">
        <xforms:trigger id="take-online-button" ref="if (xxforms:instance('fr-offline-instance')/is-online = 'false') then . else ()">
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/take-online.gif" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/online"/></xhtml:span>
            </xforms:label>
            <xxforms:online ev:event="DOMActivate"/>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:save-offline">
        <xforms:trigger id="save-offline-button" ref="if (xxforms:instance('fr-offline-instance')/is-online = 'false') then . else ()">
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/save.gif" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/save-offline"/></xhtml:span>
            </xforms:label>
            <xxforms:offline-save ev:event="DOMActivate"/>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:save-locally-button">
        <xforms:trigger id="save-locally-button">
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/images/silk/disk.png" alt=""/>
                <xforms:output value="$fr-resources/detail/labels/save-locally"/>
            </xforms:label>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:save-button">
        <xforms:trigger ref="instance('fr-triggers-instance')/save" xxforms:modal="true" id="fr-save-button">
            <xforms:label>
                <xhtml:img width="16" height="16" src="/apps/fr/style/images/silk/database_save.png" alt=""/>
                <xhtml:span><xforms:output value="$fr-resources/detail/labels/save-document"/></xhtml:span>
            </xforms:label>
        </xforms:trigger>
    </xsl:template>

    <xsl:template match="fr:close-button">
        <!-- Don't show this button in noscript mode -->
        <xforms:trigger ref=".[not(property('xxforms:noscript'))]">
            <xforms:label>
                <xhtml:img width="11" height="16" src="/apps/fr/style/close.gif" alt=""/>
                <xforms:output value="$fr-resources/detail/labels/close"/>
            </xforms:label>
            <xforms:action ev:event="DOMActivate">
                <xxforms:script>window.close();</xxforms:script>
            </xforms:action>
        </xforms:trigger>
    </xsl:template>

</xsl:stylesheet>