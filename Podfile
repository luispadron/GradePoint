platform :ios, '9.0'

target 'GradePoint' do
  use_frameworks!
  # this will disable all the warnings for all pods
  inhibit_all_warnings!

  # Pods for GradePoint
  pod 'RealmSwift'
  pod 'UICircularProgressRing'
  pod 'UIEmptyState'
end

target 'GradePointTests' do 
  use_frameworks!
  # this will disable all the warnings for all pods
  inhibit_all_warnings!

  # Pods for tests
  
  # Realm
  pod 'RealmSwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = ‘4.0’
    end
  end
end
