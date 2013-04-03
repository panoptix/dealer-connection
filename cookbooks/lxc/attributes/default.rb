default['lxc']['network_interface'] = "eth1"
default['lxc']['bridge_interface'] = "br0"
default['lxc']['lxc_path'] = "/lxc/"

default["lxc"]["containers"] =  
{
        "lxc-nginx" => {
        	"snapshot_remote" => "https://github.com/panoptix/lxc-snapshots/archive/centos.zip",
        	"snapshot_repo" => "lxc-snapshots-centos",
        	"snapshot_file" => "centos-6.4-x86_64-snapshot.tgz",
        	"interface" => "eth0",
        	"ipaddress" => "172.16.0.100",
		"netmask"   => "/24",
        	"gateway"   => "172.16.0.1",
		"dnat_ssh"  => "10022"
	},
	"lxc-dbmaster" => {
                "snapshot_remote" => "https://github.com/panoptix/lxc-snapshots/archive/centos.zip",
                "snapshot_repo" => "lxc-snapshots-centos",
                "snapshot_file" => "centos-6.4-x86_64-snapshot.tgz",
                "interface" => "eth0",
                "ipaddress" => "172.16.0.101",
                "netmask"   => "/24",
                "gateway"   => "172.16.0.1",
		"dnat_ssh"  => "10122"
        },
	  "lxc-dbslave" => {
                "snapshot_remote" => "https://github.com/panoptix/lxc-snapshots/archive/centos.zip",
                "snapshot_repo" => "lxc-snapshots-centos",
                "snapshot_file" => "centos-6.4-x86_64-snapshot.tgz",
                "interface" => "eth0",
                "ipaddress" => "172.16.0.102",
                "netmask"   => "/24",
                "gateway"   => "172.16.0.1",
		"dnat_ssh"  => "10222"
        },
	  "lxc-app" => {
                "snapshot_remote" => "https://github.com/panoptix/lxc-snapshots/archive/centos.zip",
                "snapshot_repo" => "lxc-snapshots-centos",
                "snapshot_file" => "centos-6.4-x86_64-snapshot.tgz",
                "interface" => "eth0",
                "ipaddress" => "172.16.0.103",
                "netmask"   => "/24",
                "gateway"   => "172.16.0.1",
		"dnat_ssh"  => "10322"
        }
}
