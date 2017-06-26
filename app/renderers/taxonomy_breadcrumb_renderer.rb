class TaxonomyBreadcrumbRenderer
  def self.render(content_item)
    breadcrumb_presenter =
      TaxonomyBreadcrumbPresenter.new(content_item, collapse_on_mobile: false)

    ActionController::Base.new.render_to_string(
      template: 'govuk_components/breadcrumbs',
      locals: {
        breadcrumbs: breadcrumb_presenter.breadcrumbs,
        collapse_on_mobile_css_class: breadcrumb_presenter.collapse_on_mobile_css_class
      }
    )
  end
end
