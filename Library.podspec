Pod::Spec.new do |s|
  s.name         = "Library"
  s.version      = "0.0.2"
  s.summary      = "My personnel project."
  s.homepage     = "https://github.com/ahershailesh/iOS-Library"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Shailesh Aher" => "shaileshaher07@gmail.com" }
  s.source       = { :git => "https://github.com/ahershailesh/iOS-Library.git", :tag => "v#{s.version}"  }
  spec.ios.deployment_target  = '10.0'
  s.source_files  = "**/*.swift"
end
s