# Puppet-account

[![Puppet Forge](https://img.shields.io/puppetforge/v/zleslie/account.svg)](https://forge.puppet.com/zleslie/account) [![Build Status](https://travis-ci.org/xaque208/puppet-account.svg?branch=master)](https://travis-ci.org/xaque208/puppet-account)

## Usage Overview

The account module serves as a wrapper around the core resources to manage the
creation of users and groups, and handle group membership.

The usage pattern of this module is as follows:

  * Virtual resources for `account::group` are created for every *potential*
    managed group on a system.
  * Virtual resources for every `account::user` are created for every
    *potential* managed user on a system.
  * `account::group` resources are selectively realized based on requirements.
  * Realizing the `account::group` also realizes the `account::user` resources
    matching the members of the given `account::group`.

Given the above, the approach this module assumes is one where users are not
snowflakes, and that all users are members of a group.  It is the creation of a
group that creates the required users.

Lets have an example.

### Example environment

For the sake of discussion, lets say you have a data source that contains all
the information you require about your users.  Whether this is YAML or a
database that you can query from a Puppet function, ultimately, you end up with
a Hash containing the group information that might look like the following.

```Puppet
$posix_groups = {
  'humans' => {
    gid => '1234',
    members => ['sally','parker','ian'],
    exclusive => true,
  },
  'robots' => {
    gid => '1235',
    members => ['monitorbot','backupbot'],
    exclusive => true,
  }
}
```

Now that we have the group data stored in a hash, we can iterate over it in
Puppet to generate a virtual resource for each group.

```Puppet
class virtual::groups (Hash $posix_groups){
  include virtual::users
  $posix_groups.each |$group_name, $params| {
    @account::group { $group_name:
      ensure    => present,
      gid       => $gid,
      members   => $members,
      exclusive => $exclusive,
    }
  }
}
```

Each member of the group will require that a virtual resource for
`account::user` is created for them.  So, again, we have a data blob that falls
from the sky, containing the information for each user under management.

```Puppet
$posix_users = {
  'sally' => {
    uid => '1234',
    shell => '/bin/ksh',
  },
  'parker' => {
    uid => '1235',
    shell => '/bin/zsh',
  },
  'ian' => {
    uid => '1236',
    shell => '/bin/bash',
  },
}
```

Then to create the virtual users, same story again; loop over the user data,
passing in the values.  If you wish to omit certain data from the user hash,
just check the values before you assign them to apply reasonable defaults.

```Puppet
class virtual::users (Hash $posix_users) {
  $posix_users.each |$user_name, $params| {
    if $params['shell'] {
      $shell = $params['shell']
    } else {
      $shell = '/bin/bash'
    }

    @account::user { $user_name:
      ensure    => present,
      shell     => $shell,
      uid       => $params['uid'],
    }
  }
}
```

Now that we have `account::group` and `account::user` virtual resources
available, we only need to realize them in order to deploy a group and its
members to a given system.

```Puppet
include virtual::groups
Realize(Group['humans'])
```

This will realize the 'humans' group and all of its members.  If `exclusive =>
true` is set on the `account::group` resources, any members that are not listed
will be removed.  This can help enforce that only Puppet specified members are
of members of a group.

