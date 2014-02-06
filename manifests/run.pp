define docker::run(
  $image,
  $container_name = $title,
  $use_name = false,
  $command,
  $memory_limit = '0',
  $ports = [],
  $volumes = [],
  $links = [],
  $working_dir = '/',
  $running = true,
  $volumes_from = false,
  $username = '',
  $hostname = '',
  $privileged = false,
  $env = [],
  $dns = [],
  $dependant = '',
) {

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*$')
  validate_string($command, $username, $hostname, $working_dir, $container_name, $dependant)
  validate_bool($running, $privileged, $use_name)

  $ports_array = any2array($ports)
  $volumes_array = any2array($volumes)
  $env_array = any2array($env)
  $dns_array = any2array($dns)
  $links_array = any2array($links)

  file { "/etc/init/docker-${title}.conf":
    ensure  => present,
    content => template('docker/etc/init/docker-run.conf.erb')
  }

  service { "docker-${title}":
    ensure     => $running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => upstart,
    require    => File["/etc/init/docker-${title}.conf"],
    notify     => Service["docker-${dependant}"],
  }

}
