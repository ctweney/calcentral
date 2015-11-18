module CampusSolutions
  module PersonDataExpiry
    def self.expire(uid=nil)
      [HubEdos::Student, HubEdos::MyStudent,
       HubEdos::Contacts, HubEdos::Demographics, HubEdos::Affiliations].each do |klass|
        klass.expire uid
      end
    end

    def self.expire_on_profile_change(uid=nil)
      [HubEdos::Contacts, HubEdos::MyStudent].each do |klass|
        klass.expire uid
      end
    end
  end
end
