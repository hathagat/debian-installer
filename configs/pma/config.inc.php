<?php
/* vim: set expandtab sw=4 ts=4 sts=4: */
/**
 * phpMyAdmin sample configuration, you can use it as base for
 * manual configuration. For easier setup you can use setup/
 *
 * All directives are explained in documentation in the doc/ folder
 * or at <https://docs.phpmyadmin.net/>.
 *
 * @package PhpMyAdmin
 */

/**
 * This is needed for cookie based authentication to encrypt password in
 * cookie. Needs to be 32 chars long.
 */
$cfg['blowfish_secret'] = 'PMA_BFSECURE_PASS'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */

/**
 * Servers configuration
 */
$i = 0;

/**
 * First server
 */
$i++;
/* Authentication type */
$cfg['Servers'][$i]['auth_type'] = 'cookie';
/* Server parameters */
$cfg['Servers'][$i]['host'] = 'MYSQL_HOSTNAME';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;

/**
 * phpMyAdmin configuration storage settings.
 */

/* User used to manipulate with storage */
// $cfg['Servers'][$i]['controlhost'] = '';
// $cfg['Servers'][$i]['controlport'] = '';
$cfg['Servers'][$i]['controluser'] = 'MYSQL_PMADB_USER';
$cfg['Servers'][$i]['controlpass'] = 'PMADB_PASS';

/* Storage database and tables */
$cfg['Servers'][$i]['pmadb'] = 'MYSQL_PMADB_NAME';
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
$cfg['Servers'][$i]['favorite'] = 'pma__favorite';
$cfg['Servers'][$i]['users'] = 'pma__users';
$cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
$cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
$cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
$cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
$cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
$cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';

/**
 * End of servers configuration
 */

/**
 * Directories for saving/loading files from server
 */
$cfg['UploadDir'] = 'upload';
$cfg['SaveDir'] = 'save';

/**
 * Whether to display icons or text or both icons and text in table row
 * action segment. Value can be either of 'icons', 'text' or 'both'.
 * default = 'both'
 */
//$cfg['RowActionType'] = 'icons';

/**
 * Defines whether a user should be displayed a "show all (records)"
 * button in browse mode or not.
 * default = false
 */
//$cfg['ShowAll'] = true;

/**
 * Number of rows displayed when browsing a result set. If the result
 * set contains more rows, "Previous" and "Next".
 * Possible values: 25, 50, 100, 250, 500
 * default = 25
 */
//$cfg['MaxRows'] = 50;

/**
 * Disallow editing of binary fields
 * valid values are:
 *   false    allow editing
 *   'blob'   allow editing except for BLOB fields
 *   'noblob' disallow editing except for BLOB fields
 *   'all'    disallow editing
 * default = 'blob'
 */
//$cfg['ProtectBinary'] = false;

/**
 * Default language to use, if not browser-defined or user-defined
 * (you find all languages in the locale folder)
 * uncomment the desired line:
 * default = 'en'
 */
$cfg['DefaultLang'] = 'en';
//$cfg['DefaultLang'] = 'de';

/**
 * How many columns should be used for table display of a database?
 * (a value larger than 1 results in some information being hidden)
 * default = 1
 */
//$cfg['PropertiesNumColumns'] = 2;

/**
 * Set to true if you want DB-based query history.If false, this utilizes
 * JS-routines to display query history (lost by window close)
 *
 * This requires configuration storage enabled, see above.
 * default = false
 */
//$cfg['QueryHistoryDB'] = true;

/**
 * When using DB-based query history, how many entries should be kept?
 * default = 25
 */
//$cfg['QueryHistoryMax'] = 100;

/**
 * Whether or not to query the user before sending the error report to
 * the phpMyAdmin team when a JavaScript error occurs
 *
 * Available options
 * ('ask' | 'always' | 'never')
 * default = 'ask'
 */
//$cfg['SendErrorReports'] = 'always';

/**
 * Set the number of seconds a script is allowed to run.
 * If seconds is set to zero, no time limit is imposed.
 * This setting is used while importing/exporting dump files but has no effect when PHP is running in safe mode.
 */
 $cfg['ExecTimeLimit'] = '300';

/**
 * Enables check for latest versions using JavaScript on the main phpMyAdmin page or by directly accessing version_check.php.
 */
 $cfg['VersionCheck'] = 'false';

/**
 * Defines whether to display detailed server information on main page.
 * You can additionally hide more information by using $cfg['Servers'][$i]['verbose'].
 */
 $cfg['ShowServerInfo'] = 'false';

/**
 * Defines charset for generated export.
 * By default no charset conversion is done assuming UTF-8.
 */
 $cfg['Export']['charset'] = 'utf-8';

/**
* Defines charset for import.
* By default no charset conversion is done assuming UTF-8.
*/
$cfg['Import']['charset'] = 'utf-8';

/**
* Whether to allow root access.
* This is just a shortcut for the $cfg['Servers'][$i]['AllowDeny']['rules'] below.
*/
$cfg['Servers'][$i]['AllowRoot'] = 'false';


$cfg['NavigationTreeEnableGrouping'] = false;
$cfg['AllowArbitraryServer'] = true;
$cfg['AllowThirdPartyFraming'] = true;
$cfg['ShowDbStructureCreation'] = true;
$cfg['ShowDbStructureLastUpdate'] = true;
$cfg['ShowDbStructureLastCheck'] = true;
$cfg['UserprefsDisallow'] = array(
    'ShowServerInfo',
    'ShowDbStructureCreation',
    'ShowDbStructureLastUpdate',
    'ShowDbStructureLastCheck',
    'Export/quick_export_onserver',
    'Export/quick_export_onserver_overwrite',
    'Export/onserver');
$cfg['Export']['quick_export_onserver'] = true;
$cfg['Export']['quick_export_onserver_overwrite'] = true;
$cfg['Export']['compression'] = 'gzip';
$cfg['Export']['onserver'] = true;
$cfg['Export']['sql_drop_database'] = true;
$cfg['ServerDefault'] = 1;
$cfg['Servers'][\$i]['auth_http_realm'] = 'phpMyAdmin Login';
$cfg['Servers'][\$i]['hide_db'] = 'information_schema';

/**
 * You can find more configuration options in the documentation
 * in the doc/ folder or at <https://docs.phpmyadmin.net/>.
 */
