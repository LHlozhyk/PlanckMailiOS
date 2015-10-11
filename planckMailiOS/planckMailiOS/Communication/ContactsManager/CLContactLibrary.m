//
//  CLContactLibrary.m
//
//
//  Created by Chirag Lakhani on 04/03/14.
//  Copyright (c) 2014 Chirag. All rights reserved.
//

#import "CLContactLibrary.h"
#import "UIImage+ImageSize.h"

#define kSAVED_CONTACTS_ARRAY_KEY @"contacts_array_key"

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
  
    [self fetchContactsWithCompletion:^{
        if([delegate respondsToSelector:@selector(apGetContactArray:)]) {
            [delegate apGetContactArray:[contactDataArray copy]];
        }
    }];
}

- (void)getContactArray {
  [self getContactArrayForDelegate:self.delegate];
}

- (void)getContactsNamesCount:(NSInteger)count offset:(NSInteger)offset forDelegate:(id<APContactLibraryDelegate>)aDelegate {
    self.delegate = aDelegate;
    NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
    if(savedContacts) {
        [self parseContactsNamesCount:count offset:offset];
    } else {
        [self fetchContactsWithCompletion:^{
            [self parseContactsNamesCount:count offset:offset];
        }];
    }
}

- (void)getPersonForContactNames:(NSDictionary *)names forDelegate:(id<APContactLibraryDelegate>)aDelegate {
    self.delegate = aDelegate;
    
    if(names) {
        NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
        if(savedContacts) {
            [self.delegate getPersonForNames:[self personForNames:names]];
        } else {
            [self fetchContactsWithCompletion:^{
                [self.delegate getPersonForNames:[self personForNames:names]];
            }];
        }
    } else {
        [self.delegate getPersonForNames:nil];
    }
}

#pragma mark - Private methods

- (void)fetchContactsWithCompletion:(void(^)())completion {
    contactDataArray = [[NSMutableArray alloc]init];
    [self fetchContacts:^(NSArray *contacts) {
        NSMutableArray *archivedPersons = [NSMutableArray new];
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
                    //phone number
                    NSString *usersPhoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                    if(usersPhoneNumber) {
                        [personsPhonne setObject:usersPhoneNumber forKey:PHONE_NUMBER];
                    }
                    //phone title
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
            UIImage *personImage = [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(person)];
            people.personImage = personImage;
            people.fullName = [NSString stringWithFormat:@"%@ %@", people.firstName, people.lastName];
            [contactDataArray addObject:people];
            
            [archivedPersons addObject:[NSKeyedArchiver archivedDataWithRootObject:people]];
        }];
        
//        NSMutableArray *newArchivedPersons = [NSMutableArray new];
//        for(int i = 0; i <=1 ; i++) {
//            for(NSData *person in archivedPersons) {
//                [newArchivedPersons addObject:[person copy]];
//            }
//        }
        
        [[NSUserDefaults standardUserDefaults] setObject:archivedPersons forKey:kSAVED_CONTACTS_ARRAY_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(completion) {
            completion();
        }
    } failure:^(NSError *error) {
        if(completion) {
            completion();
        }
    }];
}

- (void)parseContactsNamesCount:(NSInteger)count offset:(NSInteger)offset {
    NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
    NSMutableArray *personsArray = [NSMutableArray new];
    
    for(NSInteger i = offset; i < count + offset; i++) {
        if(i >= [savedContacts count]) {
            break;
        }
        NSData *archivedItem = savedContacts[i];
        
        CLPerson *person = [NSKeyedUnarchiver unarchiveObjectWithData:archivedItem];
        if(person) {
            NSDictionary *personNames = @{PERSON_NAME: person.firstName?:@"",
                                          PERSON_SECOND_NAME: person.lastName?:@""};
            [personsArray addObject:personNames];
        }
    }
    DLog(@"names count: %li", [personsArray count]);
    if([self.delegate respondsToSelector:@selector(getNamesOfContacts:)]) {
        [self.delegate getNamesOfContacts:personsArray];
    }
}

- (CLPerson *)personForNames:(NSDictionary *)names {
    CLPerson *person = nil;
    
    NSArray *savedContacts = [[NSUserDefaults standardUserDefaults] arrayForKey:kSAVED_CONTACTS_ARRAY_KEY];
    for(NSData *savedPerson in savedContacts) {
        person = [NSKeyedUnarchiver unarchiveObjectWithData:savedPerson];
        
        if([person.firstName isEqualToString:names[PERSON_NAME]] &&
           [person.lastName isEqualToString:names[PERSON_SECOND_NAME]]) {
            if(person.personImage) {
                person.personImage = [[person.personImage getScaledImage] roundCorners];
            }
            
            break;
        }
    }
    
    return person;
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
