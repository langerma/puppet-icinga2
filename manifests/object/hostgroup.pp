# == Define: icinga2::object::hostgroup
#
# Manage Icinga 2 HostGroup objects.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the object, absent disables it. Defaults to present.
#
# [*display_name*]
#   A short description of the host group.
#
# [*groups*]
#   An array of nested group names.
#
# [*assign*]
#   Assign host group members using the group assign rules.
#
# [*target*]
#   Destination config file to store in this object. File will be declared at the
#   first time.
#
# [*order*]
#   String to set the position in the target file, sorted alpha numeric. Defaults to 10.
#
# === Examples
#
# icinga2::object::hostgroup { 'monitoring-hosts':
#   display_name => 'Linux Servers',
#   groups       => [ 'linux-servers' ],
#   target       => '/etc/icinga2/conf.d/groups2.conf',
#   assign       => [ 'host.name == NodeName' ],
# }
#
#
define icinga2::object::hostgroup(
  $target,
  $ensure         = present,
  $hostgroup_name = $title,
  $display_name   = undef,
  $groups         = undef,
  $assign         = [],
  $ignore         = [],
  $order          = '55',
) {

  # validation
  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_string($hostgroup_name)
  validate_string($order)
  validate_absolute_path($target)

  if $display_name { validate_string($display_name) }
  if $groups { $_groups = any2array($groups) } else { $_groups = undef }

  if $ignore != [] and $assign == [] {
    fail('When attribute ignore is used, assign must be set.')
  }

  # compose the attributes
  $attrs = {
    display_name   => $display_name,
    groups         => $_groups,
  }

  # create object
  icinga2::object { "icinga2::object::HostGroup::${title}":
    ensure      => $ensure,
    object_name => $hostgroup_name,
    object_type => 'HostGroup',
    attrs       => $attrs,
    assign      => $assign,
    ignore      => $ignore,
    target      => $target,
    order       => $order,
    notify      => Class['::icinga2::service'],
  }
}
