// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: bidmachine/protobuf/init.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
 #define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
 #import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
 #import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import "bidmachine/protobuf/Init.pbobjc.h"
#import "bidmachine/protobuf/adcom/Adcom.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - BDMInitRoot

@implementation BDMInitRoot

// No extensions in the file and none of the imports (direct or indirect)
// defined extensions, so no need to generate +extensionRegistry.

@end

#pragma mark - BDMInitRoot_FileDescriptor

static GPBFileDescriptor *BDMInitRoot_FileDescriptor(void) {
  // This is called by +initialize so there is no need to worry
  // about thread safety of the singleton.
  static GPBFileDescriptor *descriptor = NULL;
  if (!descriptor) {
    GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
    descriptor = [[GPBFileDescriptor alloc] initWithPackage:@"bidmachine.protobuf"
                                                 objcPrefix:@"BDM"
                                                     syntax:GPBFileSyntaxProto3];
  }
  return descriptor;
}

#pragma mark - BDMInitRequest

@implementation BDMInitRequest

@dynamic sellerId;
@dynamic bundle;
@dynamic os;
@dynamic osv;
@dynamic hasGeo, geo;
@dynamic sdk;
@dynamic sdkver;
@dynamic ifa;
@dynamic deviceType;
@dynamic contype;

typedef struct BDMInitRequest__storage_ {
  uint32_t _has_storage_[1];
  ADCOMOS os;
  ADCOMDeviceType deviceType;
  ADCOMConnectionType contype;
  NSString *sellerId;
  NSString *bundle;
  NSString *osv;
  ADCOMContext_Geo *geo;
  NSString *sdk;
  NSString *sdkver;
  NSString *ifa;
} BDMInitRequest__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "sellerId",
        .dataTypeSpecific.className = NULL,
        .number = BDMInitRequest_FieldNumber_SellerId,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, sellerId),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "bundle",
        .dataTypeSpecific.className = NULL,
        .number = BDMInitRequest_FieldNumber_Bundle,
        .hasIndex = 1,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, bundle),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "os",
        .dataTypeSpecific.enumDescFunc = ADCOMOS_EnumDescriptor,
        .number = BDMInitRequest_FieldNumber_Os,
        .hasIndex = 2,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, os),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "osv",
        .dataTypeSpecific.className = NULL,
        .number = BDMInitRequest_FieldNumber_Osv,
        .hasIndex = 3,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, osv),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "geo",
        .dataTypeSpecific.className = GPBStringifySymbol(ADCOMContext_Geo),
        .number = BDMInitRequest_FieldNumber_Geo,
        .hasIndex = 4,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, geo),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeMessage,
      },
      {
        .name = "sdk",
        .dataTypeSpecific.className = NULL,
        .number = BDMInitRequest_FieldNumber_Sdk,
        .hasIndex = 5,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, sdk),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "sdkver",
        .dataTypeSpecific.className = NULL,
        .number = BDMInitRequest_FieldNumber_Sdkver,
        .hasIndex = 6,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, sdkver),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "ifa",
        .dataTypeSpecific.className = NULL,
        .number = BDMInitRequest_FieldNumber_Ifa,
        .hasIndex = 7,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, ifa),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "deviceType",
        .dataTypeSpecific.enumDescFunc = ADCOMDeviceType_EnumDescriptor,
        .number = BDMInitRequest_FieldNumber_DeviceType,
        .hasIndex = 8,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, deviceType),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
      {
        .name = "contype",
        .dataTypeSpecific.enumDescFunc = ADCOMConnectionType_EnumDescriptor,
        .number = BDMInitRequest_FieldNumber_Contype,
        .hasIndex = 9,
        .offset = (uint32_t)offsetof(BDMInitRequest__storage_, contype),
        .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
        .dataType = GPBDataTypeEnum,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BDMInitRequest class]
                                     rootClass:[BDMInitRoot class]
                                          file:BDMInitRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(BDMInitRequest__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end

int32_t BDMInitRequest_Os_RawValue(BDMInitRequest *message) {
  GPBDescriptor *descriptor = [BDMInitRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:BDMInitRequest_FieldNumber_Os];
  return GPBGetMessageInt32Field(message, field);
}

void SetBDMInitRequest_Os_RawValue(BDMInitRequest *message, int32_t value) {
  GPBDescriptor *descriptor = [BDMInitRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:BDMInitRequest_FieldNumber_Os];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

int32_t BDMInitRequest_DeviceType_RawValue(BDMInitRequest *message) {
  GPBDescriptor *descriptor = [BDMInitRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:BDMInitRequest_FieldNumber_DeviceType];
  return GPBGetMessageInt32Field(message, field);
}

void SetBDMInitRequest_DeviceType_RawValue(BDMInitRequest *message, int32_t value) {
  GPBDescriptor *descriptor = [BDMInitRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:BDMInitRequest_FieldNumber_DeviceType];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

int32_t BDMInitRequest_Contype_RawValue(BDMInitRequest *message) {
  GPBDescriptor *descriptor = [BDMInitRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:BDMInitRequest_FieldNumber_Contype];
  return GPBGetMessageInt32Field(message, field);
}

void SetBDMInitRequest_Contype_RawValue(BDMInitRequest *message, int32_t value) {
  GPBDescriptor *descriptor = [BDMInitRequest descriptor];
  GPBFieldDescriptor *field = [descriptor fieldWithNumber:BDMInitRequest_FieldNumber_Contype];
  GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - BDMInitResponse

@implementation BDMInitResponse

@dynamic endpoint;
@dynamic eventArray, eventArray_Count;

typedef struct BDMInitResponse__storage_ {
  uint32_t _has_storage_[1];
  NSString *endpoint;
  NSMutableArray *eventArray;
} BDMInitResponse__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
  static GPBDescriptor *descriptor = nil;
  if (!descriptor) {
    static GPBMessageFieldDescription fields[] = {
      {
        .name = "endpoint",
        .dataTypeSpecific.className = NULL,
        .number = BDMInitResponse_FieldNumber_Endpoint,
        .hasIndex = 0,
        .offset = (uint32_t)offsetof(BDMInitResponse__storage_, endpoint),
        .flags = GPBFieldOptional,
        .dataType = GPBDataTypeString,
      },
      {
        .name = "eventArray",
        .dataTypeSpecific.className = GPBStringifySymbol(ADCOMAd_Event),
        .number = BDMInitResponse_FieldNumber_EventArray,
        .hasIndex = GPBNoHasBit,
        .offset = (uint32_t)offsetof(BDMInitResponse__storage_, eventArray),
        .flags = GPBFieldRepeated,
        .dataType = GPBDataTypeMessage,
      },
    };
    GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[BDMInitResponse class]
                                     rootClass:[BDMInitRoot class]
                                          file:BDMInitRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(BDMInitResponse__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
    NSAssert(descriptor == nil, @"Startup recursed!");
    descriptor = localDescriptor;
  }
  return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
