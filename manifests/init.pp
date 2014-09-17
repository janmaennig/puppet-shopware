# = Class: shopware
#
# This is the main shopware class
#
# == Author
# Jan Maennig
#
class shopware (){

  if $::operatingsystem =~ /^(Debian|Ubuntu)$/ and versioncmp($::operatingsystemrelease, "12") < 0 {
    $packages = [ "wget", "git-core" ]
  } else {
    $packages = [ "wget", "git" ]
  }

  safepackage_shopware { $packages: ensure => "installed" }
	
}

define safepackage_shopware ( $ensure = installed ) {

  if !defined(Package[$title]) {
    package { $title: ensure => $ensure }
  }

}