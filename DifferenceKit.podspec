Pod::Spec.new do |spec|
  spec.name = 'DifferenceKit'
  spec.version  = '1.1.3'
  spec.author = { 'ra1028' => 'r.fe51028.r@gmail.com' }
  spec.homepage = 'https://github.com/ra1028/DifferenceKit'
  spec.documentation_url = 'https://ra1028.github.io/DifferenceKit'
  spec.summary = 'A fast and flexible O(n) difference algorithm framework for Swift collection.'
  spec.description = <<-DESC
                     A fast and flexible O(n) difference algorithm framework for Swift collection.
                     The algorithm is optimized based on the Paul Heckel's algorithm.
                     DESC
  spec.source = { :git => 'https://github.com/ra1028/DifferenceKit.git', :tag => spec.version.to_s }
  spec.license = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.requires_arc = true
  spec.default_subspecs = 'Core', 'UIKitExtension'
  spec.swift_versions = ['4.2', '5.0']

  spec.ios.deployment_target = '9.0'
  spec.tvos.deployment_target = '9.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'

  spec.subspec 'Core' do |subspec|
    subspec.source_files = 'Sources/*.swift'
  end

  spec.subspec 'UIKitExtension' do |subspec|
    subspec.dependency 'DifferenceKit/Core'

    source_files = 'Sources/Extensions/UIKitExtension.swift'
    frameworks = 'UIKit'

    subspec.ios.source_files = source_files
    subspec.tvos.source_files = source_files

    subspec.ios.frameworks = frameworks
    subspec.tvos.frameworks = frameworks
  end

  spec.subspec 'AppKitExtension' do |subspec|
    subspec.dependency 'DifferenceKit/Core'

    subspec.osx.source_files = 'Sources/Extensions/AppKitExtension.swift'
    subspec.osx.frameworks = 'AppKit'
  end
end
