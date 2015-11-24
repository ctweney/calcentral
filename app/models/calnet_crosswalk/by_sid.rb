module CalnetCrosswalk
  class BySid < Proxy

    def url
      "#{@settings.base_url}/LEGACY_SIS_STUDENT_ID/#{@uid}"
    end

    def mock_request
      super.merge(uri_matching: "#{@settings.base_url}/LEGACY_SIS_STUDENT_ID/#{@uid}")
    end

  end
end
