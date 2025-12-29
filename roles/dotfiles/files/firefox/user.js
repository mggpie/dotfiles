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

// Disable Pocket
user_pref("extensions.pocket.enabled", false);

// UI
user_pref("browser.tabs.drawInTitlebar", true);
user_pref("browser.uidensity", 1);
user_pref("browser.compactmode.show", true);

// Performance
user_pref("gfx.webrender.all", true);
user_pref("layers.acceleration.force-enabled", true);

// New tab
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
