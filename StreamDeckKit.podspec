Pod::Spec.new do |s|
    s.name         = 'StreamDeckKit'
    s.version      = '0.0.1'
    s.swift_version = '5.9'

    s.summary      = 'Integrate StreamDeck hardware into your App'
    s.author       = { 'Elgato' => 'info@elgato.com' }
    s.homepage     = 'https://docs.elgato.com/ipad'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.source       = { :git => 'https://github.com/elgatosf/streamdeck-kit-ipad.git', :tag => "#{s.version}" }

    s.requires_arc = true
    s.frameworks = 'UIKit', 'SwiftUI'
    s.source_files = "Sources/#{s.name}/**/*.swift"
    s.dependency 'StreamDeckCApi', "#{s.version.to_s}"

    s.platform     = :ios, '16.0'
    s.ios.deployment_target = '16'
end
