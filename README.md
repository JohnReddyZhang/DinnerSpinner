# Dinner Spinner

An app that tells you where to eat your next dinner.

This git is only for presentation purpose, because it uses [Yelp Fusion API](https://www.yelp.com/developers/documentation/v3) as data sources. (As part of Info.plist) but is removed when uploading to public.

Language: Swift 4.2 with Xcode 10.1

Patterns practiced: Delegate, Singleton.

References are listed in the project as comments starting with "REF".

Might change to some other implementation to prevent overuse.)



# Notes:

- The initial network call is done in the splash screen. If it fails, there is a repeated alert until the network is back online.

- The app requests location service and network service. When there are errors related to a lack of these, we alert users.

- App layout is iPhone only, Portrait Orientation only. It fits to most iPhone screens with Auto Layout set.

- Detail view uses MapKit to implement a map window, which has the location of the restaurant marked out. Pressing the info button on right side of the tag will take user to thier Mapping app, proposing a routing from user location to the restaurant (searched by restaurant name). 

  


# Where to go from here:

- If there were more time, would Use Card View (like in Apple Music). As more apps are using it.
  (DimmerLayer is left in project and not used on purpose to show this direction)

- More UI component polishing

- Better error handling

  

