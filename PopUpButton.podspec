Pod::Spec.new do |s|
  s.name             = 'PopUpButton'
  s.version          = '1.0'
  s.summary          = 'A control for selecting an item from a list.'
  s.description      = <<-DESC
"A control for selecting an item from a list. In other words, single motion `NSPopUpButton` for iOS."
                       DESC
  s.homepage         = 'https://github.com/k-o-d-e-n/PopUpButton'
  s.screenshots      = 'https://raw.githubusercontent.com/k-o-d-e-n/PopUpButton/master/Resources/demo.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'k-o-d-e-n' => 'koden.u8800@gmail.com' }
  s.source           = { :git => 'https://github.com/k-o-d-e-n/PopUpButton.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/K_o_D_e_N'
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/PopUpButton/**/*'
end
