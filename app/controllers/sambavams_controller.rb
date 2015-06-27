class SambavamsController < ApplicationController
  def index
  end

  def plot
    location_ids = '[{"id":"0"},{"id":"1"},{"id":"2"},{"id":"3"}]'
    user = 'radhikab@thoughtworks.com'
    password = 'radhikab'
    fetch_url = 'https://api-eu.clusterpoint.com/1201/YaamirukaBayamen/_lookup.json'
    locations = locations_from_cluster(location_ids, fetch_url, user, password)
    render json: locations, status: :ok
  end

  private
  def locations_from_cluster(payload, cluster_url, username, password)
    resource = RestClient::Resource.new(cluster_url, user: username, password: password)
    response = resource.post(payload)
    response.body
  end
end