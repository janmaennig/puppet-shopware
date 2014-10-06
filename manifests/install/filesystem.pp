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
# == Author
# Jan Maennig
#
define shopware::install::filesystem (

$src_path,

) {

  exec {"Copy in ${name} working directory":
  	command     => "sudo -u devshare cp ${src_path}/shopware_source/* ${src_path}/ -Rf",
  	creates     => "${src_path}/engine",
  	cwd         => "${src_path}",
  	onlyif  => "test ! -f ${src_path}/engine",
  }

  exec {"Chown ${name}":
  	command     => "chown -R devshare:www-data ${src_path}/logs/ -Rf ${src_path}/cache/ -Rf",
  	cwd         => "${src_path}",
  	require     => Exec["Clone ${name}"]
  }

  exec {"Chown filesystem":
	command     => "chmod 777 ${src_path}/logs/ -Rf ${src_path}/cache/ -Rf",
	cwd         => "${src_path}",
	require     => Exec["Checkout ${name}"]
  }
}