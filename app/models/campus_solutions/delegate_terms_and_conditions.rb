module CampusSolutions
  class DelegateTermsAndConditions < DirectProxy

    include DelegatedAccessFeatureFlagged

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'delegate_terms_and_conditions.xml'
    end

    def url
      "#{@settings.base_url}/UC_DA_T_C.v1/get"
    end

  end
end
