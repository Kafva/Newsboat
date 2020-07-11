# Newsboat
iOS app inspired by [newsboat](https://github.com/newsboat/newsboat) built specifically for organizing YouTube subscriptions.

### Managing channels
You cannot add or remove channels inside the app. To manage what channels are included run the `createDatabase.bash` script on a newsboat URL configuration file with lines akin to the one below for each channel.

```
    # Potential tags after the RSS link are ignored
    https://www.youtube.com/feeds/videos.xml?channel_id=UCXU7XVK_2Wd6tAHYO8g9vAA  "~Preston Jacobs"
```

This will create a SQLite database named `rss.db` which can be uploaded to the app once it has been installed using `./devctl upload`. Deploying the app will go through these steps automatically.

### Deploying the app
To deploy the app connect the destination iOS device via USB and run `./devctl deploy`. The script uses [ilibmobiledevice](https://github.com/libimobiledevice/libimobiledevice) and [ios-deploy](https://github.com/ios-control/ios-deploy) and assumes a macOS environment with Xcode installed.
