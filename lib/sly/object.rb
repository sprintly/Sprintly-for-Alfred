class Sly::Object
  def initialize(attributes={})
    self.attr_from_hash!(attributes)
  end

  def attr_from_hash!(attributes)
    raise "Attributes must be in a Hash" unless attributes.kind_of? Hash

    attributes.each do |key, val|
      if(self.respond_to?(key.to_s+"="))
        self.send(key.to_s+"=", val)
      end
    end

    ["created_at", "last_login", "last_modified"].map do |attribute|
        self.parse_attr(attribute) { |date| (date.kind_of?(String)) ? DateTime.iso8601(date) : DateTime.new }
    end

    ["assigned_to", "created_by"].map do |attribute|
        self.parse_attr(attribute, {}) { |attributes| Sly::Person.new(attributes) }
    end

    ["product"].map do |attribute|
        self.parse_attr(attribute, {}) { |attributes| Sly::Product.new(attributes) }
    end
  end

  def to_hash
    hash = {}
    self.instance_variables.each do |var| 
      value = self.instance_variable_get(var)

      if(value.kind_of?(Sly::Object))
        value = value.to_hash
      elsif(value.kind_of?(DateTime))
        value = value.iso8601
      end

      hash[var[1..-1].to_sym] = value
    end
    hash
  end

  def to_json
    self.to_hash.to_json
  end

  def parse_attr(attribute, nil_value=nil, &block)
    if(self.respond_to?(attribute+"="))
      value = self.send(attribute)

      if(!value.kind_of?(Sly::Object))
        value = nil_value if value == nil
        self.send(attribute+"=", block.call(value))
      end
    end
  end
end