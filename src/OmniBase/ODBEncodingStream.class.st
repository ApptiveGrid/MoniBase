Class {
	#name : #ODBEncodingStream,
	#superclass : #Object,
	#instVars : [
		'stream',
		'readerWriter'
	],
	#pools : [
		'ODBTypeCodes'
	],
	#classInstVars : [
		'typeCodeMapping',
		'characterEncoder'
	],
	#category : #'OmniBase-Streams'
}

{ #category : #accessing }
ODBEncodingStream class >> characterEncoder [
	^ characterEncoder
]

{ #category : #accessing }
ODBEncodingStream class >> characterEncoding: aString [
	characterEncoder := aString asZnCharacterEncoder
]

{ #category : #convenience }
ODBEncodingStream class >> decodeBytes: aByteArray [ 
	^ characterEncoder decodeBytes: aByteArray
]

{ #category : #convenience }
ODBEncodingStream class >> encodeString: aString [ 
	^ characterEncoder encodeString: aString
]

{ #category : #initialization }
ODBEncodingStream class >> initialize [ 
	self initializeEncoding
]

{ #category : #initialization }
ODBEncodingStream class >> initializeEncoding [
	"see ZnUTFEncoder knownEncodingIdentifiers for all supported encodings"
	self characterEncoding: #utf8
]

{ #category : #'instance creation' }
ODBEncodingStream class >> on: aStream [ 
	^ self new 
		stream: aStream
]

{ #category : #'initialize-release' }
ODBEncodingStream >> close [
	stream ifNotNil: [
		stream close.
		stream := nil ]
]

{ #category : #finalization }
ODBEncodingStream >> finalize [
	self close
]

{ #category : #finalization }
ODBEncodingStream >> flush [
	"Force all data written to the 
	receiver to be recorded on disk."

	stream flush
]

{ #category : #public }
ODBEncodingStream >> getBytesFor: aByteCollection len: len [ 
	"Read len bytes from stream to aByteCollection. 
	Answer number of bytes actualy read."
	
	^ stream getBytesFor: aByteCollection len: len
]

{ #category : #accessing }
ODBEncodingStream >> lockAt: position length: length [ 

	^ stream lockAt: position length: length
]

{ #category : #reading }
ODBEncodingStream >> nextArray: aClass [
	| array |
	array := aClass new: stream getPositiveInteger.
	readerWriter register: array.
	1 to: array size do: [:i | array at: i put: self odbNextObject ].
	^array
]

{ #category : #reading }
ODBEncodingStream >> nextAssociation: aClass [
	| result |
	readerWriter register: (result := aClass new).
	^result
		key: self odbNextObject;
		value: self odbNextObject
]

{ #category : #reading }
ODBEncodingStream >> nextByteArray: aClass [
	| array |
	array := aClass new: stream getPositiveInteger.
	readerWriter register: array.
	1 to: array size do: [:i | 
		array 
			at: i 
			put: stream getPositiveInteger ].
	^array
]

{ #category : #reading }
ODBEncodingStream >> nextCharacter [
	"call to #register: not needed as character is an immediate Object"
	^ stream getChar
]

{ #category : #reading }
ODBEncodingStream >> nextClass [
	^ Smalltalk 
		at: stream getString asSymbol 
		ifAbsent: nil
]

{ #category : #reading }
ODBEncodingStream >> nextDate: aClass [
	^ readerWriter register: (aClass 
		odbDateFromSeconds: stream getInteger 
		offset: stream getInteger)
]

{ #category : #reading }
ODBEncodingStream >> nextDictionary: aClass [
	| size dict key |
	size := stream getPositiveInteger.
	dict := aClass new: size.
	readerWriter register: dict.
	size timesRepeat: [
		key := self odbNextObject.
		dict at: key put: self odbNextObject.
	].
	^dict
]

{ #category : #reading }
ODBEncodingStream >> nextDoubleByteCharacter [
	"call to #register: not needed as character is an immediate Object"
	^ Character value: stream getWord
]

{ #category : #reading }
ODBEncodingStream >> nextFraction: aClass [
	^ aClass 
		numerator: stream getInteger
		denominator: stream getInteger
]

{ #category : #reading }
ODBEncodingStream >> nextLargeNegativeInteger [
	^ 0 - stream getPositiveInteger
]

{ #category : #reading }
ODBEncodingStream >> nextLargePositiveInteger [
	^ stream getPositiveInteger
]

{ #category : #reading }
ODBEncodingStream >> nextMessage: aClass [
	| result |
	readerWriter register: (result := aClass new).
	^ result
		setSelector: self odbNextObject arguments: self odbNextObject;
		yourself
]

{ #category : #reading }
ODBEncodingStream >> nextMessageSend: aClass [
	| result |
	readerWriter register: (result := aClass new).
	^result
		receiver: self odbNextObject;
		selector: self odbNextObject;
		arguments: self odbNextObject;
		yourself
]

{ #category : #reading }
ODBEncodingStream >> nextODBIdentityDictionary: aClass [ 
	| size dict key |
	size := stream getPositiveInteger.
	dict := aClass new: size.
	readerWriter register: dict.
	size timesRepeat: 
			[key := self odbNextObject.
			dict at: key put: self odbNextObject].
	^dict
]

{ #category : #reading }
ODBEncodingStream >> nextOneCharacterString [
	^  readerWriter register: stream getChar asString
]

{ #category : #reading }
ODBEncodingStream >> nextOrderedCollection: aClass [
	| coll size |
	size := stream getPositiveInteger.
	readerWriter register: (coll := aClass new: size).
	size timesRepeat: [ coll addLast: self odbNextObject ].
	^coll
]

{ #category : #reading }
ODBEncodingStream >> nextPersistentDictionary: aClass [
		| size dict |
	size := stream getPositiveInteger.
	dict := aClass new: size.
	readerWriter register: dict.
	size timesRepeat: [
		dict 
			superAt: self odbNextObject 
			put: self odbNextObject ].
	^dict
]

{ #category : #writing }
ODBEncodingStream >> nextPutArray: anArray [
	stream 
		putByte: ODBArrayCode; 
		putPositiveInteger: anArray size.
	1 to: anArray size do: [:i | 
		(anArray at: i) odbSerialize: readerWriter ].
]

{ #category : #writing }
ODBEncodingStream >> nextPutAssociation: anAssociation [ 
	stream putByte: ODBAssociationCode.
	anAssociation key odbSerialize: readerWriter.
	anAssociation value odbSerialize: readerWriter.
]

{ #category : #writing }
ODBEncodingStream >> nextPutBoxedFloat64: aNumber [ 
	stream
		putByte: ODBFloatCode;
		putInteger: (aNumber at: 1);
		putInteger: (aNumber at: 2)
]

{ #category : #writing }
ODBEncodingStream >> nextPutByteArray: aByteArray [
	stream 
		putByte: ODBByteArrayCode; 
		putPositiveInteger: aByteArray size.
	1 to: aByteArray size do: [:i |
		stream putByte: (aByteArray at: i)].
]

{ #category : #writing }
ODBEncodingStream >> nextPutCharacter: aCharacter [ 
	aCharacter asInteger < 256 ifTrue: [
		stream 
			putByte: ODBCharacterCode; 
			putChar: aCharacter.
		^ aCharacter
	].
	stream 
		putByte: ODBDoubleByteCharacterCode; 
		putWord: aCharacter asInteger
]

{ #category : #writing }
ODBEncodingStream >> nextPutClass: aClass [ 
	stream 
		putByte: ODBClassCode; 
		putString: aClass name asString
]

{ #category : #writing }
ODBEncodingStream >> nextPutDate: aDate [ 
	stream 
		putByte: ODBDateCode; 
		putInteger: aDate julianDayNumber - 2415386; 
		putInteger: aDate offset hours
]

{ #category : #writing }
ODBEncodingStream >> nextPutDictionary: aDictionary [
	stream 
		putByte: ODBDictionaryCode;
		putPositiveInteger: aDictionary size.
	aDictionary keysAndValuesDo: [:key :value |
		key odbSerialize: readerWriter.
		value odbSerialize: readerWriter ]
]

{ #category : #writing }
ODBEncodingStream >> nextPutExternalReference: anObjectID [ 
	stream
		putByte: ODBExternalReferenceCode;
		putPositiveInteger: anObjectID
]

{ #category : #writing }
ODBEncodingStream >> nextPutFalse: aBoolean [ 
	stream putByte: ODBFalseCode
]

{ #category : #writing }
ODBEncodingStream >> nextPutFraction: aNumber [ 
	stream
		putByte: ODBFractionCode;
		putInteger: aNumber numerator;
		putInteger: aNumber denominator
]

{ #category : #writing }
ODBEncodingStream >> nextPutIdentityDictionary: anIdentityDictionary [ 
	stream 
		putByte: ODBIdentityDictionaryCode;
		putPositiveInteger: anIdentityDictionary size.
	anIdentityDictionary keysAndValuesDo: [:key :value |
		key odbSerialize: readerWriter.
		value odbSerialize: readerWriter ]
]

{ #category : #writing }
ODBEncodingStream >> nextPutInteger: anInteger [ 
	anInteger < 0 ifTrue: [
		anInteger > -4 ifTrue: [ ^ stream putByte: anInteger + 70 ].
		^ stream 
			putByte: ODBLargeNegativeIntegerCode ; 
			putPositiveInteger: 0 - anInteger.
	].
	anInteger < 17 ifTrue: [ 
		^ stream putByte: anInteger + ODBSmallPositiveIntegerBaseCode  ].
	stream 
		putByte: ODBLargePositiveIntegerCode; 
		putPositiveInteger: anInteger
]

{ #category : #writing }
ODBEncodingStream >> nextPutInternalReference: anInteger [ 
	stream
		putByte: ODBInternalReference;
		putPositiveInteger: anInteger
]

{ #category : #writing }
ODBEncodingStream >> nextPutMessage: aMessage [ 
 	stream putByte: ODBMessageCode.
	aMessage selector odbSerialize: readerWriter.
	aMessage arguments odbSerialize: readerWriter
]

{ #category : #writing }
ODBEncodingStream >> nextPutMessageSend: aMessageSend [ 
	stream putByte: ODBMessageSendCode.
	aMessageSend receiver odbSerialize: readerWriter.
	aMessageSend selector odbSerialize: readerWriter.
	aMessageSend arguments odbSerialize: readerWriter
]

{ #category : #writing }
ODBEncodingStream >> nextPutNil: anUndefinedObject [ 
	stream putByte: ODBUndefinedObjectCode
]

{ #category : #writing }
ODBEncodingStream >> nextPutOrderedCollection: aCollection [ 
	stream
		putByte: ODBOrderedCollectionCode;
		putPositiveInteger: aCollection size.
	aCollection do: [:each | each odbSerialize: readerWriter ].
]

{ #category : #writing }
ODBEncodingStream >> nextPutPersistentDictionary: aPersistentDictionary [
	stream
		putByte: ODBPersistentDictionaryCode;
		putPositiveInteger: aPersistentDictionary size.
	aPersistentDictionary keysAndValuesDo: [:key :value | 
		key odbSerialize: readerWriter.
		value odbSerialize: readerWriter ]
]

{ #category : #writing }
ODBEncodingStream >> nextPutProcessorScheduler: aProcessorScheduler [ 
	stream putByte: ODBProcessSchedulerCode
]

{ #category : #writing }
ODBEncodingStream >> nextPutSmallFloat64: aNumber [ 
	stream
		putByte: ODBSmallFloat64Code;
		putInteger: (aNumber at: 1);
		putInteger: (aNumber at: 2)
]

{ #category : #writing }
ODBEncodingStream >> nextPutString: aString [ 
		| buf |
	(buf := aString asByteArray) size < 10
		ifTrue: [
			^ stream
				putByte: ODBSmallStringBaseCode + buf size;
				putBytesFrom: buf len: buf size ].
	stream
		putByte: ODBStringCode;
		putPositiveInteger: buf size;
		putBytesFrom: buf len: buf size
]

{ #category : #writing }
ODBEncodingStream >> nextPutSymbol: aSymbol [ 
	stream
		putByte: ODBSymbolCode;
		putPositiveInteger: aSymbol size;
		putBytesFrom: aSymbol asByteArray len: aSymbol size
]

{ #category : #writing }
ODBEncodingStream >> nextPutSystemDictionary: aCollection [ 
	stream putByte: ODBSystemDictionaryCode
]

{ #category : #writing }
ODBEncodingStream >> nextPutTime: aTime [ 
	stream
		putByte: ODBTimeCode;
		putPositiveInteger: aTime asSeconds
]

{ #category : #writing }
ODBEncodingStream >> nextPutTransaction: aTransaction [ 
	stream putByte: ODBTransactionCode
]

{ #category : #writing }
ODBEncodingStream >> nextPutTrue: aBoolean [ 
	stream putByte: ODBTrueCode
]

{ #category : #writing }
ODBEncodingStream >> nextPutWideString: aWideString [
	| buf |
	buf := self class encodeString: aWideString.
	stream
		putByte: ODBWideStringCode;
		putPositiveInteger: buf size;
		putBytesFrom: buf len: buf size
]

{ #category : #reading }
ODBEncodingStream >> nextSmallFloat64: aDeserializer [ 
	"We multiply the Boxesfloat by 1, this way we create a SmallFloat if possible"
	^ BoxedFloat64 basicNew
		  at: 1 put: stream getInteger;
		  at: 2 put: stream getInteger;
		  * 1
]

{ #category : #actions }
ODBEncodingStream >> nextString [
	| buf len |
	buf := ByteArray new: (len := stream getPositiveInteger).
	stream getBytesFor: buf len: len.
	^ readerWriter register: buf asString.

]

{ #category : #reading }
ODBEncodingStream >> nextSymbol [
	| bytes len |
	bytes := ByteArray new: (len := stream getPositiveInteger).
	stream getBytesFor: bytes len: len.
	^ bytes asString asSymbol
]

{ #category : #reading }
ODBEncodingStream >> nextTime [
	^ readerWriter register: (Time fromSeconds: stream getPositiveInteger)
]

{ #category : #reading }
ODBEncodingStream >> nextWideString [
	| buf len |
	buf := ByteArray new: (len := stream getPositiveInteger).
	stream getBytesFor: buf len: len.
	^ readerWriter register: (self class decodeBytes: buf)
]

{ #category : #reading }
ODBEncodingStream >> nextnCharacterStringSize: size [
	    | buf |
   stream getBytesFor: (buf := ByteArray new: size) len: size.
    ^ readerWriter register: buf asString
]

{ #category : #reading }
ODBEncodingStream >> odbNextObject [
	^ (typeCodeMapping at: stream getByte) odbDeserialize: readerWriter 
]

{ #category : #accessing }
ODBEncodingStream >> position: anInteger [ 
	stream position: anInteger
]

{ #category : #accessing }
ODBEncodingStream >> primitive [
	^ stream
]

{ #category : #public }
ODBEncodingStream >> putBytesFrom: aByteCollection len: len [ 
	"Write len bytes from aByteCollection to file."

	stream putBytesFrom: aByteCollection len: len
]

{ #category : #accessing }
ODBEncodingStream >> readerWriter: anODBSerializer [ 
	readerWriter := anODBSerializer
]

{ #category : #public }
ODBEncodingStream >> size [
	^ stream size
]

{ #category : #accessing }
ODBEncodingStream >> stream: aStream [ 
	stream := aStream
]

{ #category : #accessing }
ODBEncodingStream >> truncate: anInteger [ 
	"Truncate stream so that its size will be anInteger. 
	Position to anInteger."

	stream truncate: anInteger
]

{ #category : #accessing }
ODBEncodingStream >> unlockAt: position length: length [

	^ stream unlockAt: position length: length
]
