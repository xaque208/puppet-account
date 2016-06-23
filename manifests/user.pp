# This define handles user account creation
#
# This class installs and manages user accounts
#
# @param ensure To add or remove the account from the system
# @param shell Set the users shell if desired
# @param home Set the home if defaults are unsatisfactory
# @param group Set the primary group of the user
# @param uid Set the uid of the account if desired
# @param realizekeys Boolean to realize virtual 'ssh_authorized_key' resources
# @param purgekeys Boolean to enablee purging unmanaged ssh keys
# @param comment The comment for the user resource
# @param hushlogin Boolean to disable motd etc upon login
#
# @example
#   account::user { 'sue':
#     group => 'sysadmin',
#   }
#
define account::user (
  $ensure              = present,
  $shell               = '/bin/bash',
  $home                = undef,
  $group               = undef,
  $uid                 = undef,
  Boolean $realizekeys = true,
  Boolean $purgekeys   = false,
  $comment             = undef,
  Boolean $hushlogin   = false,
) {

  if $uid {
    $userid = $uid
  } else {
    $userid = undef
  }

  if $group {
    $groupname = $group
    realize(Account::Group[$group])
  } else {
    $groupname = undef
  }

  if $home { # Set home
    $homedir = $home
  } else {
    $homedir = $::kernel ? {
      'Darwin' => "/Users/${name}",
      'SunOS'  => "/export/home/${name}",
      default  => "/home/${name}",
    }
  }

  if $hushlogin {
    file { "${homedir}/.hushlogin":
      ensure  => present,
      require => User[$name],
    }
  }

  user { $name:
    ensure         => $ensure,
    gid            => $groupname,
    uid            => $userid,
    home           => $homedir,
    comment        => $comment,
    managehome     => false,
    shell          => $shell,
    purge_ssh_keys => $purgekeys,
  }

  # Only if we are ensuring a user is present
  if $ensure == present {
    File { owner => $name, group => $groupname }
    file { $homedir:
      ensure  => directory,
      mode    => '0700',
      require => User[$name],
    }

    if $realizekeys {
      Ssh_authorized_key <| user == $name |> { require => File[$homedir] }
    }
  } else {
    if $realizekeys {
      Ssh_authorized_key <| user == $name |> {
        ensure => absent,
      }
    }
  }
}
