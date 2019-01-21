
Pod::Spec.new do |s|

  s.name         = "LWWebView"
  s.version      = "0.0.5"
  s.summary      = "封装的webview."
 
  s.description  = '一款基于WKWebView和WebViewJavascriptBridge封装的网页'

  s.homepage     = "https://github.com/weilLove/LWWebView"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "weilLove" => "weil218@163.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/weilLove/LWWebView.git", :tag => "#{s.version}" }

  s.source_files  = "Classess", "Classess/*.{h,m}"

  s.frameworks = "UIKit", "Foundation"

  s.dependency 'WebViewJavascriptBridge'

end
