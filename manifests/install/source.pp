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
#   Example: '/var/source_libs/shopware/'
#
# [*php_version*]
#   PHP version for project.
#   Example: '5.5.9'
# [*site_user*]
#   Project files owner
#   Example: 'devshare'
#
# == Author
# Jan Maennig
#
define shopware::install::source (

		$version,
		$src_path,
		$php_version,
		$site_user

) {

		include shopware::params

		if ! defined(File[$src_path]) {
				file { "${src_path}":
						ensure  => "directory",
						owner   => "${site_user}",
						group   => "www-data",
						mode    => 775
				}
		}

		if ! defined(File["${src_path}/${version}"]) {
				file { "${src_path}/${version}":
						ensure  => "directory",
						owner   => "${site_user}",
						group   => "www-data",
						mode    => 775,
						require => File[$src_path]
				}
		}

		if ! defined("Clone ${name}") {
				exec { "Clone ${name}":
						command     => "git clone --no-hardlinks ${shopware::params::download_url} ${src_path}/${version}",
						creates     => "${src_path}/${version}/.git",
						cwd         => "${src_path}/${version}",
						onlyif      => "test ! -f ${src_path}/${version}/.git"
				}
		}

		if ! defined("Checkout ${name}") {
				exec { "Checkout ${name}":
						command     => "git checkout ${version} -f",
						cwd         => "${src_path}/${version}",
						onlyif      => "test ! -f ${src_path}/${version}/engine",
						require => Exec["Clone ${name}"]
				}
		}
}