// Privacy
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.donottrackheader.enabled", true);

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
user_pref("browser.tabs.drawInTitlebar", false);  // Show title bar
user_pref("browser.uidensity", 1);  // Compact density (0=normal, 1=compact, 2=touch)
user_pref("browser.compactmode.show", true);  // Enable compact mode option
user_pref("browser.theme.toolbar-theme", 0);
user_pref("browser.toolbars.bookmarks.visibility", "always");

// Enable userChrome.css support
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// Hide Firefox View button (recent browsing)
user_pref("browser.tabs.firefox-view", false);
user_pref("browser.tabs.firefox-view-next.enabled", false);
user_pref("browser.tabs.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");
user_pref("browser.firefox-view.feature-tour", "{\"screen\":\"\",\"complete\":true}");
user_pref("browser.firefox-view.view-count", 0);
user_pref("services.sync.engine.tabs", false);
user_pref("identity.fxaccounts.toolbar.enabled", false);

// Performance
user_pref("gfx.webrender.all", true);

// New tab - tubes-cursor via New Tab Override addon
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.newtabpage.enabled", true);
user_pref("browser.startup.homepage", "https://mggpie.github.io/tubes-cursor/");
user_pref("browser.startup.page", 3);

// URL bar
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.urlbar.suggest.trending", false);

// Misc
user_pref("browser.tabs.warnOnOpen", false);
user_pref("browser.warnOnQuitShortcut", false);
user_pref("browser.bookmarks.defaultLocation", "toolbar_____");

// Mouse
user_pref("general.autoScroll", true);
user_pref("ui.context_menus.after_mouseup", true);  // Show context menu on mouseup (needed for mouse gestures)

// Disable Picture-in-Picture
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);

// Extensions - allow sideloaded but keep user control
user_pref("extensions.autoDisableScopes", 14);
user_pref("extensions.enabledScopes", 15);
user_pref("xpinstall.signatures.required", false);
