#
#  Be sure to run `pod spec lint LQDownloadManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "LQDownloadManager"
  s.version      = "0.0.4"
  s.summary      = "iOS download manager, support background mode."
  s.homepage     = "https://github.com/ALVIN-YANG/LQDownloadManager"
  s.license      = "MIT"
  s.author       = { "ALVIN-YANG" => "ylq.win@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ALVIN-YANG/LQDownloadManager.git", :tag => "0.0.4" }
  s.framework  = "UIKit"
  s.source_files  = "LQDownloadManager/*"


end
