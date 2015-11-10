module CampusSolutions
  class DelegateAccessCreate < PostingProxy

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def self.field_mappings
      @field_mappings ||= FieldMapping.to_hash(
        [
          FieldMapping.required(:proxyEmailAddress, :SCC_DA_PRXY_EMAIL),
          FieldMapping.required(:securityKey, :SCC_DA_SECURTY_KEY)
        ]
      )
    end

    def default_post_params
      {
        SCC_DA_PRXY_OPRID: @uid
      }
    end

    def request_root_xml_node
      'DA_VAL_CREATE_REQ'
    end

    def response_root_xml_node
      'DA_VAL_CREATE_STATUS'
    end

    def xml_filename
      'delegate_access_create.xml'
    end

    def url
      "#{@settings.base_url}/UC_VAL_DA_CREATE_SCRTY.v1/CreateDASecurity/post/"
    end

  end
end
