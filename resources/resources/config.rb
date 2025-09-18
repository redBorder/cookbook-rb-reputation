# Cookbook:: rb-reputation
# Resource:: config

actions :add, :remove, :register, :deregister
default_action :add

attribute :memory, kind_of: Integer, default: 524288
attribute :config_dir, kind_of: String, default: '/etc/rb-reputation'
attribute :log_dir, kind_of: String, default: '/var/log/rb-reputation'
attribute :name, kind_of: String, default: 'localhost'
attribute :ip, kind_of: String, default: '127.0.0.1'
attribute :aerospike_ips, kind_of: Array, default: []
attribute :user, kind_of: String, default: 'rb-reputation'
attribute :group, kind_of: String, default: 'rb-reputation'
