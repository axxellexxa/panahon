# panahon
MO panahon mobile app.

# Table of Contents

- [Libraries](#Libraries)
- [Files](#Files)
	- [main.dart](###main.dart)
	- [QuickViewScreen.dart](##QuickViewScreen.dart)
		- [WeatherAPI.dart](###WeatherAPI.dart)
		- [WeatherDataSection.dart](###WeatherDataSection.dart)
		- [CustomAttribution.dart](###CustomAttribution.dart)
		- [CustomAttributionAnimation.dart](###CustomAttributionAnimation.dart)
	- [ModelsScreen.dart](#ModelsScreen.dart)
	- [ClimateScreen.dart](#ClimateScreen.dart)
	- [ReportsScreen.dart](#ReportsScreen.dart)
	- [SplashScreen.dart](#SplashScreen.dart)
- [Issues and Suggestions](#Issues%20and%20Suggestions)

# Libraries
- [`flutter_map`](https://pub.dev/packages/flutter_map)
	- provides the `FlutterMap` widget and its various layers
- [`flutter_map_animations`](https://pub.dev/packages/flutter_map_animations)
	- provides animations for the `FlutterMap` widget
- [`latlong2`](https://pub.dev/packages/latlong2)
	- provides the `LatLng` class, which defines coordinates
- [`intl`](https://pub.dev/packages/intl)
	- provides timezone localization
- [`convert`](https://pub.dev/packages/convert)
	- provides the `jsonDecode` function to be able to parse the API data
- [`math`](https://pub.dev/packages/math)
	- provides math
- [`collection`](https://pub.dev/packages/collection)
	- provides the `firstWhereOrNull` method for `List`s
- [`url_launcher`](https://pub.dev/packages/url_launcher)
	- provides redirects to websites

# Files
### main.dart
This file contains the base structure and navigation for the app.

**Important Widgets**
- `NavigationBar`
	- Allows the user to switch between different screens

## QuickViewScreen.dart
This file contains the Quick View screen, which shows the current available stations on a `FlutterMap`. Each station is selectable through either the `DropdownMenu`, or through tapping on of the `CircleMarkers` on the map.

**Important Widgets**
- `FlutterMap`
	- `TileLayer` uses [OpenStreetMap](https://operations.osmfoundation.org/policies/tiles/) tiles
	- Detects taps with `GestureDetector` child
	- `CircleLayer` contains the map markers
		- The `ValueListenableBuilder` parent of the `FlutterMap` allows it to change to different sets of map markers
	- `CustomAttributionWidget` contains the copyright information and disclaimer

### WeatherAPI.dart
This file defines the `WeatherAPI` class, which is used to fetch and process the necessary data to be used for the app

**Methods**
- `initializeData`
	- This is an asynchronous function that fetches data and stores it in the `WeatherAPI`'s `data` list
- `getData`
	- This function returns a `Map` with the necessary information for the selected `location`
	- `nullHelper` is a helper function that ensures the data inputted into the `Map` is valid, and rounded to the specified amount of `digits`
- `getDropdownLocations`
	- This function returns two `List`s: one containing `DropdownMenuEntries`, and the other containing a `LatLng` for each of those entries
- `getMapLocations`
	- This function returns four `List`s of map markers, one for each data type.
	- `colorHelper` is a helper function that calculates the color of a map marker according to its data and a provided gradient. It can also handle null or out-of-bounds values for the data `value`
- `calcHeatIndex`
	- This function calculates the heat index ([source](https://github.com/mcci-catena/heat-index/blob/master/heat-index.js))
- `calcWindDirection`
	- This function returns a compass direction given the `wdir` (wind direction) in degrees

### WeatherDataSection.dart
This file defines the `WeatherDataSection` widget, which is displayed on top of the `FlutterMap` on the Quick View Screen.

**Important Widgets**
- `leftSection`
	- contains the date and time when the data was last updated
- `middleSection`
	- contains the primary observation data
- `rightSection`
	- contains secondary information (or nothing in the case of pressure)
- `SegmentedButton`
	- These buttons allow the user to switch between the following data: rain, temperature, wind, and pressure

### CustomAttribution.dart
This file was created due to the limitations of the built-in `RichAttributionWidget` in the `flutter_maps` package.

**Changes**
- added `topRight` and `topLeft` alignments

### CustomAttributionAnimation.dart
This file was created due to the limitations of the built-in `RichAttributionWidget` in the `flutter_maps` package.

# Issues and Suggestions

| Issue                                                                                                                                             | Suggestion                                                                                            |
| ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `CustomAttributionWidget` opens every time the user switches to the Quick View Screen.                                                            | Add a boolean key to `SharedPreferences` to signify if the screen has been opened for the first time. |
| Default selected station is "Manila Observatory"                                                                                                  | Default to closest station to user                                                                    |
| Extreme values (like >999mm of rain) overflow on the right section of `WeatherDataSection`                                                        |                                                                                                       |
| No color theming                                                                                                                                  | Create color theme                                                                                    |
| `CustomAttributionWidget` and `CustomAttributionWidgetAnimation` could probably be extensions of their respective `RichAttribution` counter parts | Refactor these files to use `extends`                                                                 |
