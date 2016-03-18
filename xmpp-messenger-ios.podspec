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
  s.version          = "1.0.1"
  s.summary          = "A Swift Wrapper Arround XMPP to build chat clients"
  s.description      = <<-DESC
                       xmpp-messenger-ios is a Swift XMPP Wrapper to quickly build xmpp chat clients.
						It include third party package like JSQMessageViewController to provide UI and sound for the messaging, while the XMPPFramework handle communication
                       DESC
  s.homepage         = "https://github.com/processone/xmpp-messenger-ios"
  s.license          = 'MIT'
  s.author           = { "ProcessOne" => "pmglemaire@gmail.com" }
  s.source           = { :git => "https://github.com/processone/xmpp-messenger-ios.git"}

s.platform = :ios, '8.0'
s.ios.deployment_target = '8.0'
s.requires_arc = true

s.dependency 'FMDB'
s.dependency 'JSQMessagesViewController'
s.dependency 'JSQSystemSoundPlayer', '~> 2.0'
s.dependency 'XMPPFramework'

s.ios.frameworks = 'Foundation', 'CoreData', 'UIKit', 'CFNetwork', 'Security', 'XMPPFramework'
s.source_files = ['Pod/Classes/**/*.{swift}']
s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2 $(PODS_ROOT)/XMPPFramework/module', 'ENABLE_BITCODE' => 'NO'}

end
