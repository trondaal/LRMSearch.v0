<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:frbrizer="http://idi.ntnu.no/frbrizer/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">
   <xsl:param name="debug" as="xs:boolean" select="false()"/>
   <xsl:param name="include_MARC001_in_entityrecord"
              as="xs:boolean"
              select="false()"/>
   <xsl:param name="include_MARC001_in_controlfield"
              as="xs:boolean"
              select="false()"/>
   <xsl:param name="include_MARC001_in_subfield" as="xs:boolean" select="false()"/>
   <xsl:param name="include_MARC001_in_relationships"
              as="xs:boolean"
              select="false()"/>
   <xsl:param name="include_anchorvalues" as="xs:boolean" select="false()"/>
   <xsl:param name="include_templateinfo" as="xs:boolean" select="false()"/>
   <xsl:param name="include_sourceinfo" as="xs:boolean" select="false()"/>
   <xsl:param name="include_keyvalues" as="xs:boolean" select="false()"/>
   <xsl:param name="include_internal_key" as="xs:boolean" select="false()"/>
   <xsl:param name="include_counters" as="xs:boolean" select="false()"/>
   <xsl:param name="merge" as="xs:boolean" select="true()"/>
   <xsl:param name="rdf" as="xs:boolean" select="true()"/>
   <xsl:param name="ignore_indicators_in_merge" as="xs:boolean" select="true()"/>
   <xsl:param name="include_id_as_element" as="xs:boolean" select="false()"/>
   <xsl:param name="include_missing_reverse_relationships"
              as="xs:boolean"
              select="true()"/>
   <xsl:param name="userdefined" as="xs:boolean" select="false()"/>
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
   <xsl:template match="/*:collection">
      <xsl:variable name="entity-collection">
         <xsl:copy>
            <xsl:namespace name="xml" select="'http://www.w3.org/XML/1998/namespace'"/>
            <xsl:namespace name="rdac" select="'http://rdaregistry.info/Elements/c/'"/>
            <xsl:namespace name="rdaa" select="'http://rdaregistry.info/Elements/a/'"/>
            <xsl:namespace name="rdaw" select="'http://rdaregistry.info/Elements/w/'"/>
            <xsl:namespace name="rdae" select="'http://rdaregistry.info/Elements/e/'"/>
            <xsl:namespace name="rdam" select="'http://rdaregistry.info/Elements/m/'"/>
            <xsl:namespace name="rdfs" select="'http://www.w3.org/2000/01/rdf-schema#'"/>
            <xsl:namespace name="rdaco"
                           select="'http://rdaregistry.info/termList/RDAContentType/'"/>
            <xsl:namespace name="rdact"
                           select="'http://rdaregistry.info/termList/RDACarrierType/'"/>
            <xsl:namespace name="rdamt" select="'http://rdaregistry.info/termList/RDAMediaType/'"/>
            <xsl:namespace name="skos" select="'http://www.w3.org/2004/02/skos/core#'"/>
            <xsl:call-template name="copy-attributes"/>
            <xsl:for-each select="*:record">
               <xsl:call-template name="create-record-set"/>
            </xsl:for-each>
         </xsl:copy>
      </xsl:variable>
      <xsl:variable name="entity-collection-merged">
         <xsl:choose>
            <xsl:when test="$merge">
               <xsl:apply-templates select="$entity-collection" mode="merge"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="$entity-collection"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="entity-collection-userdefined">
         <xsl:choose>
            <xsl:when test="$userdefined">
               <xsl:apply-templates select="$entity-collection-merged" mode="userdefined"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:copy-of select="$entity-collection-merged"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$rdf">
            <xsl:apply-templates select="$entity-collection-userdefined" mode="rdfify"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="$entity-collection-userdefined"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="*:record" name="create-record-set">
      <xsl:variable name="step1">
         <frbrizer:record-set>
            <xsl:call-template name="MARC21-100700Person"/>
            <xsl:call-template name="MARC21-130240-Work"/>
            <xsl:call-template name="MARC21-130240-Expression"/>
            <xsl:call-template name="MARC21-245-Manifestation"/>
            <xsl:call-template name="MARC21-600-Person"/>
            <xsl:call-template name="MARC21-6XX-Work"/>
            <xsl:call-template name="MARC21-700-Related-Work"/>
            <xsl:call-template name="MARC21-700-Work-Analytical"/>
            <xsl:call-template name="MARC21-700-Expression-Analytical"/>
            <xsl:call-template name="MARC21-758-Related-Work"/>
            <xsl:call-template name="MARC21-8XX-Work-Series"/>
         </frbrizer:record-set>
      </xsl:variable>
      <xsl:variable name="step2">
         <xsl:apply-templates select="$step1" mode="create-inverse-relationships"/>
      </xsl:variable>
      <xsl:variable name="step3">
         <xsl:apply-templates select="$step2" mode="create-keys"/>
      </xsl:variable>
      <xsl:copy-of select="$step3//*:record"/>
   </xsl:template>
   <xsl:template name="MARC21-100700Person">
      <xsl:variable name="this_template_name" select="'MARC21-100700Person'"/>
      <xsl:variable name="tag" as="xs:string" select="'100, 110, 111, 700, 710, 711'"/>
      <xsl:variable name="code" as="xs:string" select="'4'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code" as="xs:string" select="'4'"/>
            <xsl:variable name="anchor_subfield_code" as="xs:string" select="'4'"/>
            <xsl:variable name="this_subfield_position"
                          as="xs:string"
                          select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                         namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                              select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10004'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:if test="$include_counters">
                  <xsl:attribute name="c" select="1"/>
               </xsl:if>
               <xsl:if test="$include_anchorvalues">
                  <xsl:element name="frbrizer:anchorvalue">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_templateinfo">
                  <xsl:element name="frbrizer:templatename">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="$this_template_name"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_internal_key">
                  <xsl:element name="frbrizer:intkey">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_MARC001_in_entityrecord">
                  <xsl:element name="frbrizer:mid">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="i" select="$marcid"/>
                  </xsl:element>
               </xsl:if>
               <xsl:for-each select="$record/*:datafield[@tag='100'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='110'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='111'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-130240-Expression">
      <xsl:variable name="this_template_name" select="'MARC21-130240-Expression'"/>
      <xsl:variable name="tag" as="xs:string" select="'130, 240'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('130','240')][count($record/*:datafield[@tag='700' and @ind2 = '2' and *:subfield/@code = 't']) = 0]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="anchor_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="this_subfield_position"
                          as="xs:string"
                          select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                         namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                              select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10006'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:if test="$include_counters">
                  <xsl:attribute name="c" select="1"/>
               </xsl:if>
               <xsl:if test="$include_anchorvalues">
                  <xsl:element name="frbrizer:anchorvalue">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_templateinfo">
                  <xsl:element name="frbrizer:templatename">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="$this_template_name"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_internal_key">
                  <xsl:element name="frbrizer:intkey">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_MARC001_in_entityrecord">
                  <xsl:element name="frbrizer:mid">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="i" select="$marcid"/>
                  </xsl:element>
               </xsl:if>
               <xsl:for-each select="$record/*:controlfield[@tag='008'][string-length(.) eq 40 and matches(substring(., 36, 3), '[a-z][a-z][a-z]')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-content">
                        <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                        <xsl:with-param name="select" select="substring(., 36, 3)"/>
                        <xsl:with-param name="marcid" select="$marcid"/>
                     </xsl:call-template>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='041'][*:subfield/@code = ('a','d','e','f','j')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','d','e','f','j')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'd'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'e'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'j'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='130'][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20316'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='240'][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20316'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='245'][*:subfield/@code = ('a')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type"
                                                 select="if (frbrizer:linked-strict($record/*:datafield[@tag='740'], $record/*:datafield[@tag=('130', '240')])) then 'http://rdaregistry.info/Elements/e/P20316' else 'http://rdaregistry.info/Elements/e/P20315'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), ($record/*:controlfield[@tag='008'][string-length(.) eq 40 and matches(substring(., 36, 3), '[a-z][a-z][a-z]')]/substring(., 36, 3),$record/*:datafield[@tag='041']/*:subfield[@code=('a', 'd')])[1], $record/*:datafield[@tag='336']/*:subfield[@code='a'][1]), ' / ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='336'][frbrizer:linked($anchor_field, .)][*:subfield/@code = ('a','b','0','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','b','0','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'b'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '0'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('130','240')][*:subfield/@code = '1']">
                  <xsl:variable name="target_template_name" select="'MARC21-130240-Work'"/>
                  <xsl:variable name="target_tag_value" select="'130, 240'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code" as="xs:string" select="'1'"/>
                     <xsl:variable name="target_subfield_position"
                                   as="xs:string"
                                   select="string(position())"/>
                     <xsl:if test="($target_field = $this_field)">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/e/P20231'"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                           <xsl:attribute name="href"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                             select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                           <xsl:if test="$include_MARC001_in_relationships">
                              <xsl:element name="frbrizer:mid">
                                 <xsl:attribute name="i" select="$marcid"/>
                                 <xsl:if test="$include_counters">
                                    <xsl:attribute name="c" select="1"/>
                                 </xsl:if>
                              </xsl:element>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
                  <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                     <xsl:variable name="target_subfield_position"
                                   as="xs:string"
                                   select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/e/') and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                           <xsl:attribute name="href"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                             select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                           <xsl:if test="$include_MARC001_in_relationships">
                              <xsl:element name="frbrizer:mid">
                                 <xsl:attribute name="i" select="$marcid"/>
                                 <xsl:if test="$include_counters">
                                    <xsl:attribute name="c" select="1"/>
                                 </xsl:if>
                              </xsl:element>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-130240-Work">
      <xsl:variable name="this_template_name" select="'MARC21-130240-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'130, 240'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('130','240')][*:subfield/@code = '1']">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="anchor_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="this_subfield_position"
                          as="xs:string"
                          select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                         namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                              select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:if test="$include_counters">
                  <xsl:attribute name="c" select="1"/>
               </xsl:if>
               <xsl:if test="$include_anchorvalues">
                  <xsl:element name="frbrizer:anchorvalue">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_templateinfo">
                  <xsl:element name="frbrizer:templatename">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="$this_template_name"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_internal_key">
                  <xsl:element name="frbrizer:intkey">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_MARC001_in_entityrecord">
                  <xsl:element name="frbrizer:mid">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="i" select="$marcid"/>
                  </xsl:element>
               </xsl:if>
               <xsl:for-each select="$record/*:datafield[@tag='130'][. eq $this_field][*:subfield/@code = ('a','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','k','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='240'][. eq $this_field][*:subfield/@code = ('a','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','k','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='380'][frbrizer:linked($anchor_field, .)][*:subfield/@code = ('a','0')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','0')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '0'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
                  <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                     <xsl:variable name="target_subfield_position"
                                   as="xs:string"
                                   select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/')  and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                           <xsl:attribute name="href"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                             select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                           <xsl:if test="$include_MARC001_in_relationships">
                              <xsl:element name="frbrizer:mid">
                                 <xsl:attribute name="i" select="$marcid"/>
                                 <xsl:if test="$include_counters">
                                    <xsl:attribute name="c" select="1"/>
                                 </xsl:if>
                              </xsl:element>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('600','610','611')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-600-Person'"/>
                  <xsl:variable name="target_tag_value" select="'600, 610, 611'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:if test="(not($target_field/*:subfield/@code = 't') and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/P10319'"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('600','610','611','630')][*:subfield/@code = '1' and  (if (@tag eq '630') then true() else *:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-6XX-Work'"/>
                  <xsl:variable name="target_tag_value" select="'600, 610, 611, 630'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code" as="xs:string" select="'1'"/>
                     <xsl:variable name="target_subfield_position"
                                   as="xs:string"
                                   select="string(position())"/>
                     <xsl:if test="(not($this_field/*:subfield/@code = '1') or not($this_field/*:subfield[@code = '1'] = $target_field/*:subfield[@code = '1'])  and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/P10257'"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                           <xsl:attribute name="href"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                             select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                           <xsl:if test="$include_MARC001_in_relationships">
                              <xsl:element name="frbrizer:mid">
                                 <xsl:attribute name="i" select="$marcid"/>
                                 <xsl:if test="$include_counters">
                                    <xsl:attribute name="c" select="1"/>
                                 </xsl:if>
                              </xsl:element>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1' and starts-with(., 'http')]) and not(@ind2 = '2') and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
                  <xsl:variable name="target_template_name" select="'MARC21-700-Related-Work'"/>
                  <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                     <xsl:variable name="target_subfield_position"
                                   as="xs:string"
                                   select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                           <xsl:attribute name="href"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                             select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                           <xsl:if test="$include_MARC001_in_relationships">
                              <xsl:element name="frbrizer:mid">
                                 <xsl:attribute name="i" select="$marcid"/>
                                 <xsl:if test="$include_counters">
                                    <xsl:attribute name="c" select="1"/>
                                 </xsl:if>
                              </xsl:element>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('758')]">
                  <xsl:variable name="target_template_name" select="'MARC21-758-Related-Work'"/>
                  <xsl:variable name="target_tag_value" select="'758'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:for-each select="node()[@code='4'][starts-with(., 'http') and exists($this_field/*:subfield[@code = '1']/starts-with(., 'http')) ]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                     <xsl:variable name="target_subfield_position"
                                   as="xs:string"
                                   select="string(position())"/>
                     <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                        <frbrizer:relationship>
                           <xsl:attribute name="type" select="$target_subfield"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                           <xsl:attribute name="href"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           <xsl:if test="$include_internal_key">
                              <xsl:attribute name="intkey"
                                             select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                           </xsl:if>
                           <xsl:if test="$include_MARC001_in_relationships">
                              <xsl:element name="frbrizer:mid">
                                 <xsl:attribute name="i" select="$marcid"/>
                                 <xsl:if test="$include_counters">
                                    <xsl:attribute name="c" select="1"/>
                                 </xsl:if>
                              </xsl:element>
                           </xsl:if>
                        </frbrizer:relationship>
                     </xsl:if>
                  </xsl:for-each>
               </xsl:for-each>
               <xsl:for-each select="$record/node()[@tag=('800','810','811','830')]">
                  <xsl:variable name="target_template_name" select="'MARC21-8XX-Work-Series'"/>
                  <xsl:variable name="target_tag_value" select="'800, 810, 811, 830'"/>
                  <xsl:variable name="target_field"
                                select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
                  <xsl:variable name="target_field_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
                     <xsl:variable name="target_subfield" select="."/>
                     <xsl:variable name="target_subfield_code" as="xs:string" select="'1'"/>
                     <xsl:variable name="target_subfield_position"
                                   as="xs:string"
                                   select="string(position())"/>
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/P10019'"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:for-each>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-245-Manifestation">
      <xsl:variable name="this_template_name" select="'MARC21-245-Manifestation'"/>
      <xsl:variable name="tag" as="xs:string" select="'245'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('245')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                      namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                           select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10007'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:if test="$include_counters">
               <xsl:attribute name="c" select="1"/>
            </xsl:if>
            <xsl:if test="$include_anchorvalues">
               <xsl:element name="frbrizer:anchorvalue">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="."/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_templateinfo">
               <xsl:element name="frbrizer:templatename">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="$this_template_name"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_internal_key">
               <xsl:element name="frbrizer:intkey">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_MARC001_in_entityrecord">
               <xsl:element name="frbrizer:mid">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:attribute name="i" select="$marcid"/>
               </xsl:element>
            </xsl:if>
            <xsl:for-each select="$record/*:controlfield[@tag='001']">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30004'"/>
                     <xsl:with-param name="select" select="."/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:controlfield[@tag='003']">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30004'"/>
                     <xsl:with-param name="select" select="."/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:controlfield[@tag='008']">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30004'"/>
                     <xsl:with-param name="select" select="."/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='020'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="'ISBN' || frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30004'"/>
                              <xsl:with-param name="select" select="concat('isbn-', replace(., '\D', ''))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='022'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30004'"/>
                              <xsl:with-param name="select" select="concat('issn-', ./replace(., '\D', ''))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='024'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30004'"/>
                              <xsl:with-param name="select"
                                              select="concat(frbrizer:idprefix(../@ind1) ,'-', replace(., '\D', ''))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='245'][. = $this_field][*:subfield/@code = ('a','b','c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30156'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30142'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30117'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='250'][*:subfield/@code = ('a')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30107'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='260'][*:subfield/@code = ('a','b','c','e','f','g')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c','e','f','g')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30088'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30083'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30011'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'e'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30111'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30175'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'g'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30109'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='264'][*:subfield/@code = ('a','b','c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','b','c')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30088'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30083'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30011'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='300'][*:subfield/@code = ('a','c')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','c')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30182'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'c'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30169'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='337'][*:subfield/@code = ('a','b','0','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','b','0','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30001'"/>
                              <xsl:with-param name="select" select="lower-case(frbrizer:trim(.))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30001'"/>
                              <xsl:with-param name="select" select="lower-case(frbrizer:trim(.))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '0'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30001'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30001'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='338'][*:subfield/@code = ('a','b','0','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','b','0','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30002'"/>
                              <xsl:with-param name="select" select="lower-case(frbrizer:trim(.))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30002'"/>
                              <xsl:with-param name="select" select="lower-case(frbrizer:trim(.))"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '0'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30002'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30002'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='490'][*:subfield/@code = ('a','v')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','v')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30106'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'v'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/m/P30165'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
               <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/m/') and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('130','240')][count($record/*:datafield[@tag='700' and @ind2 = '2' and *:subfield/@code = 't']) = 0]">
               <xsl:variable name="target_template_name" select="'MARC21-130240-Expression'"/>
               <xsl:variable name="target_tag_value" select="'130, 240'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'1'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/m/P30139'"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="href"
                                    select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     </xsl:if>
                     <xsl:if test="$include_MARC001_in_relationships">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and  @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-700-Expression-Analytical'"/>
               <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <frbrizer:relationship>
                  <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/m/P30139'"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:attribute name="href"
                                 select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                  <xsl:if test="$include_internal_key">
                     <xsl:attribute name="intkey"
                                    select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                  </xsl:if>
                  <xsl:if test="$include_MARC001_in_relationships">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </frbrizer:relationship>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-600-Person">
      <xsl:variable name="this_template_name" select="'MARC21-600-Person'"/>
      <xsl:variable name="tag" as="xs:string" select="'600, 610, 611'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('600','610','611')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                      namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                           select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type"
                           select="if ($this_field/@tag = '600') then 'http://rdaregistry.info/Elements/c/C10004' else if ($this_field/@tag = '610') then 'http://rdaregistry.info/Elements/c/C10005' else if ($this_field/@tag = '611') then 'http://rdaregistry.info/Elements/c/C10011' else 'http://rdaregistry.info/Elements/c/C10002'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:if test="$include_counters">
               <xsl:attribute name="c" select="1"/>
            </xsl:if>
            <xsl:if test="$include_anchorvalues">
               <xsl:element name="frbrizer:anchorvalue">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="."/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_templateinfo">
               <xsl:element name="frbrizer:templatename">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="$this_template_name"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_internal_key">
               <xsl:element name="frbrizer:intkey">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_MARC001_in_entityrecord">
               <xsl:element name="frbrizer:mid">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:attribute name="i" select="$marcid"/>
               </xsl:element>
            </xsl:if>
            <xsl:for-each select="$record/*:datafield[@tag='600'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50413'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'd'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='610'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50413'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'd'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='611'][. eq $this_field][*:subfield/@code = ('a','d','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','d','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50385'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50413'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'd'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50339'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/a/P50383'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-6XX-Work">
      <xsl:variable name="this_template_name" select="'MARC21-6XX-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'600, 610, 611, 630'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('600','610','611','630')][*:subfield/@code = '1' and  (if (@tag eq '630') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="anchor_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="this_subfield_position"
                          as="xs:string"
                          select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                         namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                              select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:if test="$include_counters">
                  <xsl:attribute name="c" select="1"/>
               </xsl:if>
               <xsl:if test="$include_anchorvalues">
                  <xsl:element name="frbrizer:anchorvalue">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_templateinfo">
                  <xsl:element name="frbrizer:templatename">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="$this_template_name"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_internal_key">
                  <xsl:element name="frbrizer:intkey">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_MARC001_in_entityrecord">
                  <xsl:element name="frbrizer:mid">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="i" select="$marcid"/>
                  </xsl:element>
               </xsl:if>
               <xsl:for-each select="$record/*:datafield[@tag='600'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='610'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='611'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='630'][. eq $this_field][*:subfield/@code = ('a','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','k','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-700-Expression-Analytical">
      <xsl:variable name="this_template_name" select="'MARC21-700-Expression-Analytical'"/>
      <xsl:variable name="tag" as="xs:string" select="'700, 710, 711, 730'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and  @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                      namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                           select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10006'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:if test="$include_counters">
               <xsl:attribute name="c" select="1"/>
            </xsl:if>
            <xsl:if test="$include_anchorvalues">
               <xsl:element name="frbrizer:anchorvalue">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="."/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_templateinfo">
               <xsl:element name="frbrizer:templatename">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="$this_template_name"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_internal_key">
               <xsl:element name="frbrizer:intkey">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_MARC001_in_entityrecord">
               <xsl:element name="frbrizer:mid">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:attribute name="i" select="$marcid"/>
               </xsl:element>
            </xsl:if>
            <xsl:for-each select="$record/*:controlfield[@tag='008'][string-length(.) eq 40 and matches(substring(., 36, 3), '[a-z][a-z][a-z]')]">
               <xsl:copy>
                  <xsl:call-template name="copy-content">
                     <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                     <xsl:with-param name="select" select="substring(., 36, 3)"/>
                     <xsl:with-param name="marcid" select="$marcid"/>
                  </xsl:call-template>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='041'][frbrizer:linked($anchor_field, .) and not(exists($anchor_field/*:subfield[@code = 'l']))][*:subfield/@code = ('a','d','e','f','j')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','d','e','f','j')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'd'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'e'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'j'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='336'][frbrizer:linked($anchor_field, .)][*:subfield/@code = ('a','b','0','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','b','0','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'b'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '0'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20001'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('t','l')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('t','l')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select"
                                              select="string-join((frbrizer:trim(.), ($record/*:controlfield[@tag='008'][string-length(.) eq 40 and matches(substring(., 36, 3), '[a-z][a-z][a-z]')]/substring(., 36, 3),$record/*:datafield[@tag='041']/*:subfield[@code=('a', 'd')])[1], $record/*:datafield[@tag='336']/*:subfield[@code='a'][1]), ' / ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                              select="if (frbrizer:linked-strict($record/*:datafield[@tag='740'], ..)) then 'http://rdaregistry.info/Elements/e/P20316' else 'http://rdaregistry.info/Elements/e/P20315'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('t','l')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('t','l')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                              select="if (frbrizer:linked-strict($record/*:datafield[@tag='740'], ..)) then 'http://rdaregistry.info/Elements/e/P20316' else 'http://rdaregistry.info/Elements/e/P20315'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('t','l')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('t','l')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                              select="if (frbrizer:linked-strict($record/*:datafield[@tag='740'], ..)) then 'http://rdaregistry.info/Elements/e/P20316' else 'http://rdaregistry.info/Elements/e/P20315'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='730'][. eq $this_field][*:subfield/@code = ('a','l','t')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','l','t')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'l'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/e/P20006'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type"
                                              select="if (frbrizer:linked-strict($record/*:datafield[@tag='740'], ..)) then 'http://rdaregistry.info/Elements/e/P20316' else 'http://rdaregistry.info/Elements/e/P20315'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-700-Work-Analytical'"/>
               <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:if test="($target_field = $this_field)">
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/e/P20231'"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="href"
                                    select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     </xsl:if>
                     <xsl:if test="$include_MARC001_in_relationships">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
               <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/e/') and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-700-Related-Work">
      <xsl:variable name="this_template_name" select="'MARC21-700-Related-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'700, 710, 711, 730'"/>
      <xsl:variable name="code" as="xs:string" select="'4'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1' and starts-with(., 'http')]) and not(@ind2 = '2') and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code" as="xs:string" select="'4'"/>
            <xsl:variable name="anchor_subfield_code" as="xs:string" select="'4'"/>
            <xsl:variable name="this_subfield_position"
                          as="xs:string"
                          select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                         namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                              select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:if test="$include_counters">
                  <xsl:attribute name="c" select="1"/>
               </xsl:if>
               <xsl:if test="$include_anchorvalues">
                  <xsl:element name="frbrizer:anchorvalue">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_templateinfo">
                  <xsl:element name="frbrizer:templatename">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="$this_template_name"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_internal_key">
                  <xsl:element name="frbrizer:intkey">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_MARC001_in_entityrecord">
                  <xsl:element name="frbrizer:mid">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="i" select="$marcid"/>
                  </xsl:element>
               </xsl:if>
               <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='730'][. eq $this_field][*:subfield/@code = ('a','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','k','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-700-Work-Analytical">
      <xsl:variable name="this_template_name" select="'MARC21-700-Work-Analytical'"/>
      <xsl:variable name="tag" as="xs:string" select="'700, 710, 711, 730'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1']/starts-with(., 'http'))  and @ind2='2' and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:element name="{name(ancestor-or-self::*:record)}"
                      namespace="{namespace-uri(ancestor-or-self::*:record)}">
            <xsl:attribute name="id"
                           select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
            <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
            <xsl:attribute name="templatename" select="$this_template_name"/>
            <xsl:if test="$include_counters">
               <xsl:attribute name="c" select="1"/>
            </xsl:if>
            <xsl:if test="$include_anchorvalues">
               <xsl:element name="frbrizer:anchorvalue">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="."/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_templateinfo">
               <xsl:element name="frbrizer:templatename">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="$this_template_name"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_internal_key">
               <xsl:element name="frbrizer:intkey">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_field_position), ':')"/>
               </xsl:element>
            </xsl:if>
            <xsl:if test="$include_MARC001_in_entityrecord">
               <xsl:element name="frbrizer:mid">
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:attribute name="i" select="$marcid"/>
               </xsl:element>
            </xsl:if>
            <xsl:for-each select="$record/*:datafield[@tag='700'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                              <xsl:with-param name="select"
                                              select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'k'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='710'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                              <xsl:with-param name="select"
                                              select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'k'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='711'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 't'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                              <xsl:with-param name="select"
                                              select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'k'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='730'][. eq $this_field][*:subfield/@code = ('a','f','n','k','1')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','f','n','k','1')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                              <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                              <xsl:with-param name="select"
                                              select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'f'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'n'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = 'k'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '1'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/*:datafield[@tag='380'][frbrizer:linked($anchor_field, .)][*:subfield/@code = ('a','0')]">
               <xsl:copy>
                  <xsl:call-template name="copy-attributes"/>
                  <xsl:if test="$include_counters">
                     <xsl:attribute name="c" select="1"/>
                  </xsl:if>
                  <xsl:for-each select="*:subfield[@code = ('a','0')]">
                     <xsl:if test="@code = 'a'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                              <xsl:with-param name="select" select="lower-case(.)"/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                     <xsl:if test="@code = '0'">
                        <xsl:copy>
                           <xsl:call-template name="copy-content">
                              <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                              <xsl:with-param name="select" select="."/>
                           </xsl:call-template>
                        </xsl:copy>
                     </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="$include_MARC001_in_subfield">
                     <xsl:element name="frbrizer:mid">
                        <xsl:attribute name="i" select="$marcid"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                     </xsl:element>
                  </xsl:if>
               </xsl:copy>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('130','240')][*:subfield/@code = '1']">
               <xsl:variable name="target_template_name" select="'MARC21-130240-Work'"/>
               <xsl:variable name="target_tag_value" select="'130, 240'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'1'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/P10019'"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="href"
                                    select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                     </xsl:if>
                     <xsl:if test="$include_MARC001_in_relationships">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('600','610','611')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-600-Person'"/>
               <xsl:variable name="target_tag_value" select="'600, 610, 611'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:if test="(frbrizer:linked-or-nolink($anchor_field, $target_field))">
                  <frbrizer:relationship>
                     <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/P10319'"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="href"
                                    select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     <xsl:if test="$include_internal_key">
                        <xsl:attribute name="intkey"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_field_position), ':')"/>
                     </xsl:if>
                     <xsl:if test="$include_MARC001_in_relationships">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </frbrizer:relationship>
               </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('600','610','611','630')][*:subfield/@code = '1' and  (if (@tag eq '630') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-6XX-Work'"/>
               <xsl:variable name="target_tag_value" select="'600, 610, 611, 630'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'1'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:if test="(frbrizer:linked-or-nolink($anchor_field, $target_field) and not($this_field/*:subfield[@code = '1'] = $target_field/*:subfield[@code = '1']))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/w/P10257'"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('100','110','111','700','710','711')][exists(*:subfield[@code = '1']/starts-with(., 'http')) and not(*:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-100700Person'"/>
               <xsl:variable name="target_tag_value" select="'100, 110, 111, 700, 710, 711'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked-or-nolink($anchor_field, $target_field))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('700','710','711','730')][exists(*:subfield[@code = '1' and starts-with(., 'http')]) and not(@ind2 = '2') and (if (@tag eq '730') then true() else *:subfield/@code = 't')]">
               <xsl:variable name="target_template_name" select="'MARC21-700-Related-Work'"/>
               <xsl:variable name="target_tag_value" select="'700, 710, 711, 730'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='4'][starts-with(., 'http')]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/') and frbrizer:linked-strict($anchor_field, $target_field))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
            <xsl:for-each select="$record/node()[@tag=('758')]">
               <xsl:variable name="target_template_name" select="'MARC21-758-Related-Work'"/>
               <xsl:variable name="target_tag_value" select="'758'"/>
               <xsl:variable name="target_field"
                             select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
               <xsl:variable name="target_field_position"
                             as="xs:string"
                             select="string(position())"/>
               <xsl:for-each select="node()[@code='4'][starts-with(., 'http') and exists($this_field/*:subfield[@code = '1']/starts-with(., 'http')) ]">
                  <xsl:variable name="target_subfield" select="."/>
                  <xsl:variable name="target_subfield_code" as="xs:string" select="'4'"/>
                  <xsl:variable name="target_subfield_position"
                                as="xs:string"
                                select="string(position())"/>
                  <xsl:if test="(starts-with($target_subfield, 'http://rdaregistry.info/Elements/w/')  and frbrizer:linked-strict($anchor_field, $target_field))">
                     <frbrizer:relationship>
                        <xsl:attribute name="type" select="$target_subfield"/>
                        <xsl:if test="$include_counters">
                           <xsl:attribute name="c" select="1"/>
                        </xsl:if>
                        <xsl:attribute name="href"
                                       select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        <xsl:if test="$include_internal_key">
                           <xsl:attribute name="intkey"
                                          select="string-join(($record/@id,$target_template_name,$target_tag_value,$target_subfield_code,$target_field_position,$target_subfield_position), ':')"/>
                        </xsl:if>
                        <xsl:if test="$include_MARC001_in_relationships">
                           <xsl:element name="frbrizer:mid">
                              <xsl:attribute name="i" select="$marcid"/>
                              <xsl:if test="$include_counters">
                                 <xsl:attribute name="c" select="1"/>
                              </xsl:if>
                           </xsl:element>
                        </xsl:if>
                     </frbrizer:relationship>
                  </xsl:if>
               </xsl:for-each>
            </xsl:for-each>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-758-Related-Work">
      <xsl:variable name="this_template_name" select="'MARC21-758-Related-Work'"/>
      <xsl:variable name="tag" as="xs:string" select="'758'"/>
      <xsl:variable name="code" as="xs:string" select="'4'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('758')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:for-each select="node()[@code='4'][starts-with(., 'http') and exists($this_field/*:subfield[@code = '1']/starts-with(., 'http')) ]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code" as="xs:string" select="'4'"/>
            <xsl:variable name="anchor_subfield_code" as="xs:string" select="'4'"/>
            <xsl:variable name="this_subfield_position"
                          as="xs:string"
                          select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                         namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                              select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:if test="$include_counters">
                  <xsl:attribute name="c" select="1"/>
               </xsl:if>
               <xsl:if test="$include_anchorvalues">
                  <xsl:element name="frbrizer:anchorvalue">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_templateinfo">
                  <xsl:element name="frbrizer:templatename">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="$this_template_name"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_internal_key">
                  <xsl:element name="frbrizer:intkey">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_MARC001_in_entityrecord">
                  <xsl:element name="frbrizer:mid">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="i" select="$marcid"/>
                  </xsl:element>
               </xsl:if>
               <xsl:for-each select="$record/*:datafield[@tag='758'][. = $this_field][*:subfield/@code = ('a','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template name="MARC21-8XX-Work-Series">
      <xsl:variable name="this_template_name" select="'MARC21-8XX-Work-Series'"/>
      <xsl:variable name="tag" as="xs:string" select="'800, 810, 811, 830'"/>
      <xsl:variable name="code" as="xs:string" select="'1'"/>
      <xsl:variable name="record" select="."/>
      <xsl:variable name="marcid" select="*:controlfield[@tag='001']"/>
      <xsl:for-each select="node()[@tag=('800','810','811','830')]">
         <xsl:variable name="this_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor_field"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="anchor"
                       as="xs:string"
                       select="(ancestor-or-self::*:datafield, ancestor-or-self::*:controlfield)"/>
         <xsl:variable name="this_field_position"
                       as="xs:string"
                       select="string(position())"/>
         <xsl:for-each select="node()[@code='1'][starts-with(., 'http')]">
            <xsl:variable name="this_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="anchor_subfield" select="(ancestor-or-self::*:subfield)"/>
            <xsl:variable name="this_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="anchor_subfield_code" as="xs:string" select="'1'"/>
            <xsl:variable name="this_subfield_position"
                          as="xs:string"
                          select="string(position())"/>
            <xsl:element name="{name(ancestor-or-self::*:record)}"
                         namespace="{namespace-uri(ancestor-or-self::*:record)}">
               <xsl:attribute name="id"
                              select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
               <xsl:attribute name="type" select="'http://rdaregistry.info/Elements/c/C10001'"/>
               <xsl:attribute name="templatename" select="$this_template_name"/>
               <xsl:if test="$include_counters">
                  <xsl:attribute name="c" select="1"/>
               </xsl:if>
               <xsl:if test="$include_anchorvalues">
                  <xsl:element name="frbrizer:anchorvalue">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="."/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_templateinfo">
                  <xsl:element name="frbrizer:templatename">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="$this_template_name"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_internal_key">
                  <xsl:element name="frbrizer:intkey">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:value-of select="string-join(($record/@id,$this_template_name,$tag,$this_subfield_code,$this_field_position,$this_subfield_position), ':')"/>
                  </xsl:element>
               </xsl:if>
               <xsl:if test="$include_MARC001_in_entityrecord">
                  <xsl:element name="frbrizer:mid">
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:attribute name="i" select="$marcid"/>
                  </xsl:element>
               </xsl:if>
               <xsl:for-each select="$record/*:datafield[@tag='800'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='810'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='811'][. eq $this_field][*:subfield/@code = ('t','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('t','f','n','k','1')]">
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 't'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
               <xsl:for-each select="$record/*:datafield[@tag='830'][. eq $this_field][*:subfield/@code = ('a','f','n','k','1')]">
                  <xsl:copy>
                     <xsl:call-template name="copy-attributes"/>
                     <xsl:if test="$include_counters">
                        <xsl:attribute name="c" select="1"/>
                     </xsl:if>
                     <xsl:for-each select="*:subfield[@code = ('a','f','n','k','1')]">
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://www.w3.org/2000/01/rdf-schema#label'"/>
                                 <xsl:with-param name="select" select="frbrizer:trim(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'a'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10088'"/>
                                 <xsl:with-param name="select"
                                                 select="string-join((frbrizer:trim(.), frbrizer:trim(../*:subfield[@code = 'p'])), ' : ')"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'f'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10219'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'n'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10003'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = 'k'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10004'"/>
                                 <xsl:with-param name="select" select="lower-case(.)"/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                        <xsl:if test="@code = '1'">
                           <xsl:copy>
                              <xsl:call-template name="copy-content">
                                 <xsl:with-param name="type" select="'http://rdaregistry.info/Elements/w/P10002'"/>
                                 <xsl:with-param name="select" select="."/>
                              </xsl:call-template>
                           </xsl:copy>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:if test="$include_MARC001_in_subfield">
                        <xsl:element name="frbrizer:mid">
                           <xsl:attribute name="i" select="$marcid"/>
                           <xsl:if test="$include_counters">
                              <xsl:attribute name="c" select="1"/>
                           </xsl:if>
                        </xsl:element>
                     </xsl:if>
                  </xsl:copy>
               </xsl:for-each>
            </xsl:element>
         </xsl:for-each>
      </xsl:for-each>
   </xsl:template>
   <xsl:template match="frbrizer:record-set" mode="create-key-mapping-step-1">
      <frbrizer:keymap>
         <xsl:for-each select="*:record">
            <xsl:choose>
               <xsl:when test="@templatename = 'MARC21-100700Person'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('100', '110', '111', '700', '710', '711')]/*:subfield[@code='1'][starts-with(., 'http')][1])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-130240-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('130', '240')]/*:subfield[@code='1'][starts-with(., 'http')][last()])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-600-Person'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('600', '610', '611')]/*:subfield[@code='1'][starts-with(., 'http')][1])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-6XX-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('600', '610', '611', '630')]/*:subfield[@code='1'][starts-with(., 'http')][1])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-700-Related-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('700', '710', '711', '730')]/*:subfield[@code='1'][starts-with(.,'http')][last()])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-700-Work-Analytical'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('700', '710', '711', '730')]/*:subfield[@code='1'][starts-with(., 'http')][last()])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-758-Related-Work'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('758')]/*:subfield[@code='1'][starts-with(., 'http')][1])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-8XX-Work-Series'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(*:datafield[@tag=('800', '810', '811', '830')]/*:subfield[@code='1'][starts-with(.,'http')][last()])"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
            </xsl:choose>
         </xsl:for-each>
      </frbrizer:keymap>
   </xsl:template>
   <xsl:template match="frbrizer:record-set" mode="create-key-mapping-step-2">
      <frbrizer:keymap>
         <xsl:for-each select="*:record">
            <xsl:choose>
               <xsl:when test="@templatename = 'MARC21-130240-Expression'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys((frbrizer:sort-relationships(*:relationship[@type = 'http://rdaregistry.info/Elements/e/P20231']/@href))[1])"/>
                        <xsl:value-of select="frbrizer:sort-keys('/')"/>
                        <xsl:value-of select="frbrizer:sort-keys(lower-case((*:datafield[@tag = ('041', '130', '240')]/*:subfield[@type='http://rdaregistry.info/Elements/e/P20006'], *:controlfield[@tag = '008'][@type='http://rdaregistry.info/Elements/e/P20006'] )[1]))"/>
                        <xsl:value-of select="frbrizer:sort-keys('/')"/>
                        <xsl:value-of select="frbrizer:sort-keys( if (*:datafield[@tag='336']/*:subfield[@code='0']) then (tokenize((*:datafield[@tag='336']/*:subfield[@code='0'])[1], '/'))[last()] else (*:datafield[@tag='336']/*:subfield[@code='b'], *:datafield[@tag='336']/*:subfield[@code='a'], 'nocontenttype')[1])"/>
                        <xsl:value-of select="frbrizer:sort-keys('/')"/>
                        <xsl:value-of select="frbrizer:sort-keys(string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/P20037', 'http://rdaregistry.info/Elements/e/P20022', 'http://rdaregistry.info/Elements/e/P20049', 'http://rdaregistry.info/Elements/e/P20330')]/@href), '/'))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-245-Manifestation'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys(if ((*:datafield[@tag=(&#34;020&#34;,&#34;024&#34;)][1]/*:subfield[@code='a'])[1]) then (*:datafield[@tag=(&#34;020&#34;,&#34;024&#34;)][1]/*:subfield[@code='a'])[1]/replace(., '\(.*\)', '') else if (*:controlfield[@tag=('001', '003')]) then *:controlfield[@tag=('001', '003')][1] else generate-id(.))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
               <xsl:when test="@templatename = 'MARC21-700-Expression-Analytical'">
                  <xsl:element name="frbrizer:keyentry">
                     <xsl:variable name="key">
                        <xsl:value-of select="frbrizer:sort-keys((frbrizer:sort-relationships(*:relationship[@type = 'http://rdaregistry.info/Elements/e/P20231']/@href))[1])"/>
                        <xsl:value-of select="frbrizer:sort-keys('/')"/>
                        <xsl:value-of select="frbrizer:sort-keys(lower-case((*:datafield[@tag = ('041')]/*:subfield[@type='http://rdaregistry.info/Elements/e/P20006'], *:controlfield[@tag = '008'][@type='http://rdaregistry.info/Elements/e/P20006'])[1]))"/>
                        <xsl:value-of select="frbrizer:sort-keys('/')"/>
                        <xsl:value-of select="frbrizer:sort-keys( if (*:datafield[@tag='336']/*:subfield[@code='0']) then (tokenize((*:datafield[@tag='336']/*:subfield[@code='0'])[1], '/'))[last()] else (*:datafield[@tag='336']/*:subfield[@code='b'], *:datafield[@tag='336']/*:subfield[@code='a'], 'nocontenttype')[1])"/>
                        <xsl:value-of select="frbrizer:sort-keys('/')"/>
                        <xsl:value-of select="frbrizer:sort-keys(string-join(frbrizer:trimsort-targets(*:relationship[@type =('http://rdaregistry.info/Elements/e/P20037', 'http://rdaregistry.info/Elements/e/P20022', 'http://rdaregistry.info/Elements/e/P20049', 'http://rdaregistry.info/Elements/e/P20330')]/@href), '/'))"/>
                     </xsl:variable>
                     <xsl:variable name="keyvalue" select="replace($key, ' ', '')"/>
                     <xsl:attribute name="key" select="$keyvalue"/>
                     <xsl:attribute name="id" select="@id"/>
                  </xsl:element>
               </xsl:when>
            </xsl:choose>
         </xsl:for-each>
      </frbrizer:keymap>
   </xsl:template>
   <xsl:template match="*:record-set" mode="create-keys">
      <xsl:variable name="set-phase-0" select="."/>
      <xsl:variable name="keys-phase-1">
         <xsl:apply-templates select="$set-phase-0" mode="create-key-mapping-step-1"/>
      </xsl:variable>
      <xsl:variable name="set-phase-1">
         <xsl:apply-templates select="$set-phase-0" mode="replace-keys">
            <xsl:with-param name="keymapping" select="$keys-phase-1"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:variable name="keys-phase-2">
         <xsl:apply-templates select="$set-phase-1" mode="create-key-mapping-step-2"/>
      </xsl:variable>
      <xsl:variable name="set-phase-2">
         <xsl:apply-templates select="$set-phase-1" mode="replace-keys">
            <xsl:with-param name="keymapping" select="$keys-phase-2"/>
         </xsl:apply-templates>
      </xsl:variable>
      <xsl:copy-of select="$set-phase-2"/>
   </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 name="copy-content">
        <xsl:param name="type" required="no" select="''"/>
        <xsl:param name="subtype" required="no" select="''"/>
        <xsl:param name="label" required="no" select="''"/>
        <xsl:param name="select" required="no"/>
        <xsl:param name="marcid" required="no"/>
        <xsl:call-template name="copy-attributes"/>
        <xsl:if test="$type ne ''">
            <xsl:attribute name="type" select="$type"/>
        </xsl:if>
        <xsl:if test="$subtype ne ''">
            <xsl:attribute name="subtype" select="$subtype"/>
        </xsl:if>
        <!--<xsl:if test="$include_labels and ($label ne '')">
            <xsl:if test="$label ne ''">
                <xsl:attribute name="label" select="$label"/>
            </xsl:if>
        </xsl:if>-->
        <xsl:value-of select="normalize-space($select)"/>
        <xsl:if test="$include_MARC001_in_controlfield">
            <xsl:if test="string($marcid) ne ''">
                <xsl:element name="frbrizer:mid">
                    <xsl:attribute name="i" select="$marcid"/>
                </xsl:element>
            </xsl:if>
        </xsl:if>
    </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 name="copy-attributes">
        <xsl:for-each select="@*">
            <xsl:copy/>
        </xsl:for-each>
    </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 match="*:record-set"
                 mode="replace-keys"
                 name="replace-keys">
        <xsl:param name="keymapping" required="yes"/>
        <xsl:copy>
            <xsl:call-template name="copy-attributes"/>
            <xsl:for-each select="*:record">
                <xsl:variable name="record_id" select="@id"/>
                <xsl:choose>
                    <xsl:when test="$keymapping//*:keyentry[@id = $record_id]">
                        <xsl:copy>
                            <xsl:for-each select="@*">
                                <xsl:choose>
                                    <xsl:when test="local-name() = 'id'">
                                        <xsl:attribute name="id" select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            <xsl:if test="$include_sourceinfo">
                                <xsl:element name="frbrizer:source">
                                    <xsl:attribute name="c" select="1"/>
                                    <xsl:value-of select="$record_id"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="$include_keyvalues">
                                <xsl:element name="frbrizer:keyvalue">
                                    <xsl:if test="$include_counters">
                                        <xsl:attribute name="f.c" select="1"/>
                                    </xsl:if>
                                    <xsl:value-of select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:if test="$include_id_as_element">
                                <xsl:element name="frbrizer:idvalue">
                                    <xsl:attribute name="c" select="'1'"/>
                                    <xsl:attribute name="id" select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                    <xsl:value-of select="$keymapping//*:keyentry[@id = $record_id]/@key"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:for-each select="node()">
                                <xsl:choose>
                                    <xsl:when test="@href = $keymapping//*:keyentry/@id">
                                        <xsl:variable name="temp" select="@href"/>
                                        <xsl:copy>
                                            <xsl:for-each select="@*">
                                                <xsl:choose>
                                                  <xsl:when test="local-name() = 'href'">
                                                  <xsl:attribute name="href" select="$keymapping//*:keyentry[@id = $temp]/@key"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                            <xsl:for-each select="node()">
                                                <xsl:copy-of select="."/>
                                            </xsl:for-each>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="exists(*:relationship[@href = $keymapping//*:keyentry/@id])">
                        <xsl:copy>
                            <xsl:call-template name="copy-attributes"/>
                            <xsl:for-each select="node()">
                                <xsl:choose>
                                    <xsl:when test="local-name() = 'relationship'">
                                        <xsl:variable name="href" select="@href"/>
                                        <xsl:copy>
                                            <xsl:for-each select="@*">
                                                <xsl:choose>
                                                  <xsl:when test="local-name() = 'href' and exists($keymapping//*:keyentry[@id = $href]/@key)">
                                                  <xsl:attribute name="href" select="$keymapping//*:keyentry[@id = $href]/@key[1]"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:copy-of select="."/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:for-each>
                                            <xsl:copy-of select="frbrizer:mid"/>
                                        </xsl:copy>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 match="*:record-set"
                 mode="create-inverse-relationships">
        <xsl:if test="$include_missing_reverse_relationships">
            <xsl:variable name="record-set" select="."/>
            <xsl:copy>
                <xsl:for-each select="*:record">
                    <xsl:variable name="record" select="."/>
                    <xsl:variable name="this-entity-id" select="@id"/>
                    <xsl:copy>
                        <xsl:copy-of select="@* | node()"/>
                        <xsl:for-each select="$record-set/*:record[*:relationship[(@href = $this-entity-id)]]">
                            <xsl:variable name="target-entity-type" select="@type"/>
                            <xsl:variable name="target-entity-label" select="@label"/>
                            <xsl:variable name="target-entity-id" select="@id"/>
                            <xsl:for-each select="*:relationship[(@href eq $this-entity-id) and exists(@itype)]">
                                <xsl:variable name="rel-type" select="@type"/>
                                <xsl:variable name="rel-itype" select="@itype"/>
                                <xsl:if test="not(exists($record/*:relationship[@href eq $target-entity-id and @itype = $rel-type and @type = $rel-itype]))">
                                    <xsl:copy>
                                        <xsl:if test="exists(@itype)">
                                            <xsl:attribute name="type" select="@itype"/>
                                        </xsl:if>
                                        <xsl:if test="exists(@type)">
                                            <xsl:attribute name="itype" select="@type"/>
                                        </xsl:if>
                                        <xsl:if test="exists(@isubtype)">
                                            <xsl:attribute name="subtype" select="@isubtype"/>
                                        </xsl:if>
                                        <xsl:if test="exists(@subtype)">
                                            <xsl:attribute name="isubtype" select="@subtype"/>
                                        </xsl:if>
                                        <!--<xsl:if test="$include_target_entity_type">
                                            <xsl:attribute name="target_type" select="$target-entity-type"/>
                                        </xsl:if>-->
                                        <xsl:if test="$include_counters">
                                            <xsl:attribute name="c" select="'1'"/>
                                        </xsl:if>
                                        <xsl:attribute name="href" select="$target-entity-id"/>
                                        <!--<xsl:if test="$include_labels">
                                            <xsl:if test="@ilabel ne ''">
                                                <xsl:attribute name="label" select="@ilabel"/>
                                            </xsl:if>
                                            <xsl:if test="@label ne ''">
                                                <xsl:attribute name="ilabel" select="@label"/>
                                            </xsl:if>
                                        </xsl:if>-->
                                        <xsl:copy-of select="node()"/>
                                    </xsl:copy>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:for-each>
                    </xsl:copy>
                </xsl:for-each>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
   <xsl:template xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 match="/*:collection"
                 mode="merge"
                 name="merge">
        <xsl:param name="ignore_indicators_in_merge" select="false()" required="no"/>
        <xsl:copy>
            <xsl:for-each-group select="//*:record" group-by="@id">
                <xsl:sort select="@type"/>
                <xsl:sort select="@subtype"/>
                <xsl:sort select="@id"/>
                <xsl:element name="{name(current-group()[1])}"
                         namespace="{namespace-uri(current-group()[1])}">
                    <xsl:attribute name="id" select="current-group()[1]/@id"/>
                    <xsl:attribute name="type" select="current-group()[1]/@type"/>
                    <xsl:if test="exists(current-group()/@subtype)">
                        <xsl:attribute name="subtype">
                            <xsl:variable name="temp">
                                <xsl:perform-sort select="string-join(distinct-values(current-group()/@subtype[. ne '']), '-')">
                                    <xsl:sort select="."/>
                                </xsl:perform-sort>
                            </xsl:variable>
                            <xsl:value-of select="string-join($temp, '/')"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="current-group()[1]/@label">
                        <xsl:attribute name="label" select="current-group()[1]/@label"/>
                    </xsl:if>
                    <xsl:if test="current-group()[1]/@c">
                        <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                    </xsl:if>
                    <xsl:for-each-group select="current-group()/*:controlfield"
                                   group-by="string-join((@tag, @type, string(.)), '')">
                        <xsl:sort select="@tag"/>
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:copy-of select="@* except @c"/>
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                            <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                                <xsl:for-each select="distinct-values(current-group()/@i)">
                                    <frbrizer:mid>
                                        <xsl:attribute name="i" select="."/>
                                    </frbrizer:mid>
                                </xsl:for-each>
                            </xsl:for-each-group>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:datafield"
                                   group-by="normalize-space(string-join(((@tag), @type,                             (if ($ignore_indicators_in_merge) then                                 ()                             else                                 (@ind1, @ind2)), *:subfield/@code, *:subfield/@type, *:subfield/text()), ''))">
                        <xsl:sort select="@tag"/>
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:copy-of select="current-group()[1]/@tag"/>
                            <xsl:copy-of select="current-group()[1]/@ind1"/>
                            <xsl:copy-of select="current-group()[1]/@ind2"/>
                            <xsl:copy-of select="current-group()[1]/@type"/>
                            <xsl:copy-of select="current-group()[1]/@subtype"/>
                            <xsl:copy-of select="current-group()[1]/@label"/>
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:for-each-group select="current-group()/*:subfield"
                                         group-by="concat(@code, @type, text())">
                                <xsl:sort select="@code"/>
                                <xsl:sort select="@type"/>
                                <xsl:for-each select="distinct-values(current-group()/text())">
                                    <xsl:element name="{name(current-group()[1])}"
                                        namespace="{namespace-uri(current-group()[1])}">
                                        <xsl:copy-of select="current-group()[1]/@code"/>
                                        <xsl:copy-of select="current-group()[1]/@type"/>
                                        <xsl:copy-of select="current-group()[1]/@subtype"/>
                                        <xsl:if test="current-group()[1]/@label">
                                            <xsl:copy-of select="current-group()[1]/@label"/>
                                        </xsl:if>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:for-each-group>
                            <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                                <xsl:for-each select="distinct-values(current-group()/@i)">
                                    <xsl:element name="{name(current-group()[1])}"
                                        namespace="{namespace-uri(current-group()[1])}">
                                        <xsl:attribute name="i" select="."/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:for-each-group>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:relationship"
                                   group-by="concat(@type, @href, @subtype)">
                        <xsl:sort select="@type"/>
                        <xsl:sort select="@subtype"/>
                        <xsl:sort select="@id"/>
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:copy-of select="@* except (@c | @ilabel | @itype | @isubtype)"/>
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:for-each-group select="current-group()/*:mid" group-by="@i">
                                <xsl:for-each select="distinct-values(current-group()/@i)">
                                    <xsl:element name="{name(current-group()[1])}"
                                        namespace="{namespace-uri(current-group()[1])}">
                                        <xsl:attribute name="i" select="."/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:for-each-group>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:template" group-by=".">
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/mid" group-by="@i">
                        <xsl:for-each select="distinct-values(current-group()/@i)">
                            <xsl:element name="{name(current-group()[1])}"
                                  namespace="{namespace-uri(current-group()[1])}">
                                <xsl:attribute name="i" select="."/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:anchorvalue" group-by=".">
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:idvalue" group-by="@id">
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:if test="current-group()[1]/@id">
                                <xsl:copy-of select="current-group()/@id"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:source" group-by=".">
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:keyvalue" group-by=".">
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:label" group-by=".">
                        <xsl:element name="{name(current-group()[1])}"
                               namespace="{namespace-uri(current-group()[1])}">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="normalize-space(current-group()[1])"/>
                        </xsl:element>
                    </xsl:for-each-group>
                    <xsl:for-each-group select="current-group()/*:intkey" group-by=".">
                        <xsl:element name="intkey">
                            <xsl:if test="current-group()[1]/@c">
                                <xsl:attribute name="c" select="sum(current-group()/@c)"/>
                            </xsl:if>
                            <xsl:value-of select="current-group()[1]"/>
                        </xsl:element>
                    </xsl:for-each-group>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
   <xsl:template xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 match="/*:collection"
                 mode="rdfify"
                 name="rdfify">
        <xsl:variable name="collection" select="."/>
        <rdf:RDF>
            <xsl:for-each select="in-scope-prefixes($collection)">
                <xsl:variable name="prefix" select="."/>
                <xsl:variable name="uri" select="namespace-uri-for-prefix(., $collection)"/>
                <xsl:if test="$prefix ne '' and not(starts-with($prefix, 'xs'))">
                    <xsl:namespace name="{$prefix}" select="$uri"/>
                </xsl:if>
            </xsl:for-each>
            <xsl:variable name="prefixmap"
                       select="map:merge(for $i in in-scope-prefixes($collection) return map{namespace-uri-for-prefix($i, $collection) : $i})"/>
            
            <xsl:for-each-group select="//*:record[starts-with(@type, 'http')]"
                             group-by="@id, @type"
                             composite="yes">
                <!--<xsl:sort select="@type"/>
                <xsl:sort select="@id"/>-->
                <!--<xsl:variable name="namespace" select="tokenize(@type, '[/#]')[last() - 1]"/>-->
                <xsl:try>
                    <xsl:variable name="entity_type" select="tokenize(@type, '[/#]')[last()]"/>
                    <xsl:variable name="entity_namespace" select="replace(@type, $entity_type, '')"/>
                    <xsl:element name="{$prefixmap($entity_namespace) || ':' || $entity_type}"
                            namespace="{$entity_namespace}">
                        <xsl:attribute name="rdf:about"
                                 select="if (starts-with(@id, 'http')) then @id else 'http://example.org/'||@id"/>
                        <xsl:for-each-group select="current-group()//(*:subfield, *:controlfield)[starts-with(@type, 'http')]"
                                      group-by="@type, replace(lower-case(text()), '[^A-Za-z0-9]', '')"
                                      composite="yes">
                            <xsl:variable name="property_type" select="tokenize(@type, '[/#]')[last()]"/>
                            <xsl:variable name="property_namespace" select="replace(@type, $property_type, '')"/>
                            <xsl:element name="{$prefixmap($property_namespace) || ':' || $property_type}"
                                  namespace="{$property_namespace}">
                                <xsl:copy-of select="current-group()[1]/text()"/>
                            </xsl:element>
                        </xsl:for-each-group>
                        <xsl:for-each-group select="current-group()/*:relationship[starts-with(@type, 'http')]"
                                      group-by="@type, @href"
                                      composite="yes">
                            <xsl:sort select="@type"/>
                            <xsl:variable name="property_type" select="tokenize(@type, '[/#]')[last()]"/>
                            <xsl:variable name="property_namespace" select="replace(@type, $property_type, '')"/>
                            <xsl:element name="{$prefixmap($property_namespace) || ':' || $property_type}"
                                  namespace="{$property_namespace}">
                                <xsl:attribute name="rdf:resource"
                                       select="if(starts-with(current-group()[1]/@href, 'http')) then current-group()[1]/@href else 'http://example.org/'||current-group()[1]/@href"/>
                            </xsl:element>                        
                        </xsl:for-each-group>
                    </xsl:element>
                    <xsl:catch>
                        <xsl:result-document href="error.log" omit-xml-declaration="yes">
                            <xsl:message terminate="no">
                                <xsl:value-of select="'Error converting to rdf in record:'"/>
                                <xsl:value-of select="./*:controlfield[@tag='001']"/>                            
                            </xsl:message>
                        </xsl:result-document>
                    </xsl:catch>
                </xsl:try>
            </xsl:for-each-group>
            <!--<xsl:for-each select="doc('rda.inverse.rdf')/rdf:RDF/rdf:Description">
                <xsl:copy-of select="."></xsl:copy-of>
            </xsl:for-each>-->
            <xsl:for-each select="doc('rda.labels.rdf')/rdf:RDF/rdf:Description">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 name="local:sort-keys">
        <xsl:param name="keys"/>
        <xsl:perform-sort select="distinct-values($keys)">
            <xsl:sort select="."/>
        </xsl:perform-sort>
    </xsl:function>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 name="local:sort-relationships">
        <xsl:param name="relationships"/>
        <xsl:perform-sort select="$relationships">
            <xsl:sort select="@id"/>
        </xsl:perform-sort>
    </xsl:function>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 name="local:trimsort-targets">
        <xsl:param name="relationships"/>
        <xsl:perform-sort select="for $r in distinct-values($relationships) return local:trim-target($r)">
            <xsl:sort select="."/>
        </xsl:perform-sort>
    </xsl:function>
   <xsl:function xmlns:local="http://idi.ntnu.no/frbrizer/"
                 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 name="local:trim-target">
        <!-- This function transforms a list of uris to a list of strings containing the last part of the uri-->
        <xsl:param name="value" as="xs:string"/>
        <xsl:value-of select="let $x := $value return if (matches($x, '\w+:(/?/?)[^\s]+')) then (tokenize(replace($x, '/$', ''), '/'))[last()] else $x"/>
    </xsl:function>
   <xsl:function xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:rdac="http://rdaregistry.info/Elements/c/"
                 xmlns:rdaa="http://rdaregistry.info/Elements/a/"
                 xmlns:rdaw="http://rdaregistry.info/Elements/w/"
                 xmlns:rdae="http://rdaregistry.info/Elements/e/"
                 xmlns:rdam="http://rdaregistry.info/Elements/m/"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                 xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                 xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                 xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 name="frbrizer:validateURI">
            <xsl:param name="uri"/>
            <xsl:param name="field"/>
            <xsl:choose>
                <xsl:when test="xs:anyURI($uri) and starts-with($uri, 'http')">
                    <xsl:value-of select="$uri"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no">Emty or invalid URI '<xsl:value-of select="$uri"/>' in field <xsl:value-of select="$field"/>
            </xsl:message>
                    <xsl:value-of select="$uri"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:function>
   <xsl:function xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:rdac="http://rdaregistry.info/Elements/c/"
                 xmlns:rdaa="http://rdaregistry.info/Elements/a/"
                 xmlns:rdaw="http://rdaregistry.info/Elements/w/"
                 xmlns:rdae="http://rdaregistry.info/Elements/e/"
                 xmlns:rdam="http://rdaregistry.info/Elements/m/"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                 xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                 xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                 xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 name="frbrizer:linked"
                 as="xs:boolean">
            <!-- returns true if the two fields have the same marc 21 link ($8), or if there is no linking subfields in target or source -->
            <xsl:param name="anchor" as="element()"/>
            <xsl:param name="target" as="element()"/>
            <xsl:sequence select="(some $x in $anchor/*:subfield[@code = '8'] satisfies $x = $target/*:subfield[@code = '8']) or (not(exists($anchor/*:subfield[@code = '8'])) or not(exists($target/*:subfield[@code='8'])))"/>  
            <!--xsl:value-of select="(some $x in $anchor/*:subfield[@code = '8'] satisfies $x = $target/*:subfield[@code = '8']) or (not(exists($target/*:subfield[@code = '8'])))"/>-->
        </xsl:function>
   <xsl:function xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:rdac="http://rdaregistry.info/Elements/c/"
                 xmlns:rdaa="http://rdaregistry.info/Elements/a/"
                 xmlns:rdaw="http://rdaregistry.info/Elements/w/"
                 xmlns:rdae="http://rdaregistry.info/Elements/e/"
                 xmlns:rdam="http://rdaregistry.info/Elements/m/"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                 xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                 xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                 xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 name="frbrizer:linked-or-nolink"
                 as="xs:boolean">
            <!-- returns true if the two fields have the same marc 21 link ($8), or if there is no linking subfields in target and source -->
            <xsl:param name="anchor" as="element()"/>
            <xsl:param name="target" as="element()"/>
            <xsl:sequence select="(some $x in $anchor/*:subfield[@code = '8'] satisfies $x = $target/*:subfield[@code = '8']) or ((not(exists($anchor/*:subfield[@code = '8'])) and not(exists($target/*:subfield[@code='8']))))"/>  
        </xsl:function>
   <xsl:function xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:rdac="http://rdaregistry.info/Elements/c/"
                 xmlns:rdaa="http://rdaregistry.info/Elements/a/"
                 xmlns:rdaw="http://rdaregistry.info/Elements/w/"
                 xmlns:rdae="http://rdaregistry.info/Elements/e/"
                 xmlns:rdam="http://rdaregistry.info/Elements/m/"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                 xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                 xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                 xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 name="frbrizer:linked-strict"
                 as="xs:boolean">
            <!-- returns true if the two fields have the same marc 21 link ($8) -->
            <xsl:param name="anchor" as="element()*"/>
            <xsl:param name="target" as="element()*"/>
            <xsl:sequence select="some $x in $anchor/*:subfield[@code = '8'] satisfies $x = $target/*:subfield[@code = '8']"/>
        </xsl:function>
   <xsl:function xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:rdac="http://rdaregistry.info/Elements/c/"
                 xmlns:rdaa="http://rdaregistry.info/Elements/a/"
                 xmlns:rdaw="http://rdaregistry.info/Elements/w/"
                 xmlns:rdae="http://rdaregistry.info/Elements/e/"
                 xmlns:rdam="http://rdaregistry.info/Elements/m/"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                 xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                 xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                 xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 name="frbrizer:linked-semistrict"
                 as="xs:boolean">
            <!-- returns true if the two fields have the same marc 21 link ($8) -->
            <!-- returns true if the two fields have the same marc 21 link ($8), or if there is no linking subfields in target or source -->
            <xsl:param name="anchor" as="element()"/>
            <xsl:param name="target" as="element()"/>
            <xsl:sequence select="(some $x in $anchor/*:subfield[@code = '8'] satisfies $x = $target/*:subfield[@code = '8']) or (not(exists($anchor/*:subfield[@code = '8'])) and not(exists($target/*:subfield[@code='8'])))"/>  
        </xsl:function>
   <xsl:function xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:rdac="http://rdaregistry.info/Elements/c/"
                 xmlns:rdaa="http://rdaregistry.info/Elements/a/"
                 xmlns:rdaw="http://rdaregistry.info/Elements/w/"
                 xmlns:rdae="http://rdaregistry.info/Elements/e/"
                 xmlns:rdam="http://rdaregistry.info/Elements/m/"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                 xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                 xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                 xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 name="frbrizer:trim"
                 as="xs:string*">
            <xsl:param name="value" as="element()*"/>
            <xsl:for-each select="$value">
                <xsl:value-of select="replace(., '[ \.,/:]+$', '')"/>
            </xsl:for-each>
        </xsl:function>
   <xsl:function xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xmlns:rdac="http://rdaregistry.info/Elements/c/"
                 xmlns:rdaa="http://rdaregistry.info/Elements/a/"
                 xmlns:rdaw="http://rdaregistry.info/Elements/w/"
                 xmlns:rdae="http://rdaregistry.info/Elements/e/"
                 xmlns:rdam="http://rdaregistry.info/Elements/m/"
                 xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                 xmlns:rdaco="http://rdaregistry.info/termList/RDAContentType/"
                 xmlns:rdact="http://rdaregistry.info/termList/RDACarrierType/"
                 xmlns:rdamt="http://rdaregistry.info/termList/RDAMediaType/"
                 xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                 name="frbrizer:idprefix">
            <xsl:param name="value"/>
            <xsl:choose>
                <xsl:when test="$value = '0'">
                    <xsl:value-of select="'isrc'"/>
                </xsl:when>
                <xsl:when test="$value = '1'">
                    <xsl:value-of select="'upc'"/>
                </xsl:when>
                <xsl:when test="$value = '2'">
                    <xsl:value-of select="'ismn'"/>
                </xsl:when>
                <xsl:when test="$value = '3'">
                    <xsl:value-of select="'ian'"/>
                </xsl:when>
                <xsl:when test="$value = '4'">
                    <xsl:value-of select="'sici'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'nn'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:function>
</xsl:stylesheet>
