platform :ios, '9.0'
use_frameworks!

def all_pods
  pod 'UICircularProgressRing'
end

target 'GradePoint' do
  all_pods
  pod 'Crashlytics'
  pod 'Fabric'
  pod 'Google-Mobile-Ads-SDK'
end

target 'GradePointWidget' do
 all_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|

    puts target.name

    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'

    end
  end
end
