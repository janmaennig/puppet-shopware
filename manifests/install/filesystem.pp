# = Class: shopware::install::filesystem
#
# == Parameters
#
# Standard class parameters
#
# [*src_path*]
#   Path to source directory.
#   Example: '/var/source_libs/shopware/'
#
# [*site_user*]
#   Project files owner
#   Example: 'devshare'
#
# [*site_path*]
#   Path to source directory.
#   Example: '/var/www/shopware'
#
# == Author
# Jan Maennig
#
define shopware::install::filesystem (
		$version,
		$src_path,
		$site_user,
		$site_path

) {

		exec { "Copy in ${name} working directory":
				command     => "sudo -u ${site_user} cp ${src_path}/${version}/* ${site_path}/ -Rf",
				creates     => "${site_path}/engine",
				cwd         => "${site_path}",
				require => Exec["Checkout ${name}"]
		}

		exec { "Copy .htaccess in ${name} working directory":
				command     => "sudo -u ${site_user} cp ${src_path}/${version}/.htaccess ${site_path}/.htaccess -Rf",
				creates     => "${site_path}/.htaccess",
				cwd         => "${site_path}",
				require => Exec["Copy in ${name} working directory"],
				onlyif      => "test ! -f ${site_path}/.htaccess",
		}

		exec { "Cleanup ${name} working directory":
				command     => "rm ${site_path}/build -Rf ${site_path}/config.php.dist ${site_path}/eula* ${site_path}/license.txt -f ${site_path}/REAME* -f ${site_path}/_sql -Rf ${site_path}/UPGRADE* -f",
				cwd         => "${site_path}",
				require => Exec["Copy in ${name} working directory"],
				onlyif      => "test -f ${site_path}/config.php.dist",
		}

		exec { "Chown ${name} filesystem":
				command     => "chmod 777 ${site_path}/logs/ -Rf ${site_path}/cache/ -Rf",
				cwd         => "${site_path}",
				require => Exec["Copy in ${name} working directory"]
		}

		exec { "Composer self-update ${name}":
				command     => "/usr/local/php/5.5.9/bin/php /usr/local/php/5.5.9/bin/composer.phar self-update",
				environment => ["COMPOSER_HOME=${src_path}/${version}"],
				cwd         => "${site_path}/",
				require     => Exec["Copy in ${name} working directory"]
		}

		exec { "Composer install ${name}":
				command     => "/usr/local/php/5.5.9/bin/php /usr/local/php/5.5.9/bin/composer.phar install",
				environment => ["COMPOSER_HOME=${src_path}/${version}"],
				cwd         => "${site_path}/",
				require     => Exec["Copy in ${name} working directory"]
		}
}