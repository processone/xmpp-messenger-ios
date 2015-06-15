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
  s.version          = "0.1.3"
  s.summary          = "A Swift Wrapper Arround XMPP to build chat clients"
  s.description      = <<-DESC
                       xmpp-messenger-ios is a Swift XMPP Wrapper to quickly build xmpp chat clients
                       DESC
  s.homepage         = "https://github.com/processone/xmpp-messenger-ios"
  s.license          = 'MIT'
  s.author           = { "ProcessOne" => "pmglemaire@gmail.com" }
  s.source           = { :git => "https://github.com/processone/xmpp-messenger-ios.git", :tag => "0.1.3" }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.ios.frameworks = 'Foundation', 'CoreData', 'UIKit', 'CFNetwork', 'Security'

  s.dependency 'XMPPFramework', '~> 3.6.4'
  s.dependency 'FMDB', '~> 1.0'
  s.dependency 'JSQMessagesViewController', '~> 6.1.3'
  s.dependency 'JSQSystemSoundPlayer', '~> 2.0.0'

  s.source_files = 'Pod/Classes/**/*.{swift,h,m}', 'Pod/Umbrella-Header.h'
  s.public_header_files = 'Pod/Umbrella-Header.h'

  s.libraries = 'xml2'
	s.xcconfig = {
  'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2'
	}
end