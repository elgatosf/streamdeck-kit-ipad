Pod::Spec.new do |s|
    s.name         = 'StreamDeckSimulator'
    s.version      = '0.0.1'
    s.swift_version = '5.9'

    s.summary      = 'Simulate different StreamDeck devices to test your StreamDeckKit integration.'
    s.author       = { 'Elgato' => 'info@elgato.com' }
    s.homepage     = 'https://docs.elgato.com/ipad'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.source       = { :git => 'https://github.com/elgatosf/streamdeck-kit-ipad.git', :tag => "#{s.version}" }

    s.requires_arc = true
    s.source_files = "Sources/#{s.name}/**/*.swift"
    s.dependency 'StreamDeckKit', "#{s.version.to_s}"

    # To be compatible with SPM integration, we give the resource bundle the same name as SPM would do.
    # See: https://medium.com/clutter-engineering/supporting-both-swift-package-manager-and-cocoapods-in-your-library-861f00b6b0f9#8694
    s.resource_bundles = { "StreamDeckKit_#{s.name}" => ["Sources/#{s.name}/Resources/**/*"] }

    s.platform     = :ios, '16.0'
    s.ios.deployment_target = '16'
end
