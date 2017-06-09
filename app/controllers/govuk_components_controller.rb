class GovukComponentsController < ApplicationController
  # todo: how do we pass options like collapse_on_mobile to partials?
  def show
    respond_to do |format|
      format.json { render json: components }
    end
  end

private

  def base_path
    "/#{params[:base_path]}"
  end

  def content_item
    ContentItem.find_and_initialize(base_path)
  end

  def components
    {
      base_path: base_path,
      breadcrumbs: BreadcrumbRenderer.render(content_item)
    }
  end
end
