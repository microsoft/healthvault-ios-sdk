//
//  HVClientResult.h
//  HVLib
//
//  Copyright (c) 2012 Microsoft Corporation. All rights reserved.
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

#import <Foundation/Foundation.h>

#if DEBUG
#define HV_DETAILEDTYPEERRORS 1
#endif

#define HVRESULT_SUCCESS [HVClientResult success]
#define HVERROR_UNKNOWN [HVClientResult unknownError]

#ifdef HV_DETAILEDTYPEERRORS
#define HVMAKE_ERROR(code) [HVClientResult fromCode:code fileName:__FILE__ lineNumber:__LINE__]
#else
#define HVMAKE_ERROR(code) [HVClientResult fromCode:code]
#endif


enum HVClientResultCode
{
    HVClientResult_Success = 0,
    //
    // Errors
    //
    HVClientError_Unknown,
    HVClientError_Web,
    //
    // Base types
    //
    HVClientError_InvalidGuid,
    HVClientError_ValueOutOfRange,
    HVClientError_InvalidStringLength,
    //
    // Types
    //
    HVClientError_InvalidDate,
    HVClientError_InvalidTime,
    HVClientError_InvalidDateTime,
    HVClientError_InvalidApproxDateTime,
    HVClientError_InvalidCodedValue,
    HVClientError_InvalidCodableValue,
    HVClientError_InvalidDisplayValue,
    HVClientError_InvalidMeasurement,
    HVClientError_InvalidApproxMeasurement,
    HVClientError_InvalidWeightMeasurement,
    HVClientError_InvalidLengthMeasurement,
    HVClientError_InvalidBloodGlucoseMeasurement,
    HVClientError_InvalidVitalSignResult,
    HVClientError_InvalidNameValue,
    HVClientError_InvalidDuration,
    HVClientError_InvalidAddress,
    HVClientError_InvalidPhone,
    HVClientError_InvalidEmailAddress,
    HVClientError_InvalidEmail,
    HVClientError_InvalidContact,
    HVClientError_InvalidName,
    HVClientError_InvalidPerson,
    HVClientError_InvalidOrganization,
    HVClientError_InvalidPrescription,
    HVClientError_InvalidItemKey,
    HVClientError_InvalidRelatedItem,
    HVClientError_InvalidItemType,
    HVClientError_InvalidItemView,
    HVClientError_InvalidItemQuery,
    HVClientError_InvalidItem,
    HVClientError_InvalidRecordReference,
    HVClientError_InvalidRecord,
    HVClientError_InvalidPersonInfo,
    HVClientError_InvalidPendingItem,
    HVClientError_InvalidItemList,
    HVClientError_InvalidVocabIdentifier,
    HVClientError_InvalidVocabItem,
    HVClientError_InvalidVocabSearch,
    HVClientError_InvalidAssessmentField,
    HVClientError_InvalidOccurrence,
    HVClientError_InvalidRelative,
    //
    // Item Types
    //
    HVClientError_InvalidWeight,
    HVClientError_InvalidBloodPressure,
    HVClientError_InvalidCholesterol,
    HVClientError_InvalidBloodGlucose,
    HVClientError_InvalidHeight,
    HVClientError_InvalidExercise,
    HVClientError_InvalidAllergy,
    HVClientError_InvalidCondition,
    HVClientError_InvalidImmunization,
    HVClientError_InvalidMedication,
    HVClientError_InvalidProcedure,
    HVClientError_InvalidVitalSigns,
    HVClientError_InvalidEncounter,
    HVClientError_InvalidFamilyHistory,
    HVClientError_InvalidEmergencyContact,
    HVClientError_InvalidPersonalContactInfo,   
    HVClientError_InvalidBasicDemographics,
    HVClientError_InvalidPersonalDemographics,
    HVClientError_InvalidDailyMedicationUsage,
    HVClientError_InvalidAssessment,
    HVClientError_InvalidQuestionAnswer,
    HVClientError_InvalidSleepJournal,
    HVClientError_InvalidDietaryIntake,
    //
    // Store
    //
    HVClientError_Sync,
    HVClientError_PutLocalStore
};

@interface HVClientResult : NSObject
{    
    enum HVClientResultCode m_error;
    const char* m_file;
    int m_line;
}

@property (readonly, nonatomic) BOOL isSuccess;
@property (readonly, nonatomic) BOOL isError;

@property (readonly, nonatomic) enum HVClientResultCode error;
@property (readonly, nonatomic) const char* fileName;
@property (readonly, nonatomic) int lineNumber;

+(void) initialize;
-(id) init;
-(id) initWithCode:(enum HVClientResultCode)code;
-(id) initWithCode:(enum HVClientResultCode)code fileName:(const char *)fileName lineNumber:(int)line;

+(HVClientResult *) success;
+(HVClientResult *) unknownError;
+(HVClientResult *) fromCode:(enum HVClientResultCode) code;
+(HVClientResult *) fromCode:(enum HVClientResultCode)code fileName:(const char *)fileName lineNumber:(int)line;

@end