module OstackUtil
  # Public: Various commands for the user to interact with ostack_util.
  class Commands < Thor
    # Public: This function will be used to validate input options and list
    #         Openstack resources.It will log the response and handle any 
    #         errors raised in the process.
    # Example: ostack_util fixedip -t bhs_fl -s 574996fc-1cd9-438a-8e2b-9ebc4dd35c4e
    desc 'fixedip','list free fixedips'
    method_option :tenantname, required: true, aliases: '-t', desc: 'Tenant name'
    def fixedip

      fixedip = OstackUtil::OstackFixedIp.new
      db_keystone = fixedip.connect_db('localhost','keystone','cerneradmin','cerner')
      db_neutron = fixedip.connect_db('localhost','neutron','cerneradmin','cerner')

      tenant_id = fixedip.get_tenant_info(db_keystone,options[:tenantname])
      tenant_subnet_info = fixedip.get_subnets_info(db_neutron,tenant_id)
      fixedip.display_output(tenant_subnet_info)
      
    rescue StandardError => error
      OstackUtil.log(error, :BOTH)
    end
  end
end
