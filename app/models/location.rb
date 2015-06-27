class Location
  attr_accessor :name, :latitude, :longitude

  def initialize(options)
    self.name = options[:name]
    self.latitude = options[:latitude]
    self.longitude = options[:longitude]
  end
end