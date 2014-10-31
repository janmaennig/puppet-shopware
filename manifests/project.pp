# = Class: shopware::project
#
# == Parameters
#
# Standard class parameters
# [*php_version*]
#   PHP version for project.
#   Example: '5.5.9'
#
# [*version*]
#   TYPO3 version for project.
#   Example: '4.3.0'
#
# [*shopware_src_path_path*]
#   Path to TYPO3 sources.
#   Example:  '/var/www/'
#
# [*site_path*]
#   Path to project root.
#   Example:  '/var/www/my-project'
#
# [*site_user*]
#   Project files owner.
#   Example: 'vagrant'
#
# [*site_group*]
#   Project files group.
#   Example: 'www-data'
#
# [*db_pass*]
#   Set the password for the database.
#   Default: '' (empty)
#
# [*db_user*]
#   Set the user for the database.
#   Default: '' (empty)
#
# [*db_host*]
#   Set the the database host.
#   Default: '' (empty)
#
# [*db_name*]
#   Set the database name.
#   Default: '' (empty)
#
# [*local_conf*]
#   Set some parameters for pre-set in LocalConfiguration file.
#   Default: (empty hash)
#
# [*extensions*]
#   Set some extensions and parameters for pre-install.
#   Default: (empty array)
#
# [*use_symlink*]
#   Set a symlink to TYPO3 source. Set to false to copy sources.
#   Default: true
#
# [*enable_install_tool*]
#   Enables the TYPO3 install tool for one hour.
#   Default: false
#
# == Author
# Jan Maennig
#
define shopware::project (

		$php_version,
		$version,
		$shopware_src_path,
		$site_path,
		$site_user,
		$site_group,

		$db_pass = "",
		$db_user = "",
		$db_host = "",
		$db_name = "",

		$local_conf = { },
		$extensions = [],

		$use_symlink = true,
		$enable_install_tool = false

) {

		include shopware

		if ( $site_user != $site_group ) {
				$dir_permission     = 2770
				$file_permission    = 660
		} else {
				$dir_permission     = 2755
				$file_permission    = 644
		}

		shopware::install::source { "${name}":
				version     => $version,
				src_path    => $shopware_src_path,
				php_version => $php_version,
				site_user   => $site_user
		}

		shopware::install::filesystem { "${name}":
				version   => $version,
				src_path  => $shopware_src_path,
				site_user => $site_user,
				site_path => $site_path
		}

		File {
				owner       => $site_user,
				group       => $site_group,
				require     => [Exec["Copy in ${name} working directory"],Exec["Composer install ${name}"]]
		}

		File {
				replace   => "no",
				ensure    => "present",
				mode      => $file_permission
		}

		file { "${site_path}/config.php":
				content   => template('shopware/config.php.erb'),
		}
}