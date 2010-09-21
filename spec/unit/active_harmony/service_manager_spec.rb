require "spec_helper"

module ActiveHarmony
  describe ServiceManager do
    before :each do
      manager = ServiceManager.new
      manager.instance_variable_set(:@services, {})
    end
    
    describe '#initialize' do
      it 'should setup hash for known services' do
        manager = ServiceManager.new
        manager.instance_variable_get(:@services).should == {}
      end
    end
    
    describe '#add_service_for_identifier' do
      it 'should add service to services hash' do
        service = Service.new
        manager = ServiceManager.new
        manager.add_service_for_identifier(service, :my_service)
        manager.instance_variable_get(:@services).should == \
          {:my_service => service}
      end
    end
    
    describe '#service_with_identifier' do
      it 'should return service by identifier' do
        service = Service.new
        manager = ServiceManager.new
        manager.instance_variable_set(:@services, 
          {:my_service => service})
        manager.service_with_identifier(:my_service).should == service
      end
      
      it 'should raise an exception when theres no such service' do
        manager = ServiceManager.new
        lambda {
          manager.service_with_identifier(:awsum_service)
        }.should raise_exception
      end
    end
  end
end