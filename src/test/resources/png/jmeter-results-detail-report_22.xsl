<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

<!--
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at
 
       http://www.apache.org/licenses/LICENSE-2.0
 
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-->

<!-- 
	Stylesheet for processing 2.1 output format test result files 
	To uses this directly in a browser, add the following to the JTL file as line 2:
	<?xml-stylesheet type="text/xsl" href="../extras/jmeter-results-detail-report_21.xsl"?>
	and you can then view the JTL in a browser
-->

<xsl:output method="html" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" />

<!-- Defined parameters (overrideable)Load Test Results -->
<xsl:param    name="showData" select="'y'"/>
<xsl:param    name="titleReport" select="'Load Test Results'"/>
<xsl:param    name="dateReport" select="'date not defined'"/>

<xsl:template match="testResults">
	<html>
		<head>
			<title><xsl:value-of select="$titleReport" /></title>
			<style type="text/css">
				body {
					font:normal 68% verdana,arial,helvetica;
					color:#000000;
				}
				table tr td, table tr th {
					font-size: 68%;
				}
				table.details tr th{
				    color: #ffffff;
					font-weight: bold;
					text-align:center;
					background:#2674a6;
					white-space: nowrap;
				}
				table.details tr td{
					background:#eeeee0;
					white-space: nowrap;
				}
				h1 {
					margin: 0px 0px 5px; font: 165% verdana,arial,helvetica
				}
				h2 {
					margin-top: 1em; margin-bottom: 0.5em; font: bold 125% verdana,arial,helvetica
				}
				h3 {
					margin-bottom: 0.5em; font: bold 115% verdana,arial,helvetica
				}
				.Failure {
					font-weight:bold; color:red;
				}
				.LongTime {
                    font-weight:bold; color:#ff9900;
                }
				img
				{
				  border-width: 0px;
				}
				
				.expand_link
				{
				   position=absolute;
				   right: 0px;
				   width: 27px;
				   top: 1px;
				   height: 27px;
				}
				
				.page_details
				{
				   display: none;
				}
                                
                                .page_details_expanded
                                {
                                    display: block;
                                    display/* hide this definition from  IE5/6 */: table-row;
                                }


			</style>
			<script language="JavaScript"><![CDATA[
                           function expand(details_id)
			   {
			      
			      document.getElementById(details_id).className = "page_details_expanded";
			   }
			   
			   function collapse(details_id)
			   {
			      
			      document.getElementById(details_id).className = "page_details";
			   }
			   
			   function change(details_id)
			   {
			      if(document.getElementById(details_id+"_image").src.match("expand"))
			      {
			         document.getElementById(details_id+"_image").src = "collapse.png";
			         expand(details_id);
			      }
			      else
			      {
			         document.getElementById(details_id+"_image").src = "expand.png";
			         collapse(details_id);
			      } 
                           }
			]]></script>
		</head>
		<body>
		
			<xsl:call-template name="pageHeader" />
			
			<xsl:call-template name="summary" />
			<hr size="1" width="95%" align="center" />
			
			<xsl:call-template name="pagelist" />
			<hr size="1" width="95%" align="center" />
			
			<xsl:call-template name="detail" />

		</body>
	</html>
</xsl:template>

<xsl:template name="pageHeader">
	<h1><xsl:value-of select="$titleReport" /></h1>
	<h1>优购负载测试报告</h1>
	<table width="100%">
		<tr>
			<td align="left">Date report: <xsl:value-of select="$dateReport" /></td>
			<td align="right">Designed for use with <a href="http://jmeter.apache.org/">JMeter</a> and <a href="http://ant.apache.org">Ant</a>.</td>
		</tr>
	</table>
	<hr size="1" />
</xsl:template>

