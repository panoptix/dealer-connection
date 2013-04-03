include_recipe "lxc::dependencies"

lxcpkgs = [ 
	"lxc-libs-0.9.0.rc1-1.el6.x86_64.rpm",
	"lxc-0.9.0.rc1-1.el6.x86_64.rpm"
]

lxcpkgs.each do  |pkg| 
	cookbook_file "/tmp/#{pkg}" do
		source "#{pkg}"
		not_if { File.exists?("/tmp/#{pkg}") } 
	end

	package "#{pkg}" do
		source "/tmp/#{pkg}"
		action :install
	not_if "rpm -qa |grep #{pkg}"
	end
end

template "/tmp/create_bridge.sh" do
	source "create_bridge.sh.erb"
	mode 700
end

execute "create bridge" do
	command "/tmp/create_bridge.sh"
	command "service network restart"
	not_if "ifconfig|grep #{node[:lxc][:bridge_interface]}"
end

directory "/cgroup" do
action :create
end

execute "cgroup" do
	command "mount none -t cgroup /cgroup"
	command 'echo "none /cgroup cgroup defaults 0 0" >> /etc/fstab'
	not_if "grep cgroup /etc/fstab"
end
execute "configure nat" do
command "iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"
end

include_recipe "lxc::containers"
