# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TimeStream' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TimeStream
  pod 'IQKeyboardManagerSwift'
  pod 'Alamofire'
  pod 'KeychainAccess'
  pod 'FlagKit'
  pod 'NVActivityIndicatorView'
  pod 'CameraKit-iOS', :git => 'https://github.com/appssemble/camerakit-ios.git', :commit => 'a3a68430d345156287e18d27dc34f9e785dc7db2'
  pod 'SwiftDate'
  pod 'Kingfisher', '~> 5.0'
  
#  pod 'Firebase'
  pod 'FirebaseCore', '~> 9.0'
  pod 'FirebaseAuth', '~> 9.1.0'
  pod 'Firebase/Analytics'
#  pod 'Firebase/Auth'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'Firebase/Crashlytics'
  
  pod 'Koloda'
  pod 'EggRating'
  pod 'Stripe'
  pod 'UITextView+Placeholder'
  pod 'ALProgressView'
  pod 'KafkaRefresh'
  
  pod 'Adyen'
  
  target 'TimeStreamTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TimeStreamUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.generated_projects.each do |project|
      project.targets.each do |target|
          target.build_configurations.each do |config|
              config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
          end
      end
  end
end