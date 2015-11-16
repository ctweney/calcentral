module CampusSolutions
  class DelegateStudents < DirectProxy

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def build_feed(response)
      feed = response.parsed_response
      return {} if feed.blank?
      feed = feed['ROOT']['STUDENT_DELEGATED_ACCESS'] if feed['ROOT'] && feed['ROOT']['STUDENT_DELEGATED_ACCESS']
      feed
    end

    def xml_filename
      'delegate_access_students.xml'
    end

    def url
      "#{@settings.base_url}/UC_CC_DELEGATED_ACCESS.v1/DelegatedAccess/get?SCC_DA_PRXY_OPRID=#{@uid}"
    end

  end
end
