(function() {
  "use strict";

  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  /* This data structure is explained in `doc/surveys.md` */
  var userSurveys = {
    init: function() {
      var activeSurvey = userSurveys.getActiveSurvey();
      if (userSurveys.isSurveyToBeDisplayed(activeSurvey)) {
        userSurveys.displaySurvey(activeSurvey);
      }
    },

    getActiveSurvey: function() {
      var activeSurvey = userSurveys.getDefaultSurvey();

      $('.user-satisfaction-survey').each(function(survey) {
        if(userSurveys.surveyInTimeWindow(survey)) {
          if(userSurveys.surveyAppliesToCurrentPage(survey)) {
            activeSurvey = survey;
          }
        }
      });

      return activeSurvey;
    },

    surveyInTimeWindow: function(survey) {
      var startDate = $(survey).data('start-date');
      var endDate = $(survey).data('end-date');

      return (userSurveys.currentTime() >= startDate && userSurveys.currentTime() <= endDate)
    },

    surveyAppliesToCurrentPage: function(survey) {
      return (surveyOrganisationMatches(survey) || surveyPathMatches(survey) || surveyBreadcrumbsMatches(survey) || surveySectionMatches(survey))
    },

    surveyOrganisationMatches: function(survey) {
      //TODO: Check match on $(survey).data('organisation-tags') with $('meta[name="govuk:analytics:organisations"]').attr('content') || "";
    },
    surveyPathMatches: function(survey) {
      //TODO: Check match on $(survey).data('paths') against userSurveys.currentPath()
    },
    surveyBreadcrumbsMatches: function(survey) {
      //TODO: Check match on $(survey).data('breadcrumbs') with $('.govuk-breadcrumbs').text() || "";
    },
    surveySectionMatches: function(survey) {
      //TODO: Check match on $(survey).data('sections') with $('meta[name="govuk:section"]').attr('content');
    },

    getDefaultSurvey: function() {
      $('#user-satisfaction-survey-container .user-satisfaction-survey.default')[0];
    },

    displaySurvey: function(survey) {
      userSurveys.setEventHandlers(survey);

      var $surveyLink = $(survey).find('.take-survey');
      var surveyUrl = $(survey).attr('href');

      // Survey monkey can record the URL of the survey link if passed through as a query param
      if ((/surveymonkey/.test(surveyUrl)) && (surveyUrl.indexOf('?c=') === -1)) {
        surveyUrl += "?c=" + root.location.pathname;
      }

      $surveyLink.attr('href', surveyUrl);
      userSurveys.trackEvent(survey.identifier, 'banner_shown', 'Banner has been shown');
    },

    setEventHandlers: function(survey) {
      var $noThanks = $(survey).find('.survey-no-thanks');
      var $takeSurvey = $(survey).find('.take-survey');

      $noThanks.click(function (e) {
        userSurveys.setSurveyTakenCookie(survey);
        userSurveys.trackEvent(survey.identifier, 'banner_no_thanks', 'No thanks clicked');
        e.stopPropagation();
        return false;
      });
      $takeSurvey.click(function () {
        userSurveys.setSurveyTakenCookie(survey);
        userSurveys.trackEvent(survey.identifier, 'banner_taken', 'User taken survey');
      });
    },

    isSurveyToBeDisplayed: function(survey) {
      if (userSurveys.pathInBlacklist()) {
        return false;
      } else if (userSurveys.otherNotificationVisible() ||
          GOVUK.cookie(userSurveys.surveyTakenCookieName(survey)) === 'true') {
        return false;
      } else if (userSurveys.userCompletedTransaction()) {
        // We don't want any survey appearing for users who have completed a
        // transaction as they may complete the survey with the department's
        // transaction in mind as opposed to the GOV.UK content.
        return false;
      } else if ($('#user-satisfaction-survey-container').length <= 0) {
        return false;
      } else if (userSurveys.randomNumberMatches($(survey).data('frequency'))) {
        return true;
      } else {
        return false;
      }
    },

    pathInBlacklist: function() {
      var blackList = new RegExp('^/(?:'
        + /service-manual/.source
        // add more blacklist paths in the form:
        // + /|path-to\/blacklist/.source
        + ')(?:\/|$)'
      );
      return blackList.test(userSurveys.currentPath());
    },

    userCompletedTransaction: function() {
      var path = userSurveys.currentPath();

      function stringContains(str, substr) {
        return str.indexOf(substr) > -1;
      }

      if (stringContains(path, "/done") ||
          stringContains(path, "/transaction-finished") ||
          stringContains(path, "/driving-transaction-finished")) {
            return true;
      }
    },

    trackEvent: function (identifier, action, label) {
      GOVUK.analytics.trackEvent(identifier, action, {
        label: label,
        value: 1,
        nonInteraction: true
      });
    },

    setSurveyTakenCookie: function (survey) {
      GOVUK.cookie(userSurveys.surveyTakenCookieName(survey), true, { days: 30*4 });
      $("#user-satisfaction-survey").removeClass('visible').attr('aria-hidden', 'true');
    },

    randomNumberMatches: function(frequency) {
      return (Math.floor(Math.random() * frequency) === 0);
    },

    otherNotificationVisible: function() {
      return $('#banner-notification:visible, #global-cookie-message:visible, #global-browser-prompt:visible').length > 0;
    },

    surveyTakenCookieName: function(survey) {
      //user_satisfaction_survey => takenUserSatisfactionSurvey
      var cookieStr = "taken_" + $(survey).data('identifier');
      var cookieStub = cookieStr.replace(/(\_\w)/g, function(m){return m[1].toUpperCase();});
      return "govuk_" + cookieStub;
    },

    currentTime: function() { return new Date().getTime(); },
    currentPath: function() { return window.location.pathname; }
  };

  root.GOVUK.userSurveys = userSurveys;
}).call(this);

