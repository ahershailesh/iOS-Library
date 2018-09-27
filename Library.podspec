Pod::Spec.new do |s|
  s.name         = "Library"
  s.version      = "0.0.1"
  s.summary      = "My personnel project."
  s.homepage     = "https://github.com/ahershailesh/iOS-Library"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Shailesh Aher" => "shaileshaher07@gmail.com" }
  s.source       = { :git => "https://github.com/ahershailesh/iOS-Library.git", :tag => "v0.0.1" }
  s.source_files  = ".", "../*.swift"
  s.exclude_files = "Classes/Exclude"
end
