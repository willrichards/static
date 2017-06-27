class AnalyticsMetatagsRenderer
  def self.render(content_item)
    analytics_metatags_presenter =
      AnalyticsMetatagsPresenter.new(content_item)

    ActionController::Base.new.render_to_string(
      template: 'govuk_components/analytics_metatags',
      locals: {
        metatags: analytics_metatags_presenter.metatags,
      }
    )
  end
end
