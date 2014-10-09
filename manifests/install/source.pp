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

  	file { "${src_path}/shopware_source":
		ensure => "directory",
		owner  => "devshare",
		group  => "www-data",
		mode   => 775,
		require => File[$src_path]
	}

  exec {"Clone ${name}":
  	command     => "git clone --no-hardlinks ${shopware::params::download_url} ${src_path}/shopware_source",
  	creates     => "${src_path}/shopware_source/.git",
  	cwd         => "${src_path}/shopware_source",
  	onlyif  => "test ! -f ${src_path}/shopware_source/.git",
  }

  exec {"Checkout ${name}":
  	command     => "git checkout ${version} -f",
  	cwd         => "${src_path}/shopware_source",
  	require     => Exec["Clone ${name}"]
	onlyif  => "test ! -f ${src_path}/shopware_source/engine",
  }

  exec {"Composer Update ${name}":
  	command     => "/usr/local/php/${php_version}/bin/php /usr/local/php/${php_version}/bin/composer.phar update",
  	environment => ["COMPOSER_HOME=${src_path}/shopware_source"],
  	cwd         => "${src_path}/shopware_source",
  	require     => Exec["Checkout ${name}"]
  }
}