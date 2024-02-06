# StreamDeck Kit

<p align="center">
    <a href="https://github.com/elgatosf/streamdeck-kit-ipad/actions/workflows/run-tests.yml" alt="Run tests">
        <img src="https://github.com/elgatosf/streamdeck-kit-ipad/actions/workflows/run-tests.yml/badge.svg" /></a>
</p>

## Installation

### SPM 

1. Click on your Xcode project file
1. Select the target from the sidebar
1. Navigate to Build Phases in the top bar
1. In the Link Binary With Libraries phase, add StreamDeckSDK from the SPM dependency
1. You may also need to add the library to the Dependencies phase

Add IOKit library.

### CocoaPods

Example Podfile

```Ruby
platform :ios, '17.0'

target 'PodIntegrationExp' do
    use_frameworks!
    pod 'StreamDeckKit'
    pod 'StreamDeckSimulator', :configurations => ['Debug']
end  
```
