# @summary Configures the Let's Encrypt client.
#
# @api private
#
class letsencrypt::config (
  $config_dir          = $letsencrypt::config_dir,
  $config_file         = $letsencrypt::config_file,
  $config              = $letsencrypt::config,
  $email               = $letsencrypt::email,
  $unsafe_registration = $letsencrypt::unsafe_registration,
  $agree_tos           = $letsencrypt::agree_tos,
) {
  assert_private()

  unless $agree_tos {
    fail("You must agree to the Let's Encrypt Terms of Service! See: https://letsencrypt.org/repository for more information." )
  }

  file { $config_dir: ensure => directory }

  file { $letsencrypt::cron_scripts_path:
    ensure => directory,
    purge  => true,
  }

  if $email {
    $_config = merge($config, { 'email' => $email })
  } else {
    $_config = $config
  }

  unless 'email' in $_config {
    if $unsafe_registration {
      warning('No email address specified for the letsencrypt class! Registering unsafely!')
      ini_setting { "${config_file} register-unsafely-without-email true":
        ensure  => present,
        path    => $config_file,
        section => '',
        setting => 'register-unsafely-without-email',
        value   => true,
        require => File[$config_dir],
      }
    } else {
      fail("Please specify an email address to register with Let's Encrypt using the \$email parameter on the letsencrypt class")
    }
  }

  $_config.each |$key,$value| {
    ini_setting { "${config_file} ${key} ${value}":
      ensure  => present,
      path    => $config_file,
      section => '',
      setting => $key,
      value   => $value,
      require => File[$config_dir],
    }
  }
}
