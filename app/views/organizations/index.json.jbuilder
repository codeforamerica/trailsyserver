json.array!(@organizations) do |organization|
  json.extract! organization, :code, :full_name, :phone, :url
  json.url organization_url(organization, format: :json)
end
