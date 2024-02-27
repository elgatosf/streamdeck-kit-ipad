Pod::Spec.new do |s|
    s.name         = 'StreamDeckCApi'
    s.version      = '0.0.1'
    s.swift_version = '5'

    s.summary      = 'C header for StreamDeckKit. Not for standalone use.'
    s.author       = { 'Elgato' => 'info@elgato.com' }
    s.homepage     = 'https://docs.elgato.com/ipad'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.source       = { :git => 'https://github.com/elgatosf/streamdeck-kit-ipad.git', :tag => "#{s.version}" }

    s.requires_arc = true
    s.frameworks = 'IOKit'
    s.source_files = "Sources/#{s.name}/**/*.{c,h}"
    s.public_header_files = "Sources/#{s.name}/**/*.h"

    # See: https://github.com/CocoaPods/CocoaPods/issues/12073#issuecomment-1737821281
    s.xcconfig = { 'ENABLE_USER_SCRIPT_SANDBOXING' => false }

    s.platform     = :ios, '16.0'
    s.ios.deployment_target = '16'
end
