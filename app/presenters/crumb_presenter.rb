class CrumbPresenter
  attr_reader :title, :url, :is_current_page, :is_page_parent

  def initialize(title:, url:, is_current_page: false, is_page_parent: false)
    @title = title
    @url = url
    @is_current_page = is_current_page
    @is_page_parent = is_page_parent
  end

  def is_link?
    url.present? || is_current_page
  end

  def path
    is_current_page ? '#content' : url
  end

  def aria_current
    is_current_page ? 'page' : 'false'
  end

  def css_class
    is_current_page ? 'breadcrumb-for-current-page' : ''
  end
end
