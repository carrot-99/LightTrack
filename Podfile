platform :ios, '16.0'

target 'LightTrack' do
  use_frameworks!

  pod 'Google-Mobile-Ads-SDK'
end

# 依存ライブラリの古いデプロイメントターゲット（iOS 9〜11）は最新の Xcode でビルドできないため揃える
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
