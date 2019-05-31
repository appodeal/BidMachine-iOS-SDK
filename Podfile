platform :ios, '9.0'
workspace 'BidMachine.xcworkspace'

# Declarations:

# Use Appodeal CocoaPods repo for adapters dependencies
source 'https://github.com/appodeal/CocoaPods.git'
# Use official CocoaPods repo for test dependecies
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

# plugin 'cocoapods-mangle', targets: [ 'BidMachine', 'DisplayKit', 'BDMVASTAdapter', 'BDMMRAIDAdapter' ],
#                            mangle_prefix: 'BDM_'

def mraid
    pod 'NexageSourceKitMRAID', '~>1.3', :inhibit_warnings => true
end

def protobuf
    pod 'Protobuf', '~> 3.6'
end

def nast
    pod 'MobileAdDisplayManagers/AppodealNASTKit'
end

def toasts
    pod 'Toast-Swift', '~> 4.0.0'
end

def supported_modules
    subspecs = [ "ASKDiskUtils", "ASKViewability", 'ASKLogger', 'ASKExtension', 'ASKProductPresentation', 'ASKSpinner']
    subspecs.each { |network|
        pod "AppodealSupportedModules/#{network}",
        '~> 0.4'
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
    mraid
end

target 'DisplayKit' do
    project 'DisplayKit/DisplayKit.xcodeproj'
    supported_modules
    mraid
end

target 'Sample' do
    project 'Sample/Sample.xcodeproj'
    supported_modules
    mraid
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
#     # Update proto models
#     system("Proto/update_proto.sh")
# end
