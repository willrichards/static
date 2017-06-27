class AnalyticsMetatagsPresenter
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item
  end

  def metatags
    metatags = {}
    metatags.merge!(format)
    metatags.merge!(schema_name)
    metatags.merge!(organisations_content)
    metatags.merge!(worldwide_locations_content)
    metatags.merge!(political_details)
    metatags.merge!(user_journey_stage)
    metatags.merge!(navigation_document_type)
    metatags.merge!(themes)
    metatags.merge!(taxons_content)
    metatags.merge!(content_history)

    metatags
  end

private

  def format
    return {} if content_item.document_type.nil?

    { "govuk:format" => content_item.document_type  }
  end

  def schema_name
    return {} if content_item.schema_name.nil?

    { "govuk:schema-name" => content_item.schema_name }
  end

  def organisations
    organisations = []

    organisations += links_hash[:organisations] || []
    organisations += links_hash[:worldwide_organisations] || []

    organisations
  end

  def organisations_content
    return {} if organisations.empty?

    content =
      organisations.map { |link| "<#{link[:analytics_identifier]}>" }.uniq.join

    { "govuk:analytics:organisations" => content }
  end

  def worldwide_locations_content
    world_locations = links_hash[:world_locations] || []

    return {} if world_locations.empty?

    world_locations_content =
      world_locations.map { |link| "<#{link[:analytics_identifier]}>" }.join

    { "govuk:analytics:world-locations" => world_locations_content }
  end

  def political_details
    return {} unless details_hash.key?(:political) && details_hash.key?(:government)

    political_status = "non-political"
    if details_hash[:political]
      political_status = details_hash[:government][:current] ? "political" : "historic"
    end

    {
      "govuk:political-status" => political_status,
      "govuk:publishing-government" => details_hash[:government][:slug]
    }
  end

  def user_journey_stage
    user_journey_stage = content_item.user_journey_document_supertype
    return {} if user_journey_stage.nil?

    { "govuk:user-journey-stage" => user_journey_stage }
  end

  def navigation_document_type
    navigation_document_type = content_item.navigation_document_supertype

    return {} if navigation_document_type.nil?

    { "govuk:navigation-document-type" => navigation_document_type }
  end

  def themes
    themes = root_taxon_slugs(content_item)

    return {} if themes.empty?

    { "govuk:themes" => themes.to_a.sort.join(', ') }
  end

  def taxons_content
    if content_item.document_type == 'taxon'
      taxons = [content_item]
    else
      taxons = links_hash[:taxons] || []
    end

    taxons.sort_by! { |taxon| taxon[:title] }
    taxon_slugs_without_theme = taxons.map do |taxon|
      base_path = taxon[:base_path] || ""
      slug_without_theme = base_path[%r{/[^/]+/(.+)}, 1]
      # Return the slug without the theme, or in the special case of a root taxon,
      # just return the full slug (because it doesn't have a slug beneath the theme)
      slug_without_theme || base_path.sub(%r(^/), '')
    end
    taxon_ids = taxons.map { |taxon| taxon[:content_id] }

    data = {}
    data["govuk:taxon-id"] = taxon_ids.first unless taxon_ids.empty?
    data["govuk:taxon-ids"] = taxon_ids.join(',') unless taxon_ids.empty?
    data["govuk:taxon-slug"] = taxon_slugs_without_theme.first unless taxon_slugs_without_theme.empty?
    data["govuk:taxon-slugs"] = taxon_slugs_without_theme.join(',') unless taxon_slugs_without_theme.empty?

    data
  end

  def content_history
    return {} unless has_content_history(content_item)

    { "govuk:content-has-history" => "true" }
  end

  def links_hash
    content_item.links
  end

  def details_hash
    content_item.details
  end

  def root_taxon_slugs(content_item)
    root_taxon_set = Set.new

    links = content_item.links
    # Taxons will have :parent_taxons, but content items will have :taxons
    parent_taxons = links[:parent_taxons] || links[:taxons] unless links.nil?

    if parent_taxons.blank?
      if content_item.document_type == 'taxon'
        root_taxon_set << content_item.base_path.sub(%r(^/), '')
      end
    else
      parent_taxons.each do |parent_taxon|
        root_taxon_set += root_taxon_slugs(parent_taxon)
      end
    end

    root_taxon_set
  end

  def has_content_history(content_item)
    details = content_item.details

    (content_item.public_updated_at && details[:first_public_at] && content_item.public_updated_at != details[:first_public_at]) ||
      (details[:change_history] && details[:change_history].size > 1)
  end
end
