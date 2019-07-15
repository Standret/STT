
Pod::Spec.new do |s|

  s.name         = "STT"
  s.version      = "2.2.3"
  s.summary      = "Simple reusable code with RxViper architecture provided by Standret, LightSide and Adnrew"

  s.description  = <<-DESC

This is a Swift project of ready made part of code include a lot of useful function.
This project is inspaired by MvvmCross [MvvmCross](https://github.com/MvvmCross/MvvmCross)
                   DESC

  s.homepage     = "https://github.com/Standret/STT"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  s.author       = { "Peter Standret" => "pstandret@gmail.com" }

  s.platform     = :ios, "11.0"
  s.swift_version = "5.0"

  s.source       = { :git => "https://github.com/Standret/STT.git", :tag => "#{s.version}" }
  s.source_files = "STT/Bindings/*.swift", "STT/Extensions/*.swift", "STT/Components/*.swift", "STT/Components/Core/*.swift", "STT/Components/View/*.swift"

  s.dependency "RxSwift", "~> 5"
  s.dependency "Alamofire", "~> 4.8.2"
  s.dependency "RxAlamofire"
  s.dependency "TinyConstraints"
  s.dependency "KeychainSwift", "~> 16.0"
end
