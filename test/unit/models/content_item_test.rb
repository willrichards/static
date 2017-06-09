require 'test_helper'
require 'govuk_schemas'

describe ContentItem do

  should 'have a title' do
    payload = content_item_payload
    content_item = ContentItem.new(payload)

    assert_equal(payload['title'], content_item.title)
  end

  should 'have a base path' do
    payload = content_item_payload
    content_item = ContentItem.new(payload)

    assert_equal(payload['base_path'], content_item.base_path)
  end

  should 'have a description' do
    payload = content_item_payload
    content_item = ContentItem.new(payload)

    assert_equal(payload['description'], content_item.description)
  end

  should 'have a content_id' do
    payload = content_item_payload
    content_item = ContentItem.new(payload)

    assert_equal(payload['content_id'], content_item.content_id)
  end

  context '#parent_taxon' do
    should 'be a content item as well' do
      payload = content_item_payload
      content_item = ContentItem.new(payload)

      assert_equal(ContentItem, content_item.parent_taxon.class)
    end
  end

  def content_item_payload(frontend_schema: 'detailed_guide')
    example = GovukSchemas::RandomExample.for_schema(
      frontend_schema: frontend_schema
    )

    example.merge_and_validate(
      title: 'Document title',
      description: 'Document description',
    )

    example.payload
  end

end
