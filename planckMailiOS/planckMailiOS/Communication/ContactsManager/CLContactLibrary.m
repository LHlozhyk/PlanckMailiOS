//
//  CLContactLibrary.m
//
//
//  Created by Chirag Lakhani on 04/03/14.
//  Copyright (c) 2014 Chirag. All rights reserved.
//

#import "CLContactLibrary.h"

@implementation CLContactLibrary{
    NSMutableArray *contactDataArray;
}
@synthesize delegate;

static CLContactLibrary  *object;

+(CLContactLibrary *)sharedInstance{
    if(!object){
        object = [[CLContactLibrary alloc]init];
    }
    return  object;
}

-(void)getContactArrayForDelegate:(id<APContactLibraryDelegate>)aDelegate {
  self.delegate = aDelegate;
  
    contactDataArray = [[NSMutableArray alloc]init];
    
    [self fetchContacts:^(NSArray *contacts) {
        [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            ABRecordRef person = (__bridge ABRecordRef)obj;
            ABMultiValueRef emails  = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            CLPerson *people = [[CLPerson alloc]init];
            if([(__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) length]==0)
                people.firstName = @"";
            else
                people.firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            if([(__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty) length]==0)
                people.lastName = @"";
            else
                people.lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                             kABPersonPhoneProperty);
          
            NSInteger phonesCount = ABMultiValueGetCount(phoneNumbers);
            if (phonesCount > 0) {
                people.phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
              
              //get array of phone numbers
              NSMutableArray *personsPhonnes = [NSMutableArray new];
              for(int i = 0; i < phonesCount; i++) {
                NSMutableDictionary *personsPhonne = [NSMutableDictionary new];
                
                NSString *usersPhoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                if(usersPhoneNumber) {
                  [personsPhonne setObject:usersPhoneNumber forKey:PHONE_NUMBER];
                }
                
                CFStringRef userPhoneLabel = ABMultiValueCopyLabelAtIndex(phoneNumbers, i);
                if(userPhoneLabel) {
                  NSString *phoneLabelLocalized = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(userPhoneLabel);
                  if(phoneLabelLocalized) {
                    [personsPhonne setObject:phoneLabelLocalized forKey:PHONE_TITLE];
                  }
                }
                [personsPhonnes addObject:personsPhonne];
              }
              people.phoneNumbers = personsPhonnes;
            } else {
                people.phoneNumber = @"None";
            }
            
            people.email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, 0);
            people.personImage = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(person)];
            people.fullName = [NSString stringWithFormat:@"%@ %@", people.firstName, people.lastName];
            [contactDataArray addObject:people];
            people = nil;
            
        }];
        [delegate apGetContactArray:[contactDataArray copy]];
    } failure:^(NSError *error) {
      [delegate apGetContactArray:nil];
    }];
}

- (void)getContactArray {
  [self getContactArrayForDelegate:self.delegate];
}

#pragma mark - AddressBook Delegate Method

- (void)fetchContacts:(void (^)(NSArray *contacts))success failure:(void (^)(NSError *error))failure {
    if (ABAddressBookRequestAccessWithCompletion) {
        // on iOS 6
        CFErrorRef err;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &err);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted)
                    failure((__bridge NSError *)error);
                else
                    readAddressBookContacts(addressBook, success);
            });
        });
       
    }
}
static void readAddressBookContacts(ABAddressBookRef addressBook, void (^completion)(NSArray *contacts)) {
    NSArray *contacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    completion(contacts);
}
@end
