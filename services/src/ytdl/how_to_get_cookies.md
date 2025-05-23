# Cookies

Cookies are used to appear authenticated towards some websites. This is the only way at the moment to access logged in parts of youtube, as using the `--username` and `--password` to log in is broken.

To export your browser's cookies, you can use an addon, though there have been issues with some in the past (google removing from chrome store, addon being taken over by someone else, etc), to avoid this completely, scroll down to the end of this article for instructions on how to use yt-dlp's `--cookies-from-browser` to get a cookies.txt export.

- Chrome: [get cookies.txt LOCALLY](https://chrome.google.com/webstore/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc)
- Firefox: [cookies.txt](https://addons.mozilla.org/en-US/firefox/addon/cookies-txt/)  
    
- Opera: [edit this cookie](https://addons.opera.com/en/extensions/details/edit-this-cookie)

**NOTE**: We cannot guarantee that these extensions aren't stealing your cookies. If that is a concern, see below for instructions on using yt-dlp to export cookies.

Some addons allow you to export only cookies from "this site" (the tab you're currently on when clicking the addon), due to how some login cookies are stored on other domains, we recommend exporting all cookies.

Some addons may require you to configure it to export the cookies in a valid format, `Netscape HTTP Cookie File`, not json or other.

To use the cookies, you give either a full path to the exported cookie file, or just the filename, if it's saved in the folder you run yt-dlp from.

Example of downloading your `watch later` playlist:

```
yt-dlp --cookies cookies.txt "https://www.youtube.com/playlist?list=WL"
```

You can also read the cookies directly from the browser's storage, `--cookies-from-browser BROWSER[+KEYRING][:PROFILE][::CONTAINER]`

Example:

```
yt-dlp --cookies-from-browser firefox "https://www.youtube.com/playlist?list=WL"
```

This means you don't need to export the cookies or use `--cookies` (if you do use both, it will overwrite the cookie file with the new cookies received from the website). This method does not support session cookies (PHPSESSID), if that is needed, use the export method.

If you have many cookies, the `--cookies-from-browser` method might be slow to use every time. You can get around this by using it to export your cookies:

```
yt-dlp --cookies cookies.txt --cookies-from-browser firefox
```

Now you have a `cookies.txt` and can continue just using `--cookies cookies.txt`.

**NOTE**: Due to a recent change in chrome, you can't have chrome or chromium-based browers running when using `--cookies-from-browser chrome`.

One solution to this is to add a command line argument to the shortcut starting the browser so it starts without locking the cookie database: `--disable-features=LockProfileCookieDatabase`

Another solution is to use a plugin: [yt-dlp-ChromeCookieUnlock](https://github.com/seproDev/yt-dlp-ChromeCookieUnlock)

**NOTE**: Due to another recent change in chrome, it appears using `--cookies-from-browser chrome` will not work at all. Use an alternative browser after logging into the site using that browser. firefox is available for all platforms, but using a browser already intalled may be easier, i.e. safari on Mac. Edge appears to have imported the changes chrome made, so no longer works.
