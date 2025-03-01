//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AudioControllerDelegate <NSObject>

- (void)audioControllerDidReceiveText:(NSString *)string isFinal:(BOOL)isFinal;
- (void)audioControllerDidReceiveError:(NSError *)error;

@end

@interface AudioController : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<AudioControllerDelegate> delegate;

@property (nonatomic, readonly, getter=isRunning) BOOL running;
@property (nonatomic, strong) NSString *languageCode;

- (void)startRecordAudio;
- (void)stopRecordAudio;

@end
