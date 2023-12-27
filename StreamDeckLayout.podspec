Pod::Spec.new do |s|
    s.name         = 'StreamDeckLayout'
    s.version      = '0.0.1'
    s.swift_version = '5'

    s.summary      = 'SwiftUI layout entities for use in StreamDeck UI and simulator.'
    s.author       = { 'Elgato' => 'info@elgato.com' }
    s.homepage     = 'https://github.com/elgatosf/streamdeck-ios'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.source       = { :git => 'https://github.com/elgatosf/streamdeck-ios.git', :tag => "#{s.version}" }

    s.requires_arc = true
    s.source_files = "Sources/#{s.name}/**/*.swift"
    s.dependency 'StreamDeckKit', "#{s.version.to_s}"

    s.platform     = :ios, '17.0'
    s.ios.deployment_target = '17'
end
