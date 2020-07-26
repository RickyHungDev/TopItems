# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

def shared_pods
  pod 'Alamofire'
  pod 'AlamofireImage', '~> 3.4'
  pod 'PKHUD'
  pod 'SwiftyJSON'
  pod 'RxSwift'
  pod 'RxCocoa'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end

target 'TopItems' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  shared_pods
  # Pods for TopItems

  target 'TopItemsTests' do
    inherit! :search_paths
    # Pods for testing
    
  end

end
