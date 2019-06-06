platform :ios, '9.0'
workspace 'BidMachine.xcworkspace'

# Use Appodeal CocoaPods repo for adapters dependencies
source 'https://github.com/appodeal/CocoaPods.git'
# Use official CocoaPods repo for test dependecies
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

# cocoapods-mangle is used for mangle Protobuf
# plugin 'cocoapods-mangle', targets: [ 'BidMachine', 'BDMVASTAdapter', 'BDMMRAIDAdapter' ],
# mangle_prefix: 'BDM_'

def protobuf
  pod 'Protobuf', '~> 3.6'
end

def nast
  pod 'MobileAdDisplayManagers/AppodealNASTKit', '~> 0.4.0'
end

def mraid
  pod 'MobileAdDisplayManagers/AppodealMRAIDKit', '~> 0.4.0'
end

def vast 
  pod 'MobileAdDisplayManagers/AppodealVASTKit', '~> 0.4.0'
end

def toasts
  pod 'Toast-Swift', '~> 4.0.0'
end

def supported_modules
  subspecs = [ 'ASKDiskUtils', 'ASKViewability', 'ASKLogger', 'ASKExtension', 'ASKProductPresentation', 'ASKSpinner']
  subspecs.each { |network|
    pod "AppodealSupportedModules/#{network}", '~> 0.5.0'
  }
end


# Targets configuration
target 'BidMachine' do
  project 'BidMachine/BidMachine.xcodeproj'
  protobuf
  supported_modules
end

target 'BDMMRAIDAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  supported_modules
  mraid
end

target 'BDMNASTAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  supported_modules
  nast
end

target 'BDMVASTAdapter' do
  project 'Adaptors/Adaptors.xcodeproj'
  supported_modules
  vast
end

target 'Sample' do
  project 'Sample/Sample.xcodeproj'
  supported_modules
  mraid
  vast
  nast
  supported_modules
  protobuf
  toasts
end

target 'BidMachineTests' do
  project 'BidMachine/BidMachine.xcodeproj'
  pod "Kiwi"
  supported_modules
end

# Post install hook
# post_install do |installer|
#   # Update proto models
#   system("Proto/update_proto.sh")
# end
