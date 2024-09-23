
# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - 2024-09-23

Removes the need for a macro.

You can now declare your Stream Deck layouts as regular Swift UI views. There is no need to implement `StreamDeckView` anymore.

### Removed

- The dependency on [Stream Deck Kit - Macros](https://github.com/elgatosf/streamdeck-kit-macros)
- The `StreamDeckView` protocol

## [1.0.0] - 2024-08-22

This is the first official release. 🎉

### Added
- __SDK - Error Handling:__ Auto-remove erroneous devices.

### Changed
- __Example App - Stream Deck Connect App Detection:__ The example app now contains a  check for the Stream Deck Connect app

 
## [0.0.2-alpha] - 2024-04-18
 
This release adds support for the newest member in the Stream Deck family: Stream Deck Neo. 

Make sure that you also update Stream Deck Connect which adds device support for Neo in the driver. 
 
### Added
- Simulator for Neo

### Changed
- Example App now includes examples for Stream Deck Neo's new info panel and touch keys 
- Updated Readme and documentation
 
## [0.0.1-alpha] - 2024-03-04
  
Initial alpha release.
