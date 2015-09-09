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
  s.version          = "1.0"
  s.summary          = "A Swift Wrapper Arround XMPP to build chat clients"
  s.description      = <<-DESC
                       xmpp-messenger-ios is a Swift XMPP Wrapper to quickly build xmpp chat clients.
						It include third party package like JSQMessageViewController to provide UI and sound for the messaging, while the XMPPFramework handle communication
                       DESC
  s.homepage         = "https://github.com/processone/xmpp-messenger-ios"
  s.license          = 'MIT'
  s.author           = { "ProcessOne" => "pmglemaire@gmail.com" }
  s.source           = { :git => "https://github.com/processone/xmpp-messenger-ios.git", :tag => s.version }

  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  s.requires_arc = true

  s.ios.frameworks = 'Foundation', 'CoreData', 'UIKit', 'CFNetwork', 'Security'

  s.ios.dependency 'XMPPFramework'
  s.dependency 'FMDB', '~> 1.0'
  s.dependency 'JSQMessagesViewController'
  s.dependency 'JSQSystemSoundPlayer', '~> 2.0'
  s.source_files = 'Pod/Classes/**/*.{swift}'
end