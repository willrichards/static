class TaxonomyBreadcrumbPresenter
  def initialize(content_item, options = {})
    @content_item = content_item
    @options = options
  end

  def breadcrumbs
    ordered_parents = all_parents.map.with_index do |parent, index|
      CrumbPresenter.new(
        title: parent.title,
        url: parent.base_path,
        is_page_parent: index == 0
      )
    end

    ordered_parents << CrumbPresenter.new(title: "Home", url: "/")

    ordered_breadcrumbs = ordered_parents.reverse
    ordered_breadcrumbs << CrumbPresenter.new(
      title: content_item.title,
      url: nil,
      is_current_page: true
    )

    ordered_breadcrumbs
  end

  def collapse_on_mobile_css_class
    "collapse-on-mobile" if options[:collapse_on_mobile] && parent_pages?
  end

  def parent_pages?
    breadcrumbs.any? { |crumb| crumb.is_page_parent }
  end

  def get_binding
    binding()
  end

private

  attr_reader :content_item, :options

  def all_parents
    parents = []

    direct_parent = content_item.parent_taxon
    while direct_parent
      parents << direct_parent
      direct_parent = direct_parent.parent_taxon
    end

    parents
  end
end
