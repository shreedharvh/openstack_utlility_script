require 'sequel'
require 'ipaddress'
require 'terminal-table'

def connect_db(host,database,user,passwd)
  Sequel.connect(:adapter=>'mysql', :host=>"#{host}", :database=>"#{database}", :user=>"#{user}", :password=>"#{passwd}")
end

def get_total_ip(subnet_hash)
   ips=subnet_hash[subnet_hash.keys.first]
   ip = IPAddress ips.first
   ip_range=ip.to(ips.last)
   ip_range.size
end

def get_tenant_info(dbh,tenantname)
  dataset = dbh[:project].filter(:name => tenantname)
  dataset.map(:id) if dataset.count > 0
end

def get_used_ip(dbh,subnet_id)
   dataset = dbh[:ipallocations].filter(:subnet_id => subnet_id).group(:subnet_id)
   used_ips=dataset.count if dataset.count > 0
end

def display_output(tenant_info)
row = []
tenant_info.each do |teant|
 teant.each do |tenant_id,results|
   results.each do |subnet_id, value|
       row << [tenant_id, subnet_id, value[:total_ips], value[:used_ips], value[:free_ips]]
   end
  end
end
table = Terminal::Table.new
table.title = "IP Details"
table.headings = ['Tenant Name', 'Subnet ID ','Total IPs','Used IPs','Free IPs']
table.rows = row
puts table
end

def get_ipallocationpools_info(dbh,subnet_ids)
  subnet_info={}
  subnet_ids.each { |subnet_id| puts subnet_id
                  dataset = dbh[:ipallocationpools].filter(:subnet_id => subnet_id)
                  subnet_hash=dataset.to_hash(:subnet_id, [:first_ip,:last_ip]) if dataset.count > 0
                  total_ips=get_total_ip(subnet_hash)
                  used_ips=get_used_ip(dbh,subnet_id)
                  free_ips=total_ips - used_ips
                 
                  subnet_info[subnet_id] = { :total_ips => total_ips,
                                                    :used_ips => used_ips,
                                                    :free_ips => free_ips }
                                                        }
  return subnet_info
end

def get_subnets_info(dbh,tenant_id)
tenant_subnet_info=[]
dataset = dbh[:subnets].filter(:tenant_id => tenant_id)
subnet_ids=dataset.map(:id) if dataset.count > 0
subnet_info=get_ipallocationpools_info(dbh,subnet_ids) unless subnet_ids.empty?
tenant_subnet_info.push(tenant_id.first =>  subnet_info)
tenant_subnet_info
end

begin
tenant_name="BHS_FL"
db_keystone=connect_db('localhost','keystone','cerneradmin','cerner')
db_neutron=connect_db('localhost','neutron','cerneradmin','cerner')

tenant_id=get_tenant_info(db_keystone,tenant_name)

tenant_subnet_info=get_subnets_info(db_neutron,tenant_id) unless  tenant_id.empty?

display_output(tenant_subnet_info)

rescue StandardError => error
puts "#{error}"
end
