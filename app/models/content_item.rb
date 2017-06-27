class ContentItem
  attr_reader :content_store_response

  def self.find_and_initialize(base_path)
    new(GovukApis.content_store.content_item(base_path))
  end

  def initialize(content_store_response)
    @content_store_response = content_store_response.to_h
  end

  def parent
    parent_item = content_store_response.dig("links", "parent", 0)
    return unless parent_item
    ContentItem.new(parent_item)
  end

  def parent_taxon
    # TODO: Determine what to do when there are multiple taxons/parents. For
    # now just display the first of each.
    parent_taxons.sort_by(&:title).first
  end

  def parent_taxons
    # First handle the case for content items tagged to the taxonomy.
    taxons = Array(content_store_response.dig("links", "taxons"))
    return taxons.map { |taxon| ContentItem.new(taxon) }.sort_by(&:title) if taxons.any?

    # If that link isn't present, assume we're dealing with a taxon and check
    # for its parents in the taxonomy.
    parent_taxons = Array(content_store_response.dig("links", "parent_taxons"))
    parent_taxons.map { |taxon| ContentItem.new(taxon) }.sort_by(&:title)
  end

  def mainstream_browse_pages
    content_store_response.dig("links", "mainstream_browse_pages").to_a.map do |link|
      ContentItem.new(link)
    end
  end

  [
    :content_id,
    :title,
    :base_path,
    :document_type,
    :schema_name,
    :description,
    :user_journey_document_supertype,
    :navigation_document_supertype,
    :public_updated_at,
  ].each do |method_name|
    define_method method_name do
      content_store_response.dig(method_name.to_s)
    end
  end

  def related_links
    content_store_response.dig("links", "ordered_related_items").to_a.map do |link|
      ContentItem.new(link)
    end
  end

  def links
    content_store_response.dig('links')
  end

  def details
    content_store_response.dig('details')
  end

  def external_links
    content_store_response.dig("details", "external_related_links").to_a
  end
end
