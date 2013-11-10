Pod::Spec.new do |s|

  s.name         = "AKSmartThings"
  s.version      = "0.0.2"
  s.summary      = "Cocoa wrapper for the SmartThings REST API"

  s.description  = <<-DESC
                   Cocoa wrapper for the SmartThings REST API

                   * Simple REST calls with JSON responses 
                   * OAuth authentication
                   * Endpoint discovery 
                   DESC

  s.homepage     = "https://github.com/alexking/AKSmartThings"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Alex King" => "alexking@me.com" }
  s.platform     = :osx, '10.9'
  s.source       = { :git => "https://github.com/alexking/AKSmartThings.git" , :tag => '0.0.2' }

  s.source_files = 'Classes', 'Classes/*.{h,m}'

  s.requires_arc = true

  s.dependency 'CocoaHTTPServer', '~> 2.3'

end
