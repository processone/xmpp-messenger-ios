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
  s.version          = "0.1.0"
  s.summary          = "xmpp-messenger-ios is a lightweight XMPP wrapper"
  s.description      = <<-DESC
                       An optional longer description of xmpp-messenger-ios

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/processone/xmpp-messenger-ios"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Paul LEMAIRE" => "pmglemaire@gmail.com" }
  s.source           = { :git => "https://github.com/processone/xmpp-messenger-ios.git », :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/@processOne'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'xmpp-messenger-ios' => ['Pod/Assets/*.png']
  }

  s.dependency 'FMDB’, 'JSQMessagesViewController’, 'JSQSystemSoundPlayer'
end
