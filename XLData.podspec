Pod::Spec.new do |s|
  s.name     = 'XLData'
  s.version  = '2.0.0'
  s.license  = 'MIT'
  s.summary  = 'XLData provides an elegant and concise way to load, synchronize and show data sets into UITableViews and UICollectionViews.'
  s.homepage = 'https://github.com/xmartlabs/XLData'
  s.authors  = { 'Martin Barreto' => 'martin@xmartlabs.com', 'Miguel Revetria' => 'miguel@xmartlabs.com' }
  s.source   = { :git => 'https://github.com/xmartlabs/XLData.git', :tag => 'v2.0.0'}
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.ios.frameworks = 'UIKit', 'Foundation'

  s.subspec 'Core' do |sp|
    sp.source_files = 'XLData/XL/Core/**/*.{h,m}'
  end
  s.subspec 'CoreRemote' do |sp|
    sp.source_files = 'XLData/XL/CoreRemote/**/*.{h,m}'
    sp.dependency 'AFNetworking', '~> 2.0'
  end

  s.subspec 'DataStore' do |sp|
    sp.source_files = 'XLData/XL/Local/DataStore/**/*.{h,m}'
    sp.dependency 'XLData/Core'
  end
  s.subspec 'CoreData' do |sp|
    sp.source_files = 'XLData/XL/Local/CoreData/**/*.{h,m}'
    sp.dependency 'XLData/Core'
    sp.ios.frameworks = 'CoreData'
  end

  s.subspec 'RemoteDataStore' do |sp|
    sp.source_files = 'XLData/XL/Remote/DataStore/**/*.{h,m}'
    sp.dependency 'XLData/CoreRemote'
    sp.dependency 'XLData/DataStore'
  end
  s.subspec 'RemoteCoreData' do |sp|
    sp.source_files = 'XLData/XL/Remote/CoreData/**/*.{h,m}'
    sp.dependency 'XLData/CoreRemote'
    sp.dependency 'XLData/CoreData'
  end
end
