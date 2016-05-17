# This class handles the creation of a group and manages its members.
#
# @param ensure passed directly to the group resource
# @param members An array of usersnames that are to be members of the group
# @param exclusive Boolean to remove users members not present in members array
# @param gid Integer for the GID of the group
#
# @example
#   account::group { 'humans':
#     members   => ['alice', 'bob'],
#     exclusive => false,
#     gid       => 2001,
#   }
#
define account::group (
  $ensure            = present,
  Array $members     = [],
  Boolean $exclusive = true,
  $gid               = undef,
) {

  realize(Account::User[$members])

  group { $name:
    ensure => $ensure,
    gid    => $gid,
    tag    => 'posixgroup',
  }

  groupmembership { $name:
    members   => $members,
    exclusive => $exclusive,
  }
}
