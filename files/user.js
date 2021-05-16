/* User configuration generated by fu */

/* no warning on about:config */
user_pref("browser.aboutConfig.showWarning", false);

/* compact UI */
user_pref("browser.uidensity", 1);

/* Screen tearing issue */
/* https://askubuntu.com/questions/1200143/full-screen-video-tearing-in-firefox-ubuntu-19-10/1288650#1288650 */
user_pref("layers.acceleration.force-enabled", true);
user_pref("layers.force-active", true);
user_pref("mozilla.widget.use-argb-visuals", false);

/* Ignore windows size at startup and let i3 do its job */
user_pref("privacy.resistFingerprinting", true);
