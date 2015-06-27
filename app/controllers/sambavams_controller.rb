class SambavamsController < ApplicationController
  def index
    locations_json = locations_from_cluster
    locations_to_plot = locations(locations_json)
  end

  private
  def locations_from_cluster
    location_ids = '[{"id":"0"},{"id":"1"},{"id":"2"},{"id":"3"}]'
    url = 'https://api-eu.clusterpoint.com/1201/YaamirukaBayamen/_lookup.json'
    resource = RestClient::Resource.new(url, user: 'radhikab@thoughtworks.com', password: 'radhikab')
    response = resource.post(location_ids)
    JSON.parse(response.body)
  end

  def locations(locations_json)
    locations = []
    locations_json["documents"].each do |location|
      locations << Location.new(name: location["name"], latitude: location["lat"], longitude: location["long"])
    end
    locations
  end
end