Class {
	#name : #ODBTypeCodes,
	#superclass : #SharedPool,
	#classVars : [
		'ODBArrayCode',
		'ODBAssociationCode',
		'ODBByteArrayCode',
		'ODBCharacterCode',
		'ODBClassCode',
		'ODBDateCode',
		'ODBDictionaryCode',
		'ODBDoubleByteCharacterCode',
		'ODBExternalReferenceCode',
		'ODBFalseCode',
		'ODBFloatCode',
		'ODBFractionCode',
		'ODBIdentityDictionaryCode',
		'ODBInternalReferenceCode',
		'ODBLargeNegativeIntegerCode',
		'ODBLargePositiveIntegerCode',
		'ODBMessageCode',
		'ODBMessageSendCode',
		'ODBMinusOneCode',
		'ODBMinusThreeCode',
		'ODBMinusTwoCode',
		'ODBODBIdentityDictionaryCode',
		'ODBOrderedCollectionCode',
		'ODBPersistentDictionaryCode',
		'ODBProcessSchedulerCode',
		'ODBScaledDecimalCode',
		'ODBSmallFloat64Code',
		'ODBSmallPositiveIntegerBaseCode',
		'ODBSmallStringBaseCode',
		'ODBStringCode',
		'ODBSymbolCode',
		'ODBSystemDictionaryCode',
		'ODBTimeCode',
		'ODBTransactionCode',
		'ODBTrueCode',
		'ODBUndefinedObjectCode',
		'ODBWideStringCode',
		'TypeCodeMapping'
	],
	#category : #'OmniBase-Base'
}

{ #category : #initialization }
ODBTypeCodes class >> initialize [ 
	self initializeTypeCodes.
	self initializeTypeCodeMapping
]

{ #category : #initialization }
ODBTypeCodes class >> initializeTypeCodeMapping [
	<script>

	TypeCodeMapping := Array new: 255.
	TypeCodeMapping
		at: 2                                    put: ODBNewObjectNewClass;
		at: 3                                    put: ODBNewObject;
		at: ODBInternalReferenceCode             put: ODBExistingObject;
		at: ODBExternalReferenceCode             put: ODBExternalReference;
		at: 6                                    put: ODBClassManagerForSerialization;
		at: ODBLargePositiveIntegerCode          put: ODBLargePositiveInteger;
		at: ODBLargeNegativeIntegerCode          put: ODBLargeNegativeInteger;
		at: ODBCharacterCode                     put: Character;
		at: ODBUndefinedObjectCode               put: UndefinedObject;
		at: ODBTrueCode                          put: true;
		at: ODBFalseCode                         put: false;
		at: ODBMessageCode                       put: Message;
		at: ODBSymbolCode                        put: Symbol;
		at: ODBSystemDictionaryCode              put: Smalltalk globals;
		at: ODBMessageSendCode                   put: MessageSend;
		at: ODBProcessSchedulerCode              put: Processor;
		at: ODBClassCode                         put: Class;
		at: ODBDoubleByteCharacterCode           put: ODBDoubleByteCharacter;
		at: ODBAssociationCode                   put: Association;
		at: ODBDateCode                          put: Date;
		at: ODBTimeCode                          put: Time;
		at: ODBStringCode                        put: String;
		at: ODBArrayCode                         put: Array;
		at: ODBWideStringCode                    put: WideString;
		at: ODBDictionaryCode                    put: Dictionary;
		at: ODBIdentityDictionaryCode            put: IdentityDictionary;
		at: ODBFractionCode                      put: Fraction;
		at: ODBFloatCode                         put: Float;
		at: ODBScaledDecimalCode                 put: ScaledDecimal;
		at: ODBSmallFloat64Code                  put: SmallFloat64;
	
		at: ODBSmallPositiveIntegerBaseCode      put: 0;
		at: ODBSmallPositiveIntegerBaseCode + 1  put: 1;
		at: ODBSmallPositiveIntegerBaseCode + 2  put: 2;
		at: ODBSmallPositiveIntegerBaseCode + 3  put: 3;
		at: ODBSmallPositiveIntegerBaseCode + 4  put: 4;
		at: ODBSmallPositiveIntegerBaseCode + 5  put: 5;
		at: ODBSmallPositiveIntegerBaseCode + 6  put: 6;
		at: ODBSmallPositiveIntegerBaseCode + 7  put: 7;
		at: ODBSmallPositiveIntegerBaseCode + 8  put: 8;
		at: ODBSmallPositiveIntegerBaseCode + 9  put: 9;
		at: ODBSmallPositiveIntegerBaseCode + 10 put: 10;
		at: ODBSmallPositiveIntegerBaseCode + 11 put: 11;
		at: ODBSmallPositiveIntegerBaseCode + 12 put: 12;
		at: ODBSmallPositiveIntegerBaseCode + 13 put: 13;
		at: ODBSmallPositiveIntegerBaseCode + 14 put: 14;
		at: ODBSmallPositiveIntegerBaseCode + 15 put: 15;
		at: ODBSmallPositiveIntegerBaseCode + 16 put: 16;
		at: ODBMinusThreeCode                    put: -3;
		at: ODBMinusTwoCode                      put: -2;
		at: ODBMinusOneCode                      put: -1;
		at: ODBSmallStringBaseCode               put: ODBEmptyString;
		at: ODBSmallStringBaseCode + 1           put: ODB1CharacterString;
		at: ODBSmallStringBaseCode + 2           put: (ODBnCharacterString length: 2);
		at: ODBSmallStringBaseCode + 3           put: (ODBnCharacterString length: 3);
		at: ODBSmallStringBaseCode + 4           put: (ODBnCharacterString length: 4);
		at: ODBSmallStringBaseCode + 5           put: (ODBnCharacterString length: 5);
		at: ODBSmallStringBaseCode + 6           put: (ODBnCharacterString length: 6);
		at: ODBSmallStringBaseCode + 7           put: (ODBnCharacterString length: 7);
		at: ODBSmallStringBaseCode + 8           put: (ODBnCharacterString length: 8);
		at: ODBSmallStringBaseCode + 9           put: (ODBnCharacterString length: 9);
		at: ODBByteArrayCode                     put: ByteArray;
		at: ODBOrderedCollectionCode             put: OrderedCollection;
		at: ODBODBIdentityDictionaryCode         put: ODBIdentityDictionary; 
		at: ODBPersistentDictionaryCode          put: ODBPersistentDictionary;
		at: ODBTransactionCode                   put: ODBTransaction.
]

{ #category : #initialization }
ODBTypeCodes class >> initializeTypeCodes [
	<script>
	"1 .. 3" 
	ODBInternalReferenceCode := 4.
	ODBExternalReferenceCode := 5.
	"6 .. 10"
	ODBLargePositiveIntegerCode := 11.
	ODBLargeNegativeIntegerCode := 12.
	ODBCharacterCode := 13.
	ODBUndefinedObjectCode := 14.
	ODBTrueCode := 15.
	ODBFalseCode := 16.
	ODBMessageCode := 17.
	ODBSymbolCode := 18.
	ODBSystemDictionaryCode := 19.
	ODBMessageSendCode := 20.
	"21"
	ODBProcessSchedulerCode := 22.
	"23 .. 25"
	ODBClassCode := 26.
	"27 .. 28"
	ODBDoubleByteCharacterCode := 29.
	"30"
	ODBAssociationCode := 31.
	ODBDateCode := 32.
	ODBTimeCode := 33.
	ODBStringCode := 34.
	ODBArrayCode := 35.
	ODBWideStringCode := 36.
	ODBDictionaryCode := 37.
	ODBIdentityDictionaryCode := 38.
	ODBFractionCode := 39.
	ODBFloatCode := 40.
	ODBScaledDecimalCode := 45.
	ODBSmallFloat64Code := 47.
	"integers <= 16 are stored with code 50 + number"
	ODBSmallPositiveIntegerBaseCode := 50. 
	"50 .. 64 integers 0 .. 16"
	ODBMinusThreeCode := 67.
	ODBMinusTwoCode := 68.
	ODBMinusOneCode := 69.
	"small strings of size small than 10 bytes are written with type 70 + size of string"
	ODBSmallStringBaseCode := 70.
	"70 .. 79 small strings"
	ODBByteArrayCode := 80.
	ODBOrderedCollectionCode := 81.
	ODBODBIdentityDictionaryCode := 82.
	ODBPersistentDictionaryCode := 83.
	ODBTransactionCode := 84.
]
