class SambavamsController < ApplicationController
  def index
  end

  def plot
    location_ids = '[{"id":"0"},{"id":"1"},{"id":"2"},{"id":"3"}]'
    user = 'radhikab@thoughtworks.com'
    password = 'radhikab'
    user_id = '1201'
    fetch_url = "https://api-eu.clusterpoint.com/#{user_id}/YaamirukaBayamen/_lookup.json"
    @locations = locations_from_cluster(location_ids, fetch_url, user, password)
    render json: @locations, status: :ok
  end

  def safe_routes
    location_ids = '[{"id":"0"},{"id":"1"},{"id":"2"},{"id":"3"}]'
    user = 'radhikab@thoughtworks.com'
    password = 'radhikab'
    user_id = '1201'
    fetch_url = "https://api-eu.clusterpoint.com/#{user_id}/YaamirukaBayamen/_lookup.json"
    @locations = locations_from_cluster(location_ids, fetch_url, user, password)

    api_key = 'AIzaSyAYU_fYcPQGp1FnLfH4W0F07hofMQkvZcQ'
    origin = 'Porur,IN'
    destination = 'Adyar,IN'
    url = "https://maps.googleapis.com/maps/api/directions/json?origin=#{origin}&destination=#{destination}&key=#{api_key}"
    paths = []
    routes_json = routes_from_maps(url)
    routes_json["routes"].each do |route|
      ne_bound = route["bounds"]["northeast"]
      sw_bound = route["bounds"]["southwest"]
      path = Path.new(start_point: origin, end_point: destination, occurences: 0, unsafe_measure: 0, bounds: [ne_bound,sw_bound])
      path = traverse_route(route, path)
      paths << path
    end
    routes = categorised_routes(paths)
    route_bounds = []
    routes[0].each do |route|
      route_bounds << {"bounds"=>[{"lat"=>route.bounds[0]["lat"],"lng"=>route.bounds[0]["lng"]},
                         {"lat"=>route.bounds[1]["lat"],"lng"=>route.bounds[1]["lng"]}]
      }
    end
    routes[1].each do |route|
      route_bounds << {"bounds"=>[{"lat"=>route.bounds[0]["lat"],"lng"=>route.bounds[0]["lng"]},
                                  {"lat"=>route.bounds[1]["lat"],"lng"=>route.bounds[1]["lng"]}]
      }
    end
    render json: route_bounds, status: :ok
  end

  private
  def locations_from_cluster(payload, cluster_url, username, password)
    resource = RestClient::Resource.new(cluster_url, user: username, password: password)
    response = resource.post(payload)
    response.body
  end

  def locations(locations_json)
    locations = []
    locations_json = JSON.parse(locations_json)
    locations_json["documents"].each do |location|
      locations << Location.new(name: location["name"], latitude: location["lat"].to_f, longitude: location["long"].to_f, occurences: location["occurences"].to_i)
    end
    locations
  end

  def routes_from_maps(url)
    resource = RestClient::Resource.new(url)
    response = resource.get
    JSON.parse(response.body)
  end

  def update_path(crisis_locations, path, latitude, longitude)
    matching_crisis_locations = crisis_locations.select { |loc| loc.latitude == latitude && loc.longitude == longitude }
    if matching_crisis_locations.present?
      path.occurences += 1
      path.unsafe_measure += matching_crisis_locations.first.occurences.to_i
    end
    path
  end

  def traverse_route(route, path)
    points = []
    route["legs"].each do |leg|
        leg["steps"].each do |step|
          start_point_lat = step["start_location"]["lat"]
          start_point_long = step["start_location"]["lng"]
          crisis_locations = locations(@locations)
          update_path(crisis_locations, path, start_point_lat, start_point_long) unless points.include?([start_point_lat,start_point_long])
          points << [start_point_lat, start_point_long]
          end_point_lat = step["end_location"]["lat"]
          end_point_long = step["end_location"]["lng"]
          update_path(crisis_locations, path, end_point_lat, end_point_long) unless points.include?([end_point_lat,end_point_long])
          points << [end_point_lat, end_point_long]
        end
    end
    path
  end

  def categorised_routes(paths)
    minimum_occurence = paths.collect(&:occurences).min
    minimum_weightage = paths.collect(&:unsafe_measure).min
    routes_with_min_occurence = paths.select {|path| path.occurences == minimum_occurence}
    if minimum_occurence == 0
      [routes_with_min_occurence,nil]
    else
      routes_with_min_unsafe_measure = paths.select {|path| path.unsafe_measure == minimum_weightage}
      [routes_with_min_occurence,routes_with_min_unsafe_measure]
    end
  end
end