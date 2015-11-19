module CampusSolutions
  class DelegateManagementURL < DirectProxy

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def response_root_xml_node
      'DELEGATED_ACCESS_URL'
    end

    def xml_filename
      'delegate_management_url.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_DELEGATED_ACCESS_URL.v1/get"
    end

  end
end
