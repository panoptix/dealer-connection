directory node[:lxc][:lxc_path] do
action :create
end

node[:lxc][:containers].each do |name,attributes| 
	directory "#{node[:lxc][:lxc_path]}/#{name}" do
		action :create
	end
	
	directory "#{node[:lxc][:lxc_path]}/#{name}/rootfs" do
		action :create
	end

	template "#{node[:lxc][:lxc_path]}#{name}/lxc.conf" do
		source "container-lxc.conf.erb"
		variables	:name => "#{name}", 
				:ipaddress => "#{attributes.ipaddress}", 
				:lxc_path => "#{node[:lxc][:lxc_path]}", 
				:interface => "#{attributes.interface}",
				:netmask    => "#{attributes.netmask}",
				:bridge => "#{node[:lxc][:bridge_interface]}"
	end

	template "#{node[:lxc][:lxc_path]}#{name}/fstab" do
		source "container-fstab.erb"
		variables	:name => "#{name}",
				:lxc_path => "#{node[:lxc][:lxc_path]}"
	end

	remote_file "/tmp/#{attributes.snapshot_file}.zip" do
		source "#{attributes.snapshot_remote}"
		not_if{ File.exists?("/tmp/#{attributes.snapshot_file}.zip") }
	end

	execute "uncompress snapshot" do
		cwd "/tmp/"
		command "/usr/bin/unzip /tmp/#{attributes.snapshot_file}.zip"
		not_if{File.exists?("/tmp/#{attributes.snapshot_repo}/#{attributes.snapshot_file}") }
	end

	execute "copy snapshot to rootfs" do
		cwd "#{node[:lxc][:lxc_path]}#{name}/rootfs"
		command "tar zxvf /tmp/#{attributes.snapshot_repo}/#{attributes.snapshot_file}"
		not_if{File.exists?("#{node[:lxc][:lxc_path]}#{name}/rootfs/etc")}
	end

	cookbook_file "#{node[:lxc][:lxc_path]}#{name}/rootfs/etc/rc.d/rc.sysinit" do
		source "container-rc.sysinit"
		mode "0700"
	end

	cookbook_file "#{node[:lxc][:lxc_path]}#{name}/rootfs/create-dev.sh" do
		source "create-dev.sh"
		mode "0700"
	end
	
	execute "create dev directory" do
	cwd "#{node[:lxc][:lxc_path]}#{name}/rootfs"
	command "./create-dev.sh"	
	not_if{File.exists?("#{node[:lxc][:lxc_path]}#{name}/rootfs/dev.old")}
	end
	
	execute "delete route" do
	command "rm #{node[:lxc][:lxc_path]}#{name}/rootfs/etc/sysconfig/network-scripts/route-eth0"
	only_if{ File.exists?("#{node[:lxc][:lxc_path]}#{name}/rootfs/etc/sysconfig/network-scripts/route-eth0") }
	end

	template "#{node[:lxc][:lxc_path]}#{name}/rootfs/etc/sysconfig/network-scripts/ifcfg-#{attributes.interface}" do

	source "container-ifcg.erb"
	variables 	:interface	 => "#{attributes.interface}",
			:ipaddress	 => "#{attributes.ipaddress}",
			:gateway	 => "#{attributes.gateway}"
	end
	template "#{node[:lxc][:lxc_path]}#{name}/rootfs/etc/hosts" do
	source "container-hosts.erb"
	variables :name => "#{name}",	
		  :ipaddress => "#{attributes.ipaddress}"
	end

	execute "create container" do
	command "lxc-create -n #{name} -f #{node[:lxc][:lxc_path]}#{name}/lxc.conf"
	not_if { node.attribute?("created") }
	end

	execute "init container" do
	command "screen -dmS #{name} lxc-start -n #{name}"
	not_if { node.attribute?("#{name}-created") }
	end

	execute "DNAT ssh" do
 	command "iptables -t nat -A PREROUTING -i eth0 -p tcp --dport #{attributes.dnat_ssh} -j DNAT --to-destination #{attributes.ipaddress}:22"
	end
	
	ruby_block "set created flag" do
  	block do
    	node.set['#{name}-created'] = true
    	node.save
  	end
  	action :nothing
	end	
	
	directory "#{node[:lxc][:lxc_path]}#{name}/rootfs/root/.ssh/" do
	action :create
	end

	cookbook_file "#{node[:lxc][:lxc_path]}#{name}/rootfs/root/.ssh/authorized_keys" do
	source "id_rsa.pub"	
	action :create
	end

	execute "selinux allow rsa-key" do
	command 'restorecon -R -v /root/.ssh'	
	end
end

