#
# Cookbook Name:: lxc
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
yum_key "RPM-GPG-KEY-elrepo" do
  url "http://elrepo.org/RPM-GPG-KEY-elrepo.org" 
  action :add
end

yum_repository "elrepo-kernel" do
  repo_name "elrepe-kernel"
  description "kernel-ml repo"
  url "http://elrepo.org/linux/kernel/el6/$basearch/"
  key "RPM-GPG-KEY-elrepo"
  action :add
end

pkgs = [ "dstat", "rsync", "openssh-clients", "perl", "screen", "libcap" , "libcap-devel", "man", "bridge-utils", "kernel-ml", "unzip" ] 

pkgs.each do |pkg| 
package "#{pkg}" do
action :install
end
end

execute "set default kernel (kernel-ml@elrepo)" do
command "grubby --set-default /boot/vmlinuz*elrepo*"
not_if { "grubby --default-kernel | grep elrepo" } 
end
