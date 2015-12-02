module CalnetCrosswalk
  class ByUid < Proxy

    def url
      "#{@settings.base_url}/UID/#{@uid}"
    end

    def mock_request
      super.merge(uri_matching: "#{@settings.base_url}/UID/#{@uid}")
    end

  end
end
