module HubEdos
  class Affiliations < Student

    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(options)
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/affiliation"
    end

    def xml_filename
      'affiliations.xml'
    end

    def include_fields
      %w(affiliations)
    end

  end
end
