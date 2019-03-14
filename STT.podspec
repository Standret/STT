
Pod::Spec.new do |s|

  s.name         = "STT"
  s.version      = "1.0.2"
  s.summary      = "Test summary. Added Dynamic components for binding"

  s.description  = <<-DESC

This is a Swift project of ready made part of code include a lot of useful function.
This project is inspaired by MvvmCross [MvvmCross](https://github.com/MvvmCross/MvvmCross)
                   DESC

  s.homepage     = "https://github.com/Standret/STT"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  s.author             = { "Peter Standret" => "pstandret@gmail.com" }

  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/Standret/STT.git", :tag => "#{s.version}" }
  s.source_files  = "STT/Bindings/*.swift", "STT/Extensions/*.swift", "STT/Components/*.swift", "STT/Components/Core/*.swift", "STT/Components/View/*.swift"

  s.dependency "RxSwift", "~> 4.0"
  s.dependency "Alamofire", "~> 4.7"
  s.dependency "RxAlamofire"
  s.dependency "TinyConstraints"
  s.dependency "KeychainSwift", "~> 10.0"
end
