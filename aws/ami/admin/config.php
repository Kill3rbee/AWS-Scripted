<?php
/*
	*********************************************************************
	* LogAnalyzer - http://loganalyzer.adiscon.com
	* -----------------------------------------------------------------
	* Main Configuration File
	*
	* -> Configuration need variables for the Database connection
	*
	* Copyright (C) 2008-2010 Adiscon GmbH.
	*
	*********************************************************************
*/

// --- Avoid directly accessing this file! 
if ( !defined('IN_PHPLOGCON') ) {
	die('Hacking attempt');
	exit;
	}

$CFG['UserDBEnabled'] = false;
$CFG['UserDBServer'] = 'localhost';
$CFG['UserDBPort'] = 3306;
$CFG['UserDBName'] = 'loganalyzer'; 
$CFG['UserDBPref'] = 'logcon_'; 
$CFG['UserDBUser'] = 'root';
$CFG['UserDBPass'] = '';
$CFG['UserDBLoginRequired'] = false;
$CFG['UserDBAuthMode'] = 0;

$CFG['LDAPServer'] = '127.0.0.1';
$CFG['LDAPPort'] = 389;
$CFG['LDAPBaseDN'] = 'CN=Users,DC=domain,DC=local';
$CFG['LDAPSearchFilter'] = '(objectClass=user)';
$CFG['LDAPUidAttribute'] = 'sAMAccountName';
$CFG['LDAPBindDN'] = 'CN=Searchuser,CN=Users,DC=domain,DC=local';
$CFG['LDAPBindPassword'] = 'Password';

$CFG['MiscShowDebugMsg'] = 0;
$CFG['MiscDebugToSyslog'] = 0;
$CFG['MiscShowDebugGridCounter'] = 0;
$CFG["MiscShowPageRenderStats"] = 1;
$CFG['MiscEnableGzipCompression'] = 1;
$CFG['MiscMaxExecutionTime'] = 60;
$CFG['DebugUserLogin'] = 0;

$CFG['PrependTitle'] = "";
$CFG['ViewUseTodayYesterday'] = 1;
$CFG['ViewMessageCharacterLimit'] = 0;
$CFG['ViewStringCharacterLimit'] = 0;
$CFG['ViewEntriesPerPage'] = 100;
$CFG['ViewEnableDetailPopups'] = 0;
$CFG['ViewDefaultTheme'] = "default";
$CFG['ViewDefaultLanguage'] = "en";
$CFG['ViewEnableAutoReloadSeconds'] = 0;

$CFG['SearchCustomButtonCaption'] = "I'd like to feel sad";
$CFG['SearchCustomButtonSearch'] = "error";

$CFG['EnableContextLinks'] = 0;
$CFG['EnableIPAddressResolve'] = 0;
$CFG['SuppressDuplicatedMessages'] = 0;
$CFG['TreatNotFoundFiltersAsTrue'] = 0;
$CFG['PopupMenuTimeout'] = 3000;
$CFG['PhplogconLogoUrl'] = "";
$CFG['InlineOnlineSearchIcons'] = 1;
$CFG['UseProxyServerForRemoteQueries'] = "";
$CFG['HeaderDefaultEncoding'] = ENC_ISO_8859_1;

$CFG['InjectHtmlHeader'] = "";
$CFG['InjectBodyHeader'] = "";
$CFG['InjectBodyFooter'] = "";

$CFG['DefaultViewsID'] = "";

$CFG['Search'][] = array ( "DisplayName" => "Syslog Warnings and Errors", "SearchQuery" => "filter=severity%3A0%2C1%2C2%2C3%2C4&search=Search" );
$CFG['Search'][] = array ( "DisplayName" => "Syslog Errors", "SearchQuery" => "filter=severity%3A0%2C1%2C2%2C3&search=Search" );
$CFG['Search'][] = array ( "DisplayName" => "All messages from the last hour", "SearchQuery" => "filter=datelastx%3A1&search=Search" );
$CFG['Search'][] = array ( "DisplayName" => "All messages from last 12 hours", "SearchQuery" => "filter=datelastx%3A2&search=Search" );
$CFG['Search'][] = array ( "DisplayName" => "All messages from last 24 hours", "SearchQuery" => "filter=datelastx%3A3&search=Search" );
$CFG['Search'][] = array ( "DisplayName" => "All messages from last 7 days", "SearchQuery" => "filter=datelastx%3A4&search=Search" );
$CFG['Search'][] = array ( "DisplayName" => "All messages from last 31 days", "SearchQuery" => "filter=datelastx%3A5&search=Search" );

