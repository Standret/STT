
Pod::Spec.new do |s|

  s.name         = "STT"
  s.version      = "3.0.0"
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
  s.source_files = "STT/Core/*.swift"
  
  # STT Extensions
  s.subspec 'Extensions' do |sp|
    sp.source_files  = "STT/Extensions/*.swift", "STT/Messenger/*.swift"
  end

  # STT RxExtensions
    s.subspec 'RxExtensions' do |sp|
    sp.source_files  = "STT/Core/*.swift", "STT/RxExtensions/*.swift"
  end

  # STT Messenger
  s.subspec 'Messenger' do |sp|
    sp.source_files = "STT/Messenger/*.swift"
  end

  # STT AlamofireExtensions
  s.subspec 'AlamofireExtensions' do |sp|
    sp.source_files = "STT/Messenger/*.swift", "STT/AlamofireExtensions/*.swift"
    sp.dependency "Alamofire", "4.9.0"
    sp.dependency "RxSwift", "~> 5"
  end
  
  # STT SDWebImageExtensions
  s.subspec 'SDWebImageExtensions' do |sp|
    sp.source_files = "STT/SDWebImageExtensions/*.swift"
    sp.dependency "SDWebImage", "~> 5.0.0"
  end
  
  # STT Bindings
  s.subspec 'Bindings' do |sp|
      sp.source_files = "STT/Bindings/*.swift"
      sp.dependency "RxCocoa", "~> 5"
  end
  
  # STT Bindings
  s.subspec 'NotificationBanner' do |sp|
      sp.source_files = "STT/NotificationBanner/*.swift"
  end
end