<xsl:template name="summary">
	<h2>Summary(概要)</h2>
	<table align="center" class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
		<tr valign="top">
			<th># Samples</th>
			<th>Failures</th>
			<th>Success Rate</th>
			<th>Average Time</th>
			<th>Min Time</th>
			<th>Max Time</th>
			<th>90%Line</th>
			<!--<th>QPS</th>-->
		</tr>
		<tr valign="top">
			<xsl:variable name="allCount" select="count(/testResults/*)" />
			<xsl:variable name="allFailureCount" select="count(/testResults/*[attribute::s='false'])" />
			<xsl:variable name="allSuccessCount" select="count(/testResults/*[attribute::s='true'])" />
			<xsl:variable name="allSuccessPercent" select="$allSuccessCount div $allCount" />
			<xsl:variable name="allTotalTime" select="sum(/testResults/*/@t)" />
			<xsl:variable name="allAverageTime" select="$allTotalTime div $allCount" />
			<xsl:variable name="allMinTime">
				<xsl:call-template name="min">
					<xsl:with-param name="nodes" select="/testResults/*/@t" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="allMaxTime">
				<xsl:call-template name="max">
					<xsl:with-param name="nodes" select="/testResults/*/@t" />
				</xsl:call-template>
			</xsl:variable>
			<!-- New add 90% line -->
            <xsl:variable name="allLineTime">
                <xsl:call-template name="lineTime">
                    <xsl:with-param name="nodes" select="/testResults/*/@t" />
                </xsl:call-template>
            </xsl:variable>
            <!-- 将毫秒转换成秒 -->
            <xsl:variable name="qps" select="$allCount * 1000 div $allTotalTime"/>
			<!--
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$allFailureCount &gt; 0">Failure</xsl:when>
			</xsl:attribute>
			-->
			<td align="center">
				<xsl:value-of select="$allCount" />
			</td>
			<xsl:choose>
				<xsl:when test="$allFailureCount &gt; 0">
					<td align="center" style="font-weight:bold">
						<font color="red">
							<xsl:value-of select="$allFailureCount" />
						</font>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<td align="center">
						<xsl:value-of select="$allFailureCount" />
					</td>
				</xsl:otherwise>
			</xsl:choose>
			<td align="center">
				<xsl:call-template name="display-percent">
					<xsl:with-param name="value" select="$allSuccessPercent" />
				</xsl:call-template>
			</td>
			<td align="center">
				<xsl:call-template name="display-time">
					<xsl:with-param name="value" select="$allAverageTime" />
				</xsl:call-template>
			</td>
			<td align="center">
				<xsl:call-template name="display-time">
					<xsl:with-param name="value" select="$allMinTime" />
				</xsl:call-template>
			</td>
			<td align="center">
				<xsl:call-template name="display-time">
					<xsl:with-param name="value" select="$allMaxTime" />
				</xsl:call-template>
			</td>
			            <td align="center">
                <xsl:call-template name="display-time">
                    <xsl:with-param name="value" select="$allLineTime" />
                </xsl:call-template>
            </td>
<!--
            <td align="center">
                <xsl:call-template name="display-qps">
                    <xsl:with-param name="value" select="$qps" />
                </xsl:call-template>
			</td>
-->	
	</tr>
	</table>
</xsl:template>

<xsl:template name="pagelist">
	<h2>Pages(列表)</h2>
	<table align="center" class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
<!--		<tr valign="top">
			<th>URL</th>
			<th># Samples</th>
			<th>Failures</th>
			<th>Success Rate</th>
			
			<th>Average Time</th>
			<th>Min Time</th>
			<th>Max Time</th>
			<th>90% Line</th>
			
			###
			<th>totalTime</th>
           		 <th>QPS</th>
			<th>Min TS</th>
			<th>Max TS</th>
			<th>Elapsed Time</th>
			 ###
			<th>TPS/QPS</th>
			<th>Throught</th>
			<th></th>
		</tr>
-->
		<tr valign="top">
			<th>用例名称</th>
			<th>总请求数量</th>
			<th>失败个数</th>
			<th>成功率</th>
			<th>平均响应时间</th>
			<th>最小响应时间</th>
			<th>最大响应时间</th>
			<th>90%响应时间</th>
			<th>每秒事务数</th>
			<th>吞吐量</th>
			<th></th>
		</tr>
		<xsl:for-each select="/testResults/*[not(@lb = preceding::*/@lb)]">
			<xsl:variable name="label" select="@lb" />
			<xsl:variable name="count" select="count(../*[@lb = current()/@lb])" />
			<xsl:variable name="failureCount" select="count(../*[@lb = current()/@lb][attribute::s='false'])" />
			<xsl:variable name="successCount" select="count(../*[@lb = current()/@lb][attribute::s='true'])" />
			<xsl:variable name="successPercent" select="$successCount div $count" />
			<xsl:variable name="totalTime" select="sum(../*[@lb = current()/@lb]/@t)" />
			<xsl:variable name="averageTime" select="$totalTime div $count" />
			<xsl:variable name="minTime">
				<xsl:call-template name="min">
					<xsl:with-param name="nodes" select="../*[@lb = current()/@lb]/@t" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="maxTime">
				<xsl:call-template name="max">
					<xsl:with-param name="nodes" select="../*[@lb = current()/@lb]/@t" />
				</xsl:call-template>
			</xsl:variable>
            <!-- new add 90% line time -->
            <xsl:variable name="nintyTime">
                <xsl:call-template name="lineTime">
                    <xsl:with-param name="nodes" select="../*[@lb = current()/@lb]/@t" />
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="qpsTime" select="$count * 1000 div $totalTime"/>
			
			<xsl:variable name="minTs">
				<xsl:call-template name="min">
					<xsl:with-param name="nodes" select="../*[@lb = current()/@lb]/@ts" />
				</xsl:call-template>
			</xsl:variable>

			<xsl:variable name="maxTs">
				<xsl:call-template name="max">
					<xsl:with-param name="nodes" select="../*[@lb = current()/@lb]/@ts" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="lastTimestamp">
				<xsl:call-template name="max">
					<xsl:with-param name="nodes" select="../*[@ts = $maxTs]/@t" />
				</xsl:call-template>
			</xsl:variable>
			
			<!--   ######################## TPS ########################   -->
			<xsl:variable name="TPS" select="$count*1000 div ($maxTs + $lastTimestamp - $minTs)" />
			<!--   ######################## THROUGHT ########################   -->
			<xsl:variable name="Throught" select="sum(/testResults/*[@lb = current()/@lb]/@by) div 1024 div ($maxTs + $lastTimestamp - $minTs)* 1000" />
			<tr valign="top">
				<xsl:choose>
					<!-- 失败用例标红显示 -->
					<xsl:when test="$failureCount &gt; 0">
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="$failureCount &gt; 0">Failure</xsl:when>
							</xsl:choose>
						</xsl:attribute>
	          		</xsl:when>
					<!-- 平均时间超过1s，标色显示 -->
					<xsl:when test="$averageTime &gt; 1000">
						<xsl:attribute name="class">
							<xsl:choose>
								<xsl:when test="$averageTime &gt; 1000">LongTime</xsl:when>
							</xsl:choose>
						</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<!--</xsl:attribute>-->
				<td>
				<xsl:if test="$failureCount > 0">
				  <a><xsl:attribute name="href">#<xsl:value-of select="$label" /></xsl:attribute>
				  <xsl:value-of select="$label" />
				  </a>
				</xsl:if>
				<xsl:if test="0 >= $failureCount">
				  <xsl:value-of select="$label" />
				</xsl:if>
				</td>
				<td align="center">
					<xsl:value-of select="$count" />
				</td>
				<td align="center">
					<xsl:value-of select="$failureCount" />
				</td>
				<td align="right">
					<xsl:call-template name="display-percent">
						<xsl:with-param name="value" select="$successPercent" />
					</xsl:call-template>
				</td>

				<td align="right">
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$averageTime" />
					</xsl:call-template>
				</td>
				<td align="right">
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$minTime" />
					</xsl:call-template>
				</td>
				<td align="right">
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$maxTime" />
					</xsl:call-template>
				</td>
				                <!-- Page页面添加90% LineTime -->
                <td align="center">
                    <xsl:call-template name="display-time">
                        <xsl:with-param name="value" select="$nintyTime" />
                    </xsl:call-template>
                </td>
				<!-- 
				<td align="right">
					<xsl:call-template name="display-totalTime">
						<xsl:with-param name="value" select="$totalTime" />
					</xsl:call-template>
				</td>
                <td align="center">
                    <xsl:call-template name="display-qps">
                        <xsl:with-param name="value" select="$qpsTime" />
                    </xsl:call-template>
                </td>
				 
				<td align="right">
					<xsl:call-template name="display-totalTime">
						<xsl:with-param name="value" select="$minTs" />
					</xsl:call-template>
				</td>
				<td align="right">
					<xsl:call-template name="display-totalTime">
						<xsl:with-param name="value" select="$maxTs" />
					</xsl:call-template>
				</td>
				
				<td align="right">
					<xsl:call-template name="display-totalTime">
						<xsl:with-param name="value" select="$lastTimestamp" />
					</xsl:call-template>
				</td>
				-->
				<!-- -->
				<!--   ######################## TPS ########################   -->
				<td align="right">
					<xsl:call-template name="display-qps">
						<xsl:with-param name="value" select="$TPS" />
					</xsl:call-template>
				</td>
				<!--   ######################## Throught ########################   -->
				<td align="right">
					<xsl:call-template name="display-kbs">
						<xsl:with-param name="value" select="$Throught" />
					</xsl:call-template>
				</td>
				<td align="center">
				   <a href="">
				      <xsl:attribute name="href"><xsl:text/>javascript:change('page_details_<xsl:value-of select="position()" />')</xsl:attribute>
				      <img src="expand.png" alt="expand/collapse"><xsl:attribute name="id"><xsl:text/>page_details_<xsl:value-of select="position()" />_image</xsl:attribute></img>				      
				   </a>
				</td>
			</tr>
			
                        <tr class="page_details">
                           <xsl:attribute name="id"><xsl:text/>page_details_<xsl:value-of select="position()" /></xsl:attribute>
                           <td colspan="8" bgcolor="#FF0000">
                              <div align="center">
			         <b>Details for Page "<xsl:value-of select="$label" />"</b>
			         <table bordercolor="#000000" bgcolor="#2674A6" border="0"  cellpadding="1" cellspacing="1" width="95%">
			         <tr>
			            <th>Thread</th>
			            <th>Iteration</th>
			            <th>Time (milliseconds)</th>
			            <th>Bytes</th>
			            <th>Success</th>
			         </tr>
			         		         
			         <xsl:for-each select="../*[@lb = $label and @tn != $label]">			         			            
			            <tr>
			               <td><xsl:value-of select="@tn" /></td>
			               <td align="center"><xsl:value-of select="position()" /></td>
			               <td align="right"><xsl:value-of select="@t" /></td>
			               <!--  TODO allow for missing bytes field -->
			               <td align="right"><xsl:value-of select="@by" /></td>
			               <td align="center"><xsl:value-of select="@s" /></td>
			            </tr>
			         </xsl:for-each>
			         
			         </table>
			      </div>
                           </td>
                        </tr>
			
		</xsl:for-each>
	</table>
</xsl:template>


<xsl:template name="detail">
	<xsl:variable name="allFailureCount" select="count(/testResults/*[attribute::s='false'])" />

	<xsl:if test="$allFailureCount > 0">
		<h2>Failure Detail</h2>

		<xsl:for-each select="/testResults/*[not(@lb = preceding::*/@lb)]">

			<xsl:variable name="failureCount" select="count(../*[@lb = current()/@lb][attribute::s='false'])" />

			<xsl:if test="$failureCount > 0">
				<h3><xsl:value-of select="@lb" /><a><xsl:attribute name="name"><xsl:value-of select="@lb" /></xsl:attribute></a></h3>

				<table class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
				<tr valign="top">
					<th align="center">Response</th>
					<th align="center">Failure Message</th>
					<xsl:if test="$showData = 'y'">
						<th align="left">Response Data</th>
					</xsl:if>
				</tr>
			
				<xsl:for-each select="/testResults/*[@lb = current()/@lb][attribute::s='false']">
					<tr>
						<td><xsl:value-of select="@rc | @rs" /> - <xsl:value-of select="@rm" /></td>
						<td><xsl:value-of select="assertionResult/failureMessage" /></td>
						
						<xsl:if test="$showData = 'y'">
							<td><xsl:value-of select="responseData" /></td>
						</xsl:if>
						
					</tr>
				</xsl:for-each>
				
				</table>
			</xsl:if>

		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template name="min">
	<xsl:param name="nodes" select="/.." />
	<xsl:choose>
		<xsl:when test="not($nodes)">NaN</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$nodes">
				<xsl:sort data-type="number" />
				<xsl:if test="position() = 1">
					<xsl:value-of select="number(.)" />
				</xsl:if>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="max">
	<xsl:param name="nodes" select="/.." />
	<xsl:choose>
		<xsl:when test="not($nodes)">NaN</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$nodes">
				<xsl:sort data-type="number" order="descending" />
				<xsl:if test="position() = 1">
					<xsl:value-of select="number(.)" />
				</xsl:if>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- lastT
<xsl:template name="lastTimestamp">
	<xsl:param name="nodes" select="/.." />
	<xsl:choose>
		<xsl:when test="not($nodes)">NaN</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$nodes">
				<xsl:sort data-type="number" order="descending" />
				<xsl:if test="position() = 1">
					<xsl:variable name="maxTime" select="../*[@lb = current()/@lb]/@ts"/>
						<xsl:if test="$maxTime>=$maxTs">
							<xsl:value-of select="number(.)" />
						</xsl:if>
					<xsl:value-of select="number(.)" />
				</xsl:if>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template> -->
<!-- 90% line time -->
<xsl:template name="lineTime">
    <xsl:param name="nodes" select="/.." />
    <xsl:choose>
        <xsl:when test="not($nodes)">NaN</xsl:when>
        <xsl:otherwise>
            <xsl:for-each select="$nodes">
                <xsl:sort data-type="number" />
                <!-- last() 返回当前上下文中的最后一个节点位置数 -->
                <!-- ceiling(number) 返回大于number的最小整数 -->
                <!-- floor(number) 返回不大于number的最大整数 -->
                <!-- position() 返回当前节点位置的数字 -->
                <!-- number(object) 使对象转换成数字 -->
                <xsl:choose>
                    <!-- 当只有一个节点时，向上取整 -->
                    <xsl:when test="last() = 1">
                        <xsl:if test="position() = ceiling(last()*0.9)">
                            <xsl:value-of select="number(.)" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="position() = floor(last()*0.9)">
                            <xsl:value-of select="number(.)" />
                        </xsl:if>
                      </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>
<xsl:template name="display-percent">
	<xsl:param name="value" />
	<xsl:value-of select="format-number($value,'0.00%')" />
</xsl:template>
<xsl:template name="display-totalTime">
	<xsl:param name="value" />
	<xsl:value-of select="format-number($value,'0')" />
</xsl:template>


<xsl:template name="display-time">
	<xsl:param name="value" />
	<xsl:value-of select="format-number($value,'0 ms')" />
</xsl:template>

<xsl:template name="display-qps">
	<xsl:param name="value" />
	<xsl:value-of select="format-number($value,'0.00/s')" />
</xsl:template>

<xsl:template name="display-kbs">
	<xsl:param name="value" />
	<xsl:value-of select="format-number($value,'0.00kb/s')" />
</xsl:template>
</xsl:stylesheet>
