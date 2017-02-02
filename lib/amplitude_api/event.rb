class AmplitudeAPI
  # AmplitudeAPI::Event
  class Event
    # @!attribute [ rw ] user_id
    #   @return [ String ] the user_id to be sent to Amplitude
    attr_accessor :user_id
    # @!attribute [ rw ] device_id
    #   @return [ String ] the device_id to be sent to Amplitude
    attr_accessor :device_id
    # @!attribute [ rw ] event_type
    #   @return [ String ] the event_type to be sent to Amplitude
    attr_accessor :event_type
    # @!attribute [ rw ] event_properties
    #   @return [ String ] the event_properties to be attached to the Amplitude Event
    attr_accessor :event_properties
    # @!attribute [ rw ] user_properties
    #   @return [ String ] the user_properties to be passed for the user
    attr_accessor :user_properties
    # @!attribute [ rw ] time
    #   @return [ Time ] Time that the event occurred (defaults to now)
    attr_accessor :time
    # @!attribute [ rw ] ip
    #   @return [ String ] IP address of the user
    attr_accessor :ip

    # @!attribute [ rw ] insert_id
    #   @return [ String ] the unique identifier to be sent to Amplitude
    attr_accessor :insert_id

    # @!attribute [ rw ] session_id
    #   @return [ Long ] the start time of the session in milliseconds since epoch
    attr_accessor :session_id

    # @!attribute [ rw ] price
    #   @return [ String ] (required for revenue data) price of the item purchased
    attr_accessor :price

    # @!attribute [ rw ] quantity
    #   @return [ String ] (required for revenue data, defaults to 1 if not specified) quantity of the item purchased
    attr_accessor :quantity

    # @!attribute [ rw ] product_id
    #   @return [ String ] an identifier for the product. (Note: you must send a price and quantity with this field)
    attr_accessor :product_id

    # @!attribute [ rw ] revenue_type
    #   @return [ String ] type of revenue. (Note: you must send a price and quantity with this field)
    attr_accessor :revenue_type

    attr_accessor :app_version, :platform,
                  :os_name, :os_version,
                  :device_brand, :device_manufacturer, :device_model, :device_type,
                  :carrier

    # Create a new Event
    #
    # @param [ String ] user_id a user_id to associate with the event
    # @param [ String ] device_id a device_id to associate with the event
    # @param [ String ] event_type a name for the event
    # @param [ Hash ] event_properties various properties to attach to the event
    # @param [ Time ] Time that the event occurred (defaults to now)
    # @param [ Double ] price (optional, but required for revenue data) price of the item purchased
    # @param [ Integer ] quantity (optional, but required for revenue data) quantity of the item purchased
    # @param [ String ] product_id (optional) an identifier for the product.
    # @param [ String ] revenue_type (optional) type of revenue
    # @param [ String ] IP address of the user
    # @param [ String ] insert_id a unique identifier for the event
    # @param [ Long ] session_id the start time of the session in milliseconds since epoch
    def initialize(attributes = {})
      self.user_id = getopt(attributes, :user_id, '')
      self.device_id = getopt(attributes, :device_id, nil)
      self.event_type = getopt(attributes, :event_type, '')
      self.event_properties = getopt(attributes, :event_properties, {})
      self.user_properties = getopt(attributes, :user_properties, {})
      self.time = getopt(attributes, :time)
      self.ip = getopt(attributes, :ip, '')
      self.insert_id = getopt(attributes, :insert_id)
      self.session_id = getopt(attributes, :session_id)
      validate_revenue_arguments(attributes)
      initialize_device_info_arguments(attributes)
    end

    def user_id=(value)
      @user_id =
        if value.respond_to?(:id)
          value.id
        else
          value || AmplitudeAPI::USER_WITH_NO_ACCOUNT
        end
    end

    # @return [ Hash ] A serialized Event
    #
    # Used for serialization and comparison
    def to_hash
      serialized_event = {}
      serialized_event[:event_type] = event_type
      serialized_event[:user_id] = user_id
      serialized_event[:event_properties] = event_properties
      serialized_event[:user_properties] = user_properties
      serialized_event = add_optional_properties(serialized_event)
      serialized_event.merge(revenue_hash).merge(device_info_hash)
    end

    # @return [ Hash ] A serialized Event with optional properties
    def add_optional_properties(serialized_event)
      serialized_event[:device_id] = device_id if device_id
      serialized_event[:time] = formatted_time if time
      serialized_event[:ip] = ip if ip
      serialized_event[:insert_id] = insert_id if insert_id
      serialized_event[:session_id] = formatted_session_id if session_id
      serialized_event
    end

    # @return [ true, false ]
    #
    # Compares +to_hash+ for equality
    def ==(other)
      if other.respond_to?(:to_hash)
        to_hash == other.to_hash
      else
        false
      end
    end

    private

    def formatted_time
      milliseconds_from_epoch_for(time)
    end

    def formatted_session_id
      if session_id.is_a?(Time)
        milliseconds_from_epoch_for(session_id)
      else
        session_id
      end
    end

    def milliseconds_from_epoch_for(time)
      (time.to_f * 1000).to_i
    end

    def validate_revenue_arguments(options)
      self.price = getopt(options, :price)
      self.quantity = getopt(options, :quantity, 1) if price
      self.product_id = getopt(options, :product_id)
      self.revenue_type = getopt(options, :revenue_type)
      return if price
      raise ArgumentError, 'You must provide a price in order to use the product_id' if product_id
      raise ArgumentError, 'You must provide a price in order to use the revenue_type' if revenue_type
    end

    def initialize_device_info_arguments(options)
      self.app_version = getopt(options, :app_version)
      self.platform = getopt(options, :platform)
      self.os_name = getopt(options, :os_name)
      self.os_version = getopt(options, :os_version)

      self.device_brand = getopt(options, :device_brand)
      self.device_manufacturer = getopt(options, :device_manufacturer)
      self.device_model = getopt(options, :device_model)
      self.device_type = getopt(options, :device_type)
      self.carrier = getopt(options, :carrier)
    end

    def revenue_hash
      revenue_hash = {}
      revenue_hash[:productId] = product_id if product_id
      revenue_hash[:revenueType] = revenue_type if revenue_type
      revenue_hash[:quantity] = quantity if quantity
      revenue_hash[:price] = price if price
      revenue_hash
    end

    def device_info_hash
      { app_version:         app_version,
        platform:            platform,
        os_name:             os_name,
        os_version:          os_version,

        device_brand:        device_brand,
        device_manufacturer: device_manufacturer,
        device_model:        device_model,
        device_type:         device_type,
        carrier:             carrier }
    end

    def getopt(options, key, default = nil)
      options.fetch(key.to_sym, options.fetch(key.to_s, default))
    end
  end
end
