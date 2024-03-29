Class {
	#name : #ODBPrimitiveEncodingStream,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'OmniBase-Streams'
}

{ #category : #testing }
ODBPrimitiveEncodingStream class >> isAbstract [
		
	^ self == ODBPrimitiveEncodingStream
]

{ #category : #'instance creation' }
ODBPrimitiveEncodingStream class >> on: aFileStream [ 
	^ self new 
		stream: aFileStream
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> atEnd [ 
	^ stream atEnd
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> flush [
	stream flush
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getBoolean [

    ^ self  getByte = 1
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getByte [
	^ stream next
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getBytesFor: aByteCollection [

    ^ self getBytesFor: aByteCollection len: aByteCollection size
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getBytesFor: aByteCollection len: len [ 
	"Read len bytes from stream to aByteCollection. Answer number of bytes actualy read."

	^ stream readInto: aByteCollection startingAt: 1 count: len
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getChar [

    ^ Character value: self getByte
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getInteger [
	"Answer the next Integer encoded in the receiver."

	| int |
	((int := self getPositiveInteger) bitAnd: 1) == 0 ifTrue: [^int bitShift: -1].
	^0 - (int bitShift: -1)
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> getLong [
	^ self subclassResponsibility
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getPositiveInteger [
	"Answer the next Integer encoded in the receiver."

	| answer |
	(answer := self getByte) < 128 ifTrue: [^answer].
	^(self getPositiveInteger bitShift: 7) bitOr: (answer bitAnd: 127)
]

{ #category : #public }
ODBPrimitiveEncodingStream >> getString [

	| size bytes |
	^(size := self getPositiveInteger) = 0
		ifTrue: [String new]
		ifFalse: [
			bytes := ByteArray new: size.
			self getBytesFor: bytes len: size.
			bytes asString ]
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> getWord [
	^ self subclassResponsibility
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> position [
	^ stream position
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> position: anInteger [ 
	stream position: anInteger
]

{ #category : #public }
ODBPrimitiveEncodingStream >> putBoolean: aBool [

    self putByte: (aBool ifTrue: [ 1] ifFalse: [0])
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> putByte: anInteger [ 
	^ self subclassResponsibility
]

{ #category : #public }
ODBPrimitiveEncodingStream >> putBytesFrom: aByteCollection [

    ^ self putBytesFrom: aByteCollection len: aByteCollection size
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> putBytesFrom: aByteCollection len: len [ 
	^ self subclassResponsibility
]

{ #category : #public }
ODBPrimitiveEncodingStream >> putChar: aCharacter [

	self putByte: aCharacter asInteger
]

{ #category : #public }
ODBPrimitiveEncodingStream >> putInteger: anInteger [ 
	anInteger < 0 ifTrue: [^self putPositiveInteger: (0 - anInteger bitShift: 1) + 1].
	self putPositiveInteger: (anInteger bitShift: 1)
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> putLong: anInteger [ 
	^ self subclassResponsibility
]

{ #category : #public }
ODBPrimitiveEncodingStream >> putPositiveInteger: anInteger [ 
	anInteger < 128 ifTrue: [^self putByte: anInteger].
	self
		putByte: ((anInteger bitAnd: 127) bitOr: 128);
		putPositiveInteger: (anInteger bitShift: -7)
]

{ #category : #public }
ODBPrimitiveEncodingStream >> putString: aString [

	self putPositiveInteger: aString basicSize.
	aString basicSize > 0 ifTrue: [ self putBytesFrom: aString asByteArray len: aString basicSize ]
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> putWord: anInteger [ 
	^ self subclassResponsibility
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> size [ 
	^ stream size
]

{ #category : #accessing }
ODBPrimitiveEncodingStream >> stream: aCollection [ 
	stream := aCollection 
]
