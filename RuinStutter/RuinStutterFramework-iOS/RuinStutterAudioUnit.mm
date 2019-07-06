//
//  RuinStutterAU_iOSAudioUnit.m
//  RuinStutterAU-iOS
//
//  Created by Simon Haycock on 06/07/2019.
//  Copyright © 2019 Hyper Barn LTD. All rights reserved.
//

#import "RuinStutterAudioUnit.h"

#import <AVFoundation/AVFoundation.h>
#import "RuinAUUtilites/RuinAUUtilites.h"
#import "RuinStutterKernel.hpp"

static const UInt8 kNumberOfPresets = 1;
static const NSInteger kDefaultFactoryPreset = 0;

typedef struct FactoryPresetParameters {
    AUValue enable; // TODO: Does not need to be part of preset
    AUValue length;
    AUValue pitch;
} FactoryPresetParameters;

static const FactoryPresetParameters presetParameters[kNumberOfPresets] =
{
    {
        0.0f,    // StutterParameterEnable
        200.0f,  // StutterParameterLength
        1.0f     // StutterParameterPitch
    }
};

@interface RuinStutterAudioUnit ()

@property (nonatomic, readwrite) AUParameterTree *parameterTree;
@property (nonatomic, readwrite) AUAudioUnitBus *outputBus;
@property (nonatomic, readwrite) AUAudioUnitBusArray *inputBusArray;
@property (nonatomic, readwrite) AUAudioUnitBusArray *outputBusArray;

@end


@implementation RuinStutterAudioUnit {
    RuinStutterKernel _kernel;
    BufferedInputBus _inputBus;
    
    NSInteger _currentFactoryPresetIndex;
    AUAudioUnitPreset *_currentPreset;
    NSArray<AUAudioUnitPreset *> *_presets;
}

@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    
    // Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    
    // Initialize DSP kernel
    _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);
    
    // Create the input and output busses.
    _inputBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    
    // Create the input and output bus arrays.
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeInput busses: @[_inputBus.bus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    
    // Create parameters
    AUParameter *enableParameter = [AUParameterTree createParameterWithIdentifier:@"enable"
                                                                             name:@"Enable"
                                                                          address:StutterParameterEnable
                                                                              min:0
                                                                              max:1
                                                                             unit:kAudioUnitParameterUnit_Boolean
                                                                         unitName:nil
                                                                            flags:kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_CanRamp
                                                                     valueStrings:nil
                                                              dependentParameters:nil];
    
    AUParameter *lengthParameter = [AUParameterTree createParameterWithIdentifier:@"length"
                                                                             name:@"Length"
                                                                          address:StutterParameterLength
                                                                              min:StutterMinLengthInMS
                                                                              max:StutterMaxLengthInMS
                                                                             unit:kAudioUnitParameterUnit_Milliseconds
                                                                         unitName:nil
                                                                            flags:kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_CanRamp
                                                                     valueStrings:nil
                                                              dependentParameters:nil];
    
    AUParameter *pitchParameter = [AUParameterTree createParameterWithIdentifier:@"pitch"
                                                                            name:@"Pitch"
                                                                         address:StutterParameterPitch
                                                                             min:StutterMinPitchAsRatio
                                                                             max:StutterMaxPitchAsRatio
                                                                            unit:kAudioUnitParameterUnit_Ratio
                                                                        unitName:nil
                                                                           flags:kAudioUnitParameterFlag_IsReadable | kAudioUnitParameterFlag_IsWritable | kAudioUnitParameterFlag_CanRamp
                                                                    valueStrings:nil
                                                             dependentParameters:nil];
    // Set default for parameters
    enableParameter.value = 0;
    lengthParameter.value = 200;
    pitchParameter.value = 1.0;
    
    _kernel.setParameter(StutterParameterEnable, enableParameter.value);
    _kernel.setParameter(StutterParameterLength, lengthParameter.value);
    _kernel.setParameter(StutterParameterPitch, pitchParameter.value);
    
    // Create parameter tree
    _parameterTree = [AUParameterTree createTreeWithChildren:@[enableParameter, lengthParameter, pitchParameter]];
    
    // A function to provide string representations of parameter values
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address) {
            case StutterParameterEnable:
                return value == 0 ? @"Enabled" : @"Disabled";
            case StutterParameterLength:
                return [NSString stringWithFormat:@"%.f", value];
            case StutterParameterPitch:
                return [NSString stringWithFormat:@"%.f", value];
            default:
                return @"?";
        }
    };
    
    // Plumbing for AU parameter observing / providing
    __block RuinStutterKernel *blockKernel = &_kernel;
    // implementorValueObserver is called when a parameter changes value
    _parameterTree.implementorValueObserver = ^(AUParameter * _Nonnull param, AUValue value) {
        blockKernel->setParameter(param.address, value);
    };
    // implementorValueProvider is called when the value needs to be refreshed
    _parameterTree.implementorValueProvider = ^AUValue(AUParameter * _Nonnull param) {
        return blockKernel->getParameter(param.address);
    };
    
    // Create factory preset array.
    _currentFactoryPresetIndex = kDefaultFactoryPreset;
    _presets = @[[self newPresetWithNumber:0 name:@"Default"]];
    _currentPreset = _presets.firstObject;
    
    self.maximumFramesToRender = 512;
    
    return self;
}

- (AUAudioUnitPreset*)newPresetWithNumber:(NSInteger)number name:(NSString *)name {
    AUAudioUnitPreset *aPreset = [AUAudioUnitPreset new];
    aPreset.number = number;
    aPreset.name = name;
    return aPreset;
}

#pragma mark - AUAudioUnit Overrides

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}

// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    if (self.outputBus.format.channelCount != _inputBus.bus.format.channelCount) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization userInfo:nil];
        }
        // Notify superclass that initialization was not successful
        self.renderResourcesAllocated = NO;
        
        return NO;
    }
    
    _inputBus.allocateRenderResources(self.maximumFramesToRender);
    
    // TODO: Allocate memory for kernel
    
    return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
    
    _inputBus.deallocateRenderResources();
    
    // TODO: Deallocate memory for stutter kernel
    
    [super deallocateRenderResources];
}

- (BOOL)canProcessInPlace {
    return YES;
}

- (AUAudioUnitPreset *)currentPreset
{
    if (_currentPreset.number >= 0) {
        NSLog(@"Returning Current Factory Preset: %ld\n", (long)_currentFactoryPresetIndex);
        return [_presets objectAtIndex:_currentFactoryPresetIndex];
    } else {
        NSLog(@"Returning Current Custom Preset: %ld, %@\n", (long)_currentPreset.number, _currentPreset.name);
        return _currentPreset;
    }
}

- (void)setCurrentPreset:(AUAudioUnitPreset *)currentPreset {
    
    NSAssert(currentPreset != nil, @"Setting nil as current preset");
    
    if (currentPreset.number >= 0) {
        for (AUAudioUnitPreset *factoryPreset in _presets) {
            if (currentPreset.number == factoryPreset.number) {
                
                AUParameter *enableParameter = [self.parameterTree valueForKey: @"enable"];
                AUParameter *lengthParameter = [self.parameterTree valueForKey: @"length"];
                AUParameter *pitchParameter = [self.parameterTree valueForKey: @"pitch"];
                
                enableParameter.value = presetParameters[factoryPreset.number].enable;
                lengthParameter.value = presetParameters[factoryPreset.number].length;
                pitchParameter.value = presetParameters[factoryPreset.number].pitch;
                
                // set factory preset as current
                _currentPreset = currentPreset;
                _currentFactoryPresetIndex = factoryPreset.number;
                NSLog(@"currentPreset Factory: %ld, %@\n", (long)_currentFactoryPresetIndex, factoryPreset.name);
                break;
            }
        }
    } else if (nil != currentPreset.name) {
        // set custom preset as current
        _currentPreset = currentPreset;
        NSLog(@"currentPreset Custom: %ld, %@\n", (long)_currentPreset.number, _currentPreset.name);
    } else {
        NSLog(@"setCurrentPreset not set! - invalid AUAudioUnitPreset\n");
    }
}

- (NSArray<AUAudioUnitPreset*>*)factoryPresets {
    return _presets;
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    // Capture in locals to avoid Obj-C member lookups. If "self" is captured in render, we're doing it wrong. See sample code.
    
    // Specify captured objects are mutable.
    __block RuinStutterKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;
    
    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp *timestamp,
                              AVAudioFrameCount frameCount,
                              NSInteger outputBusNumber,
                              AudioBufferList *outputData,
                              const AURenderEvent *realtimeEventListHead,
                              AURenderPullInputBlock pullInputBlock) {
        
        // Do event handling and signal processing here.
        
        AUAudioUnitStatus err = input->pullInput(actionFlags, timestamp, frameCount, outputBusNumber, pullInputBlock);
        
        if (err != 0) { return err; }
        
        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;
        
        // If passed null output buffer pointers, process in-place in the input buffer.
        AudioBufferList *outAudioBufferList = outputData;
        
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        }
        
        state->setBuffers(inAudioBufferList, outAudioBufferList);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);
        
        return noErr;
    };
}

@end

