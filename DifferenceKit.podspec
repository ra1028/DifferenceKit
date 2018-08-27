Pod::Spec.new do |spec|
  spec.name = 'DifferenceKit'
  spec.version  = '0.5.2'
  spec.author = { 'ra1028' => 'r.fe51028.r@gmail.com' }
  spec.homepage = 'https://github.com/ra1028/DifferenceKit'
  spec.documentation_url = 'https://ra1028.github.io/DifferenceKit'
  spec.summary = 'A fast and flexible O(n) difference algorithm framework for Swift collection.'
  spec.description = <<-DESC
                     A fast and flexible O(n) difference algorithm framework for Swift collection.
                     The algorithm is optimized based on the Paul Heckel's algorithm.
                     DESC
  spec.source = { :git => 'https://github.com/ra1028/DifferenceKit.git', :tag => spec.version.to_s }
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.requires_arc = true
  spec.default_subspecs = 'Core', 'UIExtensions'

  spec.ios.deployment_target = '9.0'
  spec.tvos.deployment_target = '9.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'

  spec.subspec 'Core' do |subspec|
    subspec.source_files = 'Sources/*.swift'
  end

  spec.subspec 'UIExtensions' do |subspec|
    subspec.dependency 'DifferenceKit/Core'

    source_files = 'Sources/UIExtensions/*.swift'
    frameworks = 'UIKit'

    subspec.ios.source_files = source_files
    subspec.tvos.source_files = source_files

    subspec.ios.frameworks = frameworks
    subspec.tvos.frameworks = frameworks
  end
end
