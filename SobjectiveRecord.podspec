@version = "0.3.0"

Pod::Spec.new do |s|
  s.name         = "SobjectiveRecord"
  s.version      = @version
  s.summary      = "Lightweight and sexy CoreData Library for background `NSManagedObjectContext` written in Swift"
  s.homepage     = "https://github.com/hmhv/SobjectiveRecord"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "hmhv" => "admin@hmhv.info" }
  s.source       = { :git => "https://github.com/hmhv/SobjectiveRecord.git", :tag => @version }

  s.source_files = 'SobjectiveRecord/**/*.swift'
  s.framework  = 'CoreData'
  s.requires_arc = true

  s.ios.deployment_target = '8.0'

end
