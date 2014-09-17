# = Class: shopware::install::source
#
# == Parameters
#
# Standard class parameters
#
# [*version*]
#   Shopware version for project.
#   Example: '4.3.0'
#
# [*src_path*]
#   Path to source directory.
#   Example: '/var/www/shopware'
#
# [*php_version*]
#   PHP version for project.
#   Example: '5.5.9'
#
# == Author
# Jan Maennig
#
define shopware::install::source (

  $version,
  $src_path,
  $php_version

) {

  include shopware::params

  exec {"Clone ${name}":
  	command     => "git clone --no-hardlinks ${shopware::params::download_url} ${src_path}",
  	creates     => "${src_path}/.git",
  	cwd         => "${src_path}",
  	onlyif  => "test ! -f ${src_path}/.git",
  }

  exec {"Checkout ${name}":
  	command     => "git checkout ${version}",
  	cwd         => "${src_path}",
  	notify      => Exec["Chown ${name}"],
  	require     => Exec["Clone ${name}"]
  }

  exec {"Composer Update ${name}":
  	command     => "/usr/local/php/${php_version}/bin/php /usr/local/php/${php_version}/bin/composer.phar update",
  	environment => ["COMPOSER_HOME=${src_path}"],
  	cwd         => "${src_path}",
  	require     => Exec["Checkout ${name}"]
  }

  exec {"Chown ${name}":
  	command     => "chown -R devshare:www-data ${src_path}/ -Rf",
  	refreshonly => true,
  	cwd         => "${src_path}",
  	require     => Exec["Clone ${name}"]
  }

  exec {"Chown filesystem":
	command     => "chmod 777 ${src_path}/logs/ -Rf ${src_path}/cache/ -Rf",
	cwd         => "${src_path}",
	require     => Exec["Checkout ${name}"]
  }
}