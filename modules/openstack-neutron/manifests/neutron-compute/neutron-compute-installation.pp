class openstack-neutron::neutron-compute::neutron-compute-installation inherits openstack-neutron::params {

    notify {"Installing Openstack Neutron Packages on Compute Nodes":} ->
    package {
        $neutron_compute_packages: 
        ensure =>installed,
    } -> 

    notify {"CREATING neutron.conf file on Compute Node":} ->
    file { "/etc/neutron/neutron.conf":
        ensure  => file,
        owner  => root,
        group  => neutron,
        content => template('openstack-neutron/neutron-compute/neutron.conf.erb'),
   }
}
