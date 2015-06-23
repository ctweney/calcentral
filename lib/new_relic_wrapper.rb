class NewRelicWrapper
  def self.record_custom_event(event_type, event_attrs)
    enabled = !!(defined?(::NewRelic::Agent))
    Rails.logger.debug "New Relic enabled: #{enabled}. Sending custom event: #{event_type}, data: #{event_attrs.inspect}"
    if enabled
      ::NewRelic::Agent.record_custom_event(event_type, event_attrs)
    end
  end
end
