Pod::Spec.new do |s|
  s.name         = "Geometry"
  s.version      = "0.0.1"
  s.license      = "MIT"
  s.homepage     = "https://www.voynovia.ru/"
  s.author       = { "Igor Voynov" => "igyo@me.com" }
  s.summary      = "A collection of functions for geometrical calculation written Swift for iOS and macOS."
  s.description  = <<-DESC
                   This library is a collection of functions that perform geometrical calculations: segment, triangle, curves and others.
                   DESC

  s.source       = { :git => "https://gitlab.com/rcai/geometry.git", :tag => "#{s.version}" }
  s.source_files = "Sources/Geometry/*.swift"

  s.framework    = 'SystemConfiguration'

  s.ios.deployment_target = "9.2"
  s.osx.deployment_target = "10.10"
  s.pod_target_xcconfig   = { 'SWIFT_VERSION' => '4' }
end

