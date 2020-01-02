
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
    sp.source_files  = "STT/Extensions/*.swift"
  end

  # STT RxExtensions
    s.subspec 'RxExtensions' do |sp|
    sp.source_files  = "STT/Core/*.swift", "STT/RxExtensions/*.swift"
  end

  # STT AlamofireExtensions
  s.subspec 'AlamofireExtensions' do |sp|
    sp.source_files = "STT/Core/*.swift", "STT/AlamofireExtensions/*.swift"
    sp.dependency "Alamofire", "~> 5.0.0-rc.3"
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
  
  # STT NotificationBanner
  s.subspec 'NotificationBanner' do |sp|
      sp.source_files = "STT/NotificationBanner/*.swift"
  end
  
  # STT Validator
  s.subspec 'Validator' do |sp|
      sp.source_files = "STT/Core/*.swift", "STT/Validator/*.swift"
  end
  
  # STT UIElements
  s.subspec 'UIElements' do |sp|
      sp.source_files = "STT/UIElements/*.swift"
  end
  
  # STT Support2x
  s.subspec 'Support2x' do |sp|
      sp.source_files = "STT/Support2x/Bindings/*.swift", "STT/Support2x/Components/*.swift", "STT/Support2x/Components/Core/*.swift", "STT/Support2x/Components/View/*.swift"
      sp.dependency "TinyConstraints"
      sp.dependency "KeychainSwift"
  end
end
