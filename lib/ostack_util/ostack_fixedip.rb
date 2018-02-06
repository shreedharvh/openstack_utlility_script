module OstackUtil
  class OstackFixedIp

    def connect_db(host, database, user, passwd)
      Sequel.connect(adapter: 'mysql', host: host.to_s, database: database.to_s, user: user.to_s, password: passwd.to_s)
    end

    def get_total_ip(subnet_hash)
      ips = subnet_hash[subnet_hash.keys.first]
      ip = IPAddress ips.first
      ip_range = ip.to(ips.last)
      ip_range.size
    end

    def get_used_ip(dbh, subnet_id)
      dataset = dbh[:ipallocations].filter(subnet_id: subnet_id).group(:subnet_id)
      used_ips = dataset.count
    end

  
    def get_ipallocation_info(dbh, subnet_ids)
      subnet_info = {}
      subnet_ids.each do |subnet_id|
        
        dataset = dbh[:ipallocationpools].filter(subnet_id: subnet_id)
        subnet_hash = dataset.to_hash(:subnet_id, [:first_ip, :last_ip]) if dataset.count > 0
        total_ips = get_total_ip(subnet_hash)
        used_ips = get_used_ip(dbh, subnet_id)
        free_ips = total_ips - used_ips
      
        subnet_info[subnet_id] = { :total_ips => total_ips,
                                   :used_ips => used_ips,
                                   :free_ips => free_ips }
      end
      subnet_info
    end

    def display_output(tenant_subnet_info)
      row = []
      tenant_subnet_info.each do |tenant|
        tenant.each do |tenant_id, subnet_info|
          subnet_info do |subnet_id, ip_info|
            row << [tenant_id, subnet_id, ip_info[:total_ips], ip_info[:used_ips], ip_info[:free_ips]]
          end
        end
      end
      
      table = Terminal::Table.new
      table.title = "IP Details"
      table.headings = ['Tenant ID', 'Subnet ID ','Total IPs','Used IPs','Free IPs']
      table.rows = row
      puts table

    end

    def get_subnets_info(dbh, tenant_id)
      tenant_subnet_info = []
      dataset = dbh[:subnets].filter(tenant_id: tenant_id)
      raise "#{__method__} subnet id not found for #{tenant_id}" if dataset.count > 0
      subnet_ids = dataset.map(:id)
      subnet_info = get_ipallocation_info(dbh, subnet_ids)
      tenant_subnet_info.push(tenant_id.first => subnet_info)
      tenant_subnet_info
    end

    def get_tenant_info(dbh, tenant_name)
      dataset = dbh[:project].filter(name: tenant_name)
      raise "#{__method__} invalid tenant_name #{tenant_name}" if dataset.count > 0
      dataset.map(:id) 
    end

  end
end

