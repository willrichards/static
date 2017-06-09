require 'gds_api/content_store'

class GovukApis
  def self.content_store
    @content_store ||= GdsApi::ContentStore.new(Plek.new.find('content-store'))
  end
end