$CFG['Charts'][] = array ( "DisplayName" => "Top Hosts", "chart_type" => CHART_BARS_HORIZONTAL, "chart_width" => 400, "chart_field" => SYSLOG_HOST, "maxrecords" => 10, "showpercent" => 0, "chart_enabled" => 1 );
$CFG['Charts'][] = array ( "DisplayName" => "SyslogTags", "chart_type" => CHART_CAKE, "chart_width" => 400, "chart_field" => SYSLOG_SYSLOGTAG, "maxrecords" => 10, "showpercent" => 0, "chart_enabled" => 1 );
$CFG['Charts'][] = array ( "DisplayName" => "Severity Occurences", "chart_type" => CHART_BARS_VERTICAL, "chart_width" => 400, "chart_field" => SYSLOG_SEVERITY, "maxrecords" => 10, "showpercent" => 1, "chart_enabled" => 1 );
$CFG['Charts'][] = array ( "DisplayName" => "Usage by Day", "chart_type" => CHART_CAKE, "chart_width" => 400, "chart_field" => SYSLOG_DATE, "maxrecords" => 10, "showpercent" => 1, "chart_enabled" => 1 );

$CFG['DiskAllowed'][] = "/var/log/"; 

$CFG['DefaultSourceID'] = 'Source1';

$CFG['Sources']['Source1']['ID'] = 'Source1';
$CFG['Sources']['Source1']['Name'] = 'Syslog';
$CFG['Sources']['Source1']['ViewID'] = 'SYSLOG';
$CFG['Sources']['Source1']['SourceType'] = SOURCE_DISK;
$CFG['Sources']['Source1']['LogLineType'] = 'syslog';
$CFG['Sources']['Source1']['DiskFile'] = '/var/log/messages';

$CFG['Sources']['Source2']['ID'] = 'Source2';
$CFG['Sources']['Source2']['Name'] = 'Admin Httpd Error';
$CFG['Sources']['Source2']['ViewID'] = 'SYSLOG';
$CFG['Sources']['Source2']['SourceType'] = SOURCE_DISK;
$CFG['Sources']['Source2']['LogLineType'] = 'syslog';
$CFG['Sources']['Source2']['DiskFile'] = '/var/log/adminhttpderr.log';

$CFG['Sources']['Source3']['ID'] = 'Source3';
$CFG['Sources']['Source3']['Name'] = 'Web Httpd Error';
$CFG['Sources']['Source3']['ViewID'] = 'SYSLOG';
$CFG['Sources']['Source3']['SourceType'] = SOURCE_DISK;
$CFG['Sources']['Source3']['LogLineType'] = 'syslog';
$CFG['Sources']['Source3']['DiskFile'] = '/var/log/webhttpderr.log';

$CFG['Sources']['Source4']['ID'] = 'Source4';
$CFG['Sources']['Source4']['Name'] = 'JavaMail';
$CFG['Sources']['Source4']['ViewID'] = 'SYSLOG';
$CFG['Sources']['Source4']['SourceType'] = SOURCE_DISK;
$CFG['Sources']['Source4']['LogLineType'] = 'syslog';
$CFG['Sources']['Source4']['DiskFile'] = '/var/log/javamail.log';

$CFG['Sources']['Source5']['ID'] = 'Source5';
$CFG['Sources']['Source5']['Name'] = 'Admin Httpd';
$CFG['Sources']['Source5']['ViewID'] = 'WEBLOG';
$CFG['Sources']['Source5']['SourceType'] = SOURCE_DISK;
$CFG['Sources']['Source5']['LogLineType'] = 'syslog';
$CFG['Sources']['Source5']['DiskFile'] = '/var/log/adminhttpd.log';
$CFG['Sources']['Source5']['MsgParserList'] = "apache2";

$CFG['Sources']['Source6']['ID'] = 'Source6';
$CFG['Sources']['Source6']['Name'] = 'Web Httpd';
$CFG['Sources']['Source6']['ViewID'] = 'WEBLOG';
$CFG['Sources']['Source6']['SourceType'] = SOURCE_DISK;
$CFG['Sources']['Source6']['LogLineType'] = 'syslog';
$CFG['Sources']['Source6']['DiskFile'] = '/var/log/webhttpd.log';
$CFG['Sources']['Source6']['MsgParserList'] = "apache2";

$CFG['Sources']['Source7']['ID'] = 'Source7';
$CFG['Sources']['Source7']['Name'] = 'PHP At A Glance';
$CFG['Sources']['Source7']['ViewID'] = 'SYSLOG';
$CFG['Sources']['Source7']['SourceType'] = SOURCE_DISK;
$CFG['Sources']['Source7']['LogLineType'] = 'syslog';
$CFG['Sources']['Source7']['DiskFile'] = '/var/log/ataglance.log';

?>