module HubEdos
  class Contacts < Student

    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(options)
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/contacts"
    end

    def xml_filename
      'contacts.xml'
    end

    def include_fields
      %w(identifiers names addresses phones emails urls emergencyContacts confidential)
    end

  end
end
