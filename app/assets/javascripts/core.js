$(document).ready(function() {
  $('.print-link a').attr('target', '_blank');

  if (window.GOVUK) {
    // for radio buttons and checkboxes
    var buttonsSelector = "label.selectable input[type='radio'], label.selectable input[type='checkbox']";
    new GOVUK.SelectionButtons(buttonsSelector);

    if (GOVUK.shimLinksWithButtonRole) {
      GOVUK.shimLinksWithButtonRole.init();
    }

    // HMRC webchat
    if (GOVUK.webchat) {
      GOVUK.webchat.init();
    }
  }
});
