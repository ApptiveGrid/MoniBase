Class {
	#name : #ODBMemoryStreamWrapper,
	#superclass : #ODBPrimitiveEncodingStream,
	#category : #'OmniBase-Streams'
}

{ #category : #writing }
ODBMemoryStreamWrapper class >> write [
	^ self on: (WriteStream on: ByteArray new)
]

{ #category : #converting }
ODBMemoryStreamWrapper >> asByteArray [
	^ stream contents copy
]

{ #category : #public }
ODBMemoryStreamWrapper >> createOn: aByteArray [
	stream := aByteArray readStream
]

{ #category : #public }
ODBMemoryStreamWrapper >> getLong [

    ^self getWord bitOr: (self getWord bitShift: 16)
]

{ #category : #public }
ODBMemoryStreamWrapper >> getWord [

    ^self getByte bitOr: (self getByte bitShift: 8)
]

{ #category : #public }
ODBMemoryStreamWrapper >> putByte: anInteger [

    stream nextPut: anInteger
]

{ #category : #public }
ODBMemoryStreamWrapper >> putBytesFrom: aByteCollection len: len [
	stream next: len putAll: aByteCollection startingAt: 1
]

{ #category : #public }
ODBMemoryStreamWrapper >> putLong: anInteger [

    self 
		putWord: (anInteger bitAnd: 65535); 
		putWord: (anInteger bitShift: -16)
]

{ #category : #public }
ODBMemoryStreamWrapper >> putWord: anInteger [

	self 
		putByte: (anInteger bitAnd: 255); 
		putByte: (anInteger bitShift: -8)
]

{ #category : #writing }
ODBMemoryStreamWrapper >> writeOn: aStream [
	aStream putLong: self size.
	aStream putBytesFrom: stream contents
]
