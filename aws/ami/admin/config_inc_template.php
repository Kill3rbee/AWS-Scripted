<?php
/**
 * phpMyAdmin configuration file, you can use it as base for the manual
 * configuration.
 */

$cfg['blowfish_secret'] = '';

$i = 0;

$i++;
$cfg['Servers'][$i]['host']          = 'SEDdbhostSED';
$cfg['Servers'][$i]['port']          = '3306';
$cfg['Servers'][$i]['socket']        = '';
$cfg['Servers'][$i]['connect_type']  = 'tcp';
$cfg['Servers'][$i]['extension']     = 'mysqli';
$cfg['Servers'][$i]['compress']      = FALSE;
$cfg['Servers'][$i]['controluser']   = '';
$cfg['Servers'][$i]['controlpass']   = '';
$cfg['Servers'][$i]['auth_type']     = 'config';
$cfg['Servers'][$i]['user']          = 'mainuser';
$cfg['Servers'][$i]['password']      = 'SEDdbmainuserpassSED';
$cfg['Servers'][$i]['only_db']       = '';
$cfg['Servers'][$i]['hide_db']       = '';
$cfg['Servers'][$i]['verbose']       = '';
$cfg['Servers'][$i]['pmadb']         = '';
$cfg['Servers'][$i]['bookmarktable'] = '';
$cfg['Servers'][$i]['relation']      = '';
$cfg['Servers'][$i]['table_info']    = '';
$cfg['Servers'][$i]['table_coords']  = '';
$cfg['Servers'][$i]['pdf_pages']     = '';
$cfg['Servers'][$i]['column_info']   = '';
$cfg['Servers'][$i]['history']       = '';
$cfg['Servers'][$i]['verbose_check'] = TRUE;
$cfg['Servers'][$i]['AllowRoot']     = TRUE;
$cfg['Servers'][$i]['AllowDeny']['order'] = '';
$cfg['Servers'][$i]['AllowDeny']['rules'] = array();
$cfg['Servers'][$i]['AllowNoPassword'] = FALSE;
$cfg['Servers'][$i]['designer_coords'] = '';
$cfg['Servers'][$i]['bs_garbage_threshold'] = 50;
$cfg['Servers'][$i]['bs_repository_threshold'] = '32M';
$cfg['Servers'][$i]['bs_temp_blob_timeout'] = 600;
$cfg['Servers'][$i]['bs_temp_log_threshold'] = '32M';

$cfg['UploadDir'] = '/var/lib/phpMyAdmin/upload';
$cfg['SaveDir']   = '/var/lib/phpMyAdmin/save';

$cfg['PmaNoRelation_DisableWarning'] = TRUE;
?>