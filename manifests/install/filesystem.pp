# = Class: shopware::install::filesystem
#
# == Parameters
#
# Standard class parameters
#
# [*src_path*]
#   Path to source directory.
#   Example: '/var/www/shopware'
#
# [*site_user*]
#   Project files owner
#   Example: 'devshare'
#
# == Author
# Jan Maennig
#
define shopware::install::filesystem (

$src_path,
$site_user

) {

	exec {"Copy in ${name} working directory":
		command     => "sudo -u ${site_user} cp ${src_path}/shopware_source/* ${src_path}/ -Rf",
		creates     => "${src_path}/engine",
		cwd         => "${src_path}",
		onlyif  => "test ! -f ${src_path}/engine",
	}

	exec {"Copy .htaccess in ${name} working directory":
		command     => "sudo -u ${site_user} cp ${src_path}/shopware_source/.htaccess ${src_path}/.htaccess -Rf",
		creates     => "${src_path}/.htaccess",
		cwd         => "${src_path}",
		onlyif  => "test ! -f ${src_path}/.htaccess",
	}

	exec {"Cleanup ${name} working directory":
		command     => "rm ${src_path}/build -Rf ${src_path}/composer* -Rf ${src_path}/config.php.dist ${src_path}/eula* ${src_path}/license.txt -f ${src_path}/REAME* -f ${src_path}/_sql -Rf ${src_path}/UPGRADE* -f",
		cwd         => "${src_path}",
		onlyif  => "test -f ${src_path}/config.php.dist",
	}

	exec {"Chown filesystem":
		command     => "chmod 777 ${src_path}/logs/ -Rf ${src_path}/cache/ -Rf",
		cwd         => "${src_path}",
		require     => Exec["Checkout ${name}"]
	}
}