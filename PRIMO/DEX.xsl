<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<html> 

<head style="font-family:Verdana;font-size:9pt">
<style>
table, th, td {
    border: 1px solid ltgray;
    border-collapse: collapse;
    padding: 8px;
	font-size: 8pt
}
th {
    background-color: #0080cd;
    color: white;
}
tr:nth-child(even) {background-color: #f2f2f2;}
tr:hover {background-color: #c5c5c5;}
div {
    background-color: #f2f2f2;
    width: 1024px;
    border: 5px solid #f2f2f2;
    padding:5px;
    margin: 5px;
}
.tab { 
       display:inline-block; 
       margin-left: 40px; 
}

</style>
  <div>
	<img src="c:\primo\icons\logo-bird.ico" style="float:left;width:92px;height:92px;"/>
	  <h2> <span class="tab"> PRIMO Data Exchange (XML) File</span> </h2>
      <xsl:for-each select="PRIMODataExchangeFile/Prefix">
	  <p> <span class="tab">
	    <xsl:text> Created on </xsl:text> 
	    <xsl:value-of select="creation_date"/> 
	    <xsl:text> at </xsl:text> 
	    <xsl:value-of select="creation_time"/> 
	    <xsl:text> with PRIMO version </xsl:text> 
	    <xsl:value-of select="primo_version"/> 
	  </span></p>
	  <p></p>
      <br></br>
    </xsl:for-each>
  </div>
</head>  

<body 
  style="font-family:Verdana;font-size:9pt">
  
  <xsl:for-each select="PRIMODataExchangeFile/Prefix">
  	<p></p>
    <br></br>
    <b><xsl:text> Reference Project: </xsl:text></b> <xsl:value-of select="ProjectName"/> <br></br>
    <b><xsl:text> External  Project: </xsl:text></b> <xsl:value-of select="exProjectName"/> <br></br>
    <b><xsl:text> Processing  Macro: </xsl:text></b> <xsl:value-of select="MacroName"/> <p></p>
  </xsl:for-each>
  <table >
    <tr>
      <th style="text-align:left">Result type</th>
      <th style="text-align:left">Region id</th>
      <th style="text-align:left">Region type</th>
      <th style="text-align:left">Dose mode</th>
      <th style="text-align:left">Setting(0)</th>
      <th style="text-align:left">Setting(1)</th>
      <th style="text-align:left">Setting(2)</th>
      <th style="text-align:left">Setting(3)</th>
      <th style="text-align:left">Setting(4)</th>
      <th style="text-align:left">Result(0)</th>
      <th style="text-align:left">Result(1)</th>
      <th style="text-align:left">Result(2)</th>
      <th style="text-align:left">Result(3)</th>
      <th style="text-align:left">Result(4)</th>
    </tr>
    <xsl:for-each select="PRIMODataExchangeFile/Table">
    <tr>
      <td style="text-align:left"><xsl:value-of select="data_type"/></td>
      <td style="text-align:left"><xsl:value-of select="region_id"/></td>
      <td style="text-align:left"><xsl:value-of select="region_type"/></td>
      <td style="text-align:left"><xsl:value-of select="dose_mode"/></td>
      <td style="text-align:left"><xsl:value-of select="setting-0"/></td>
      <td style="text-align:left"><xsl:value-of select="setting-1"/></td>
      <td style="text-align:left"><xsl:value-of select="setting-2"/></td>
      <td style="text-align:left"><xsl:value-of select="setting-3"/></td>
      <td style="text-align:left"><xsl:value-of select="setting-4"/></td>
      <td style="text-align:left"><xsl:value-of select="result-0"/></td>
      <td style="text-align:left"><xsl:value-of select="result-1"/></td>
      <td style="text-align:left"><xsl:value-of select="result-2"/></td>
      <td style="text-align:left"><xsl:value-of select="result-3"/></td>
      <td style="text-align:left"><xsl:value-of select="result-4"/></td>
    </tr>
    </xsl:for-each>
  </table>
</body>
</html>
</xsl:template>
</xsl:stylesheet>

