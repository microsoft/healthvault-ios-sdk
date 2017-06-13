//
//  MHVExplanationOfBenefitsTests.m
// MHVLib
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

#import <XCTest/XCTest.h>
#import "Kiwi.h"
#import "MHVExplanationOfBenefits.h"

SPEC_BEGIN(MHVExplanationOfBenefitsTests)

describe(@"MHVExplanationOfBenefits", ^
         {
             NSString *objectDefinition = @"<explanation-of-benefits><date-submitted><date><y>2010</y><m>1</m><d>1</d></date></date-submitted><patient><name><full>John Patient</full></name></patient><relationship-to-member><text>Self</text><code><value>1</value><family>wc</family><type>relationship-types</type><version>1</version></code></relationship-to-member><plan><name>Contoso Medical</name></plan><group-id>5551212</group-id><member-id>11111111-01</member-id><claim-type><text>Medical</text><code><value>Medical</value><family>wc</family><type>explanation-of-benefits-claim-types</type><version>1</version></code></claim-type><claim-id>222222222</claim-id><submitted-by><name>General Family Practice</name></submitted-by><provider><name>Darryl Doctor</name></provider><currency><text>US Dollar</text><code><value>USD</value><family>iso</family><type>iso4217</type><version>1</version></code></currency><claim-totals><charged-amount>360.5</charged-amount><negotiated-amount>276.67</negotiated-amount><copay>20.5</copay><deductible>0</deductible><amount-not-covered>90</amount-not-covered><eligible-for-benefits>167.67</eligible-for-benefits><coinsurance>16.67</coinsurance><miscellaneous-adjustments>0.5</miscellaneous-adjustments><benefits-paid>150</benefits-paid><patient-responsibility>126.67</patient-responsibility></claim-totals><services><service-type><text>Office Visit</text></service-type><service-dates><start-date><structured><date><y>2010</y><m>1</m><d>1</d></date></structured></start-date></service-dates><claim-amounts><charged-amount>110</charged-amount><negotiated-amount>90</negotiated-amount><copay>20.5</copay><deductible>0.5</deductible><amount-not-covered>0.5</amount-not-covered><eligible-for-benefits>70</eligible-for-benefits><percentage-covered>0.91</percentage-covered><coinsurance>7.5</coinsurance><miscellaneous-adjustments>0.5</miscellaneous-adjustments><benefits-paid>63</benefits-paid><patient-responsibility>27</patient-responsibility></claim-amounts></services><services><service-type><text>Lab</text></service-type><service-dates><start-date><structured><date><y>2010</y><m>1</m><d>1</d></date></structured></start-date></service-dates><claim-amounts><charged-amount>140</charged-amount><negotiated-amount>96.67</negotiated-amount><copay>0</copay><deductible>0</deductible><amount-not-covered>0.5</amount-not-covered><eligible-for-benefits>96.67</eligible-for-benefits><percentage-covered>0.9</percentage-covered><coinsurance>9.67</coinsurance><miscellaneous-adjustments>0.5</miscellaneous-adjustments><benefits-paid>87</benefits-paid><patient-responsibility>9.67</patient-responsibility></claim-amounts></services><services><service-type><text>Lab</text></service-type><service-dates><start-date><structured><date><y>2010</y><m>1</m><d>1</d></date></structured></start-date></service-dates><claim-amounts><charged-amount>110</charged-amount><negotiated-amount>90</negotiated-amount><copay>0</copay><deductible>0</deductible><amount-not-covered>90.5</amount-not-covered><eligible-for-benefits>0</eligible-for-benefits><coinsurance>0</coinsurance><miscellaneous-adjustments>0.5</miscellaneous-adjustments><benefits-paid>0</benefits-paid><patient-responsibility>90</patient-responsibility></claim-amounts><notes>Code 38.5</notes></services></explanation-of-benefits>";
             
             context(@"Deserialize", ^
                     {
                         it(@"should deserialize correctly", ^                            {
                                MHVExplanationOfBenefits *eob = (MHVExplanationOfBenefits*)[XReader newFromString:objectDefinition withRoot:[MHVExplanationOfBenefits XRootElement] asClass:[MHVExplanationOfBenefits class]];
                                
                                [[eob.dateSubmitted.description should] equal:@"01/01/10 12:00 AM"];
                                [[eob.patient.description should] equal:@"John Patient"];
                                [[eob.relationshipToMember.description should] equal:@"Self"];
                                [[eob.plan.description should] equal:@"Contoso Medical"];
                                [[eob.groupId.description should] equal:@"5551212"];
                                [[eob.memberId.description should] equal:@"11111111-01"];
                                [[eob.claimType.description should] equal:@"Medical"];
                                [[eob.claimId.description should] equal:@"222222222"];
                                [[eob.submittedBy.description should] equal:@"General Family Practice"];
                                [[eob.provider.description should] equal:@"Darryl Doctor"];
                                [[eob.currency.description should] equal:@"US Dollar"];
                                [[theValue(eob.claimTotals.chargedAmount.value) should] equal:theValue(360.5)];
                                [[theValue(eob.services.count) should] equal:theValue(3)];
                            });
                     });
             
             context(@"Serialize", ^
                     {
                        it(@"should serialize correctly", ^
                           {
                               MHVExplanationOfBenefits *eob = (MHVExplanationOfBenefits*)[XReader newFromString:objectDefinition withRoot:[MHVExplanationOfBenefits XRootElement] asClass:[MHVExplanationOfBenefits class]];
                               
                               XWriter *writer = [[XWriter alloc] initWithBufferSize:2048];
                               [writer writeStartElement:[MHVExplanationOfBenefits XRootElement]];
                               [eob serialize:writer];
                               [writer writeEndElement];
                               
                               NSString *result = [writer newXmlString];
                               
                               [[result should] equal:objectDefinition];

                           });
                     });
         });

SPEC_END
