platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def all_pods
  pod 'Realm',      :git => 'https://github.com/realm/realm-cocoa.git', 
                    :branch => 'master', 
                    :submodules => true
  pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', 
                    :branch => 'master', 
                    :submodules => true
  pod 'UICircularProgressRing'
  pod 'UIEmptyState'
  pod 'LPSnackbar'
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

post_install do |installer|
  installer.pods_project.targets.each do |target|
    
    puts target.name

    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'

    end
  end
end
