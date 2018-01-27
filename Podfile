platform :ios, '9.0'
use_frameworks!

def all_pods
  pod 'UICircularProgressRing'
  pod 'Google-Mobile-Ads-SDK'
end

target 'GradePoint' do
  all_pods
end

target 'GradePointTests' do
  all_pods
end

target 'GradePointUITests' do
  all_pods
end

target 'GradePointWidget' do
  pod 'UICircularProgressRing'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|

    puts target.name

    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'

    end
  end
end
