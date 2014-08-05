Pod::Spec.new do |s|

  s.name         = "JGProgressView"
  s.version      = "1.2.1"
  s.summary      = "UIProgressView subclass with an animated 'Indeterminate' setting."
  s.description  = <<-DESC
UIProgressView subclass with an animated "Indeterminate" setting.
DESC
  s.homepage     = "https://github.com/JonasGessner/JGProgressView"
  s.license      = { :type => "MIT", :file => "LICENSE.txt" }
  s.author             = "Jonas Gessner"
  s.social_media_url   = "http://twitter.com/JonasGessner"
  s.platform     = :ios, "5.0"
  s.source       = { :git => "https://github.com/JonasGessner/JGProgressView.git", :tag => "v1.2.1" }
  s.source_files  = "JGProgressView/*.{h,m}"
  s.resources = "JGProgressView/*.png"
  s.frameworks = "Foundation", "UIKit", "QuartzCore"
  s.requires_arc = true

end
