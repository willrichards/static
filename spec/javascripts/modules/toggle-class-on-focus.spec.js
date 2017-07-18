/* eslint-env jasmine */
/* eslint-disable no-multi-str */

describe('A toggle class module', function () {
  'use strict';

  var element, toggle;

  afterEach(function(){
    element.remove();
  });

  describe('when the search box is interacted with', function () {
    beforeEach(function () {
      element = $('\
        <form class="govuk-search" action="/search" method="get" role="search" data-module="toggle-class-on-focus">\
          <label for="search-box" class="search-label">Search GOV.UK</label>\
          <div class="search-wrapper">\
            <input type="search" id="search-box" name="q" title="Search" class="search-element search-input js-class-toggle">\
            <div class="search-element search-submit-wrapper">\
              <button type="submit" class="search-submit">Search</button>\
            </div>\
          </div>\
        </form>')

      $('body').append(element);
      toggle = new GOVUK.Modules.ToggleInputClassOnFocus();
      toggle.start(element);
    });

    it('applies the focus style on focus and removes it on blur', function () {
      var searchInput = element.find('.js-class-toggle');
      expect(searchInput.is('.focus')).toBe(false);
      searchInput.trigger('focus');
      expect(searchInput.is('.focus')).toBe(true);
      searchInput.trigger('blur');
      expect(searchInput.is('.focus')).toBe(false);
    });
  });

  describe('when the search box has a value', function () {
    beforeEach(function () {
      element = $('\
        <form class="govuk-search" action="/search" method="get" role="search" data-module="toggle-class-on-focus">\
          <label for="search-box" class="search-label">Search GOV.UK</label>\
          <div class="search-wrapper">\
            <input type="search" id="search-box" name="q" title="Search" value="Find this" class="search-element search-input js-class-toggle">\
            <div class="search-element search-submit-wrapper">\
              <button type="submit" class="search-submit">Search</button>\
            </div>\
          </div>\
        </form>')

      $('body').append(element);
      toggle = new GOVUK.Modules.ToggleInputClassOnFocus();
      toggle.start(element);
    });

    it('applies the focus style on load if the search box already has a value', function() {
      var searchInput = element.find('.js-class-toggle');
      expect(searchInput.is('.focus')).toBe(true);
    });

    it('does not remove the focus style on blur if the search box already has a value', function() {
      var searchInput = element.find('.js-class-toggle');
      searchInput.trigger('focus');
      expect(searchInput.is('.focus')).toBe(true);
      searchInput.trigger('blur');
      expect(searchInput.is('.focus')).toBe(true);
    });
  });
});
