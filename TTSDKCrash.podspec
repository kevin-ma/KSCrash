Pod::Spec.new do |s|
  IOS_DEPLOYMENT_TARGET = '12.0' unless defined? IOS_DEPLOYMENT_TARGET
  s.name         = "TTSDKCrash"
  s.version      = "2.0.0-rc.4"
  s.summary      = "The Ultimate iOS Crash Reporter"
  s.homepage     = "https://github.com/kstenerud/TTSDKCrash"
  s.license      = { :type => 'TTSDKCrash license agreement', :file => 'LICENSE' }
  s.author       = { "Karl Stenerud" => "kstenerud@gmail.com" }
  s.ios.deployment_target = IOS_DEPLOYMENT_TARGET
  s.source       = { :git => "https://github.com/kstenerud/TTSDKCrash.git", :tag=>s.version.to_s }
  s.frameworks   = 'Foundation'
  s.libraries    = 'c++', 'z'
  s.xcconfig     = { 'GCC_ENABLE_CPP_EXCEPTIONS' => 'YES' }
  s.default_subspecs = 'Installations'

  configure_subspec = lambda do |subs|
    module_name = subs.name.gsub('/', '')
    subs.source_files = "Sources/#{module_name}/**/*.{h,m,mm,c,cpp,def}"
    subs.public_header_files = "Sources/#{module_name}/include/*.h"
    subs.resource_bundles = { module_name => "Sources/#{module_name}/Resources/PrivacyInfo.xcprivacy" }
  end

  s.subspec 'Recording' do |recording|
    recording.dependency 'TTSDKCrash/RecordingCore'

    configure_subspec.call(recording)
  end

  s.subspec 'Filters' do |filters|
    filters.dependency 'TTSDKCrash/Recording'
    filters.dependency 'TTSDKCrash/RecordingCore'
    filters.dependency 'TTSDKCrash/ReportingCore'

    configure_subspec.call(filters)
  end

  s.subspec 'Sinks' do |sinks|
    sinks.dependency 'TTSDKCrash/Recording'
    sinks.dependency 'TTSDKCrash/Filters'
    sinks.ios.frameworks = 'MessageUI'

    configure_subspec.call(sinks)
  end

  s.subspec 'Installations' do |installations|
    installations.dependency 'TTSDKCrash/Filters'
    installations.dependency 'TTSDKCrash/Sinks'
    installations.dependency 'TTSDKCrash/Recording'
    installations.dependency 'TTSDKCrash/DemangleFilter'

    configure_subspec.call(installations)
  end

  s.subspec 'RecordingCore' do |recording_core|
    recording_core.dependency 'TTSDKCrash/Core'

    configure_subspec.call(recording_core)
  end

  s.subspec 'BootTimeMonitor' do |boot_time_monitor|
    boot_time_monitor.dependency 'TTSDKCrash/RecordingCore'

    configure_subspec.call(boot_time_monitor)
  end

  s.subspec 'DiscSpaceMonitor' do |disc_space_monitor|
    disc_space_monitor.dependency 'TTSDKCrash/RecordingCore'

    configure_subspec.call(disc_space_monitor)
  end

  s.subspec 'DemangleFilter' do |demangle_filter|
    demangle_filter.dependency 'TTSDKCrash/Recording'

    configure_subspec.call(demangle_filter)
  end

  s.subspec 'ReportingCore' do |reporting_core|
    reporting_core.dependency 'TTSDKCrash/Core'
    reporting_core.ios.frameworks = 'SystemConfiguration'
    reporting_core.tvos.frameworks = 'SystemConfiguration'
    reporting_core.osx.frameworks = 'SystemConfiguration'

    configure_subspec.call(reporting_core)
  end

  s.subspec 'Core' do |core|
    configure_subspec.call(core)
  end
end