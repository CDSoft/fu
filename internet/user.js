/* User configuration generated by fu */

/* no warning on about:config */
user_pref("browser.aboutConfig.showWarning", false);

/* compact UI */
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1);

/* Enable tab groups */
// Not enable (yet?) since the behaviour is strange:
// - new tabs are not open in the same group
// - moving a tab outside its group moves it to the next group
// For a better experience:
// - group tabs in windows (i3 is a nice windows manager)
// - use "Windows Titler" to rename windows (i.e. tab groups) => easy to search with rofi
//user_pref("browser.tabs.groups.enabled", true);

/* Screen tearing issue */
/* https://askubuntu.com/questions/1200143/full-screen-video-tearing-in-firefox-ubuntu-19-10/1288650#1288650 */
user_pref("layers.acceleration.force-enabled", true);
user_pref("layers.force-active", true);
user_pref("mozilla.widget.use-argb-visuals", false);

/* Ignore windows size at startup and let i3 do its job */
//user_pref("privacy.resistFingerprinting", true);  // causes other troubles (wrong timestamps in Slack and Jira)
user_pref("privacy.resistFingerprinting", false);

/* Open Firefox in the current workspace, not in the previous one */
/* https://bugs.kde.org/show_bug.cgi?id=434818 */
/* https://technologytales.com/2021/10/12/stopping-firefox-from-launching-on-the-wrong-virtual-desktop-on-linux-mint/ */
user_pref("widget.disable-workspace-management", true);

/* Hardware acceleration */
/* https://support.mozilla.org/en-US/questions/1232970 */
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);
user_pref("layers.acceleration.force-enabled", true);
user_pref("layers.force-active", true);
//user_pref("gfx.xrender.enabled", true);
