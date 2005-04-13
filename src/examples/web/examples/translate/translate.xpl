<!--
    Copyright (C) 2004 Orbeon, Inc.

    This program is free software; you can redistribute it and/or modify it under the terms of the
    GNU Lesser General Public License as published by the Free Software Foundation; either version
    2.1 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
    without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
    See the GNU Lesser General Public License for more details.

    The full text of the license is available at http://www.gnu.org/copyleft/lesser.html
-->
<p:config xmlns:p="http://www.orbeon.com/oxf/pipeline"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:oxf="http://www.orbeon.com/oxf/processors">
    
    <p:processor name="oxf:request">
        <p:input name="config">
            <config>
                <include>/request/parameters/parameter[name = 'text']/value</include>
            </config>
        </p:input>
        <p:output name="data" id="text"/>
    </p:processor>

    <p:processor name="oxf:xslt">
        <p:input name="data" href="#text"/>
        <p:input name="config">
            <config xsl:version="2.0">
                <url>http://translate.google.com/translate_t?text=<xsl:value-of select="escape-uri(/*, true())"/>&amp;langpair=en|fr</url>
                <content-type>text/html</content-type>
                <header>
                    <name>User-Agent</name>
                    <value>Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.4.1) Gecko/20031008</value>
                </header>
            </config>
        </p:input>
        <p:output name="data" id="google-request"/>
    </p:processor>

    <p:processor name="oxf:url-generator">
        <p:input name="config" href="#google-request"/>
        <p:output name="data" id="google-translation"/>
    </p:processor>

    <p:processor name="oxf:xml-serializer">
        <p:input name="config"><config/></p:input>
        <p:input name="data" href="aggregate('r', #google-translation#xpointer(string(//textarea[@name = 'q'])))" debug="result"/>
    </p:processor>

</p:config>
