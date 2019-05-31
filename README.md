BidMachine for iOS
======================================

Please read [documentation](https://wiki.appodeal.com/display/BID/BidMachine+iOS+SDK+Documentation)

## Release algorithm

1. Check that you has next CLI on your local machine:
* [CoocoaPods](https://guides.cocoapods.org/using/getting-started.html)
* [Fastlane](https://docs.fastlane.tools) 
* [Mangle](https://github.com/intercom/cocoapods-mangle)
* [Amazon CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html)
* XCode 

2. Merge everything you want to master (or some release branch)

3. Send to TestFlight:
  * Manualy (prefered)
  * Fastlane - lane **qa** (not prefered) 

4. Create tag with correct description 
```shell
  ~:git tag -a vX.Y.Z -m "Add some cool feature"
  ~:git push origin vX.Y.Z
```
`NOTE!` If you build release from branch different to master, please set *-Beta* suffix to tag version: vX.Y.Z-Beta

5. Run build.sh from root project directory
`NOTE` Program options:
```shell
[options] application [arguments]

options:
-h, --help                                       show brief help
-v, --version                                    specify version of build. Required
-pu, --pod_update=YES                            update CocoaPods Environment. Optional
-s3, --s3_upload=YES                             upload results to Amazon s3. Optional
-z, --zip=YES                                    compress results. Optional
```

```shell
  ~:./build.sh -v X.Y.Z -pu NO -s3 YES -z YES
```

6. Edit *BidMachine.podspec*. Change pod version to actual tag. Save

7. Distribute podspec to pirvate repo
```shell
  ~:pod repo push appodeal BidMachine.podspec --allow-warnings
```

8. Publish podspec to public repo
```shell
  ~:pod trunk push BidMachine.podspec --allow-warnings
```