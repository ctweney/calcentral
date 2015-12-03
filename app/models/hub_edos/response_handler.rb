module HubEdos
  module ResponseHandler

    def get_students(response)
      return [] unless response.is_a? Hash
      container = response['studentResponse']
      # Verify that target element is capable of being iterated. And yes, the structure really is this weird.
      return [] unless container.present? && container['students'].present? && container['students']['students'].respond_to?(:each)
      container['students']['students']
    end

  end
end
