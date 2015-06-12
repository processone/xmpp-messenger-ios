#
# Be sure to run `pod lib lint xmpp-messenger-ios.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "xmpp-messenger-ios"
  s.version          = "0.1.1"
  s.summary          = "Swift XMPP Wrapper to build chat clients"
  s.description      = <<-DESC
                       xmpp-messenger-ios is a Swift XMPP Wrapper to quickly build xmpp chat clients
                       DESC
  s.homepage         = "https://github.com/processone/xmpp-messenger-ios"
  s.license          = 'MIT'
  s.author           = { "ProcessOne" => "pmglemaire@gmail.com" }
  s.source           = { :git => "https://github.com/processone/xmpp-messenger-ios.git", :tag => "0.1.1" }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.prefix_header_contents = 'iphone/include/xmpp-messenger-ios.pch'
  s.ios.frameworks = 'Foundation', 'CoreData', 'UIKit', 'CFNetwork', 'Security'
  s.dependency 'FMDB', '~> 1.0'
  s.dependency 'JSQMessagesViewController', '~> 6.1.3'
  s.dependency 'JSQSystemSoundPlayer', '~> 2.0.0'
  s.dependency 'XMPPFramework'
	s.source_files = 'Pod/Classes/**/*'
	s.libraries = 'xml2'
	s.xcconfig = {
	'SWIFT_OBJC_BRIDGING_HEADER' => '/Users/paul/Documents/iOS Development/OneChat/xmpp-messenger-ios/Example/xmpp-messenger-ios/xmpp-messenger-ios_Example-Bridging-Header.h',
  'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'
	}
end