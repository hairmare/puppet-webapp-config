# == Define: webapp_config
#
# call webapp_config
#
# === Parameters:
# [*action*]
#   install or remove an app, default is install
# [*vhost*]
#   in what vhost to install
# [*base*]
#   what location to use
# [*app*]
#   what app to install, dont forget to install the Package elsewhere
# [*version*]
#   what version of the app to install
# [*depends*]
#   dependencies, like the Package and or File resources
# [*installdir*]
#   optional installdir location
#
define webapp_config ($action = 'install', $vhost, $base = '/', $app, $version, $depends, $installdir = undef) {
  $installdir_real = $installdir ? {
    undef   => "/var/www/${vhost}",
    default => $installdir,
  }

  case $action {
    'install' : {
      $cmd    = "webapp-config -I -h ${vhost} -d ${base} ${app} ${version}"
      $unless = "test -f ${installdir_real}/htdocs/${base}/.webapp-${app}-${version}"
    }
    'remove'  : {
      $cmd    = "webapp-config -C -h ${vhost} -d ${base} ${app} ${version}"
      $unless = "$(! test -f ${installdir_real}/htdocs/${base}/.webapp-${app}-${version})"
    }
    default   : {
      alert("webapp-config: Action '${action}' is invalid")
    }
  }

  exec { "webapp-${action}-${app}":
    command => $cmd,
    path    => ['/usr/bin', '/usr/sbin'],
    unless  => $unless,
    require => $depends,
  }
}
  