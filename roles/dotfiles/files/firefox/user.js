// Privacy
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.donottrackheader.enabled", true);
user_pref("dom.security.https_only_mode", true);

// Disable telemetry
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.usage.uploadEnabled", false);
user_pref("app.shield.optoutstudies.enabled", false);

// Disable Pocket
user_pref("extensions.pocket.enabled", false);

// UI
user_pref("browser.tabs.drawInTitlebar", true);
user_pref("browser.uidensity", 1);
user_pref("browser.compactmode.show", true);
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.toolbars.bookmarks.visibility", "always");

// Performance
user_pref("gfx.webrender.all", true);
user_pref("layers.acceleration.force-enabled", true);

// New tab - blank page
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.startup.homepage", "chrome://browser/content/blanktab.html");
user_pref("browser.startup.page", 3);

// URL bar
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.urlbar.suggest.trending", false);

// Misc
user_pref("browser.tabs.warnOnOpen", false);
user_pref("browser.warnOnQuitShortcut", false);
user_pref("browser.bookmarks.defaultLocation", "toolbar_____");
