module CampusSolutions
  class DelegateManagementURL < DirectProxy

    include DelegatedAccessFeatureFlagged

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'delegate_management_url.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_DELEGATED_ACCESS_URL.v1/get"
    end

  end
end
