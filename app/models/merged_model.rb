module MergedModel

  def handling_provider_exceptions(feed, providers)
    providers.each do |provider|
      begin
        yield provider
      rescue => e
        logger.error "Failed to merge #{provider_class_name(provider)} for UID #{@uid}: #{e.class}: #{e.message}\n #{e.backtrace.join("\n ")}"
        feed[:errors] ||= []
        feed[:errors] << provider_class_name(provider)
      end
    end
  end

  def provider_class_name(provider)
    provider.to_s
  end

end
