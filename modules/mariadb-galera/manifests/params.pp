class mariadb-galera::params {
    $MYSQL_ROOT_PASSWORD    = '459nvDB91fWU'
    $GALERA_DB_USER         = 'sst_user'
    $HOST_IP                = $ipaddress 
    $HOSTNAME               = $hostname
    $GALERA_DB_PASSWORD     = '9Rp2491E3n9L'
    $CLUSTER_MEMBERS_LIST   = "openstack_controller1,openstack_controller2,openstack_controller3" 

    $packages = [ 
        "MariaDB-server",
        "MariaDB-client",
        "rsync",
        "galera",
        "expect",
        "socat"
    ]
 }
