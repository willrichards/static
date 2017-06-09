class BreadcrumbPresenter
  def initialize(content_item, options = {})
    @content_item = content_item
    @options = options
  end

  def breadcrumbs
    @breadcrumbs ||= begin
      ordered_parents = all_parents.map do |parent|
        CrumbPresenter.new(title: parent.title, url: parent.base_path)
      end

      ordered_parents << CrumbPresenter.new(title: "Home", url: "/")

      ordered_parents.reverse
    end
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

    direct_parent = content_item.parent
    while direct_parent
      parents << direct_parent

      direct_parent = direct_parent.parent
    end

    parents
  end
end
