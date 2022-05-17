Class {
	#name : #ODBDeserializer,
	#superclass : #Object,
	#instVars : [
		'classes',
		'classesCounter',
		'classManager',
		'counter',
		'objects',
		'stream',
		'referenceManager',
		'transaction'
	],
	#category : #'OmniBase-Serializers'
}

{ #category : #public }
ODBDeserializer class >> deserializeFromBytes: aByteArray [ 
	| memoryStream classManager |
	memoryStream := ODBMemoryStreamWrapper on: aByteArray readStream.
	memoryStream getPositiveInteger = 0 
		ifFalse: [self error: 'External references not defined'].
	classManager := ODBClassManagerForSerialization new.
	classManager loadFromStream: memoryStream.
	^self new 
		deserializeFrom:  (ODBEncodingStream on: memoryStream)
		referenceManager: nil
		classManager: classManager
]

{ #category : #public }
ODBDeserializer class >> deserializeFromBytes: aByteArray externalReferencesLoaderBlock: aBlock [ 
	| memoryStream referenceManager classManager |
	memoryStream := ODBMemoryStreamWrapper on: aByteArray readStream.
	referenceManager := ODBReferenceManager new.
	referenceManager loadFromStream: memoryStream externalReferencesLoaderBlock: aBlock.
	classManager := ODBClassManagerForSerialization new.
	classManager loadFromStream: memoryStream.
	^self new 
		deserializeFrom: memoryStream
		referenceManager: referenceManager
		classManager: classManager
]

{ #category : #public }
ODBDeserializer >> deserializeFrom: aStream referenceManager: aReferenceManager classManager: aClassManager [ 
	stream := aStream readerWriter: self.
	referenceManager := aReferenceManager.
	classManager := aClassManager.
	objects := Array new: stream primitive getLong.
	classes := OrderedCollection new: 30.
	counter := 0.
	classesCounter := 0.
	^ stream odbNextObject: self
]

{ #category : #public }
ODBDeserializer >> deserializeFrom: aStream
	referenceManager: aReferenceManager
	transaction: aTransaction [

	stream := aStream readerWriter: self.
	referenceManager := aReferenceManager.
	classManager := aTransaction environment classManager.
	transaction := aTransaction.
	objects := Array new: stream primitive getLong.
	classes := OrderedCollection new: 30.
	counter := 0.
	classesCounter := 0.
	^ stream odbNextObject: self
]

{ #category : #private }
ODBDeserializer >> existingObject [

	^ objects at: stream primitive getPositiveInteger
]

{ #category : #private }
ODBDeserializer >> loadError [
	| id |
	stream primitive position: stream primitive position - 1.
	id := stream primitive getByte.
	OmniBase 
		signalError: 'OmniBase deserializer: Unknown serialization id (' , id printString , ')'
]

{ #category : #private }
ODBDeserializer >> loadReference [

	^self register: (referenceManager referenceAt: stream primitive getPositiveInteger)
]

{ #category : #private }
ODBDeserializer >> newObjectNewClass [
	| classInfo |
	classInfo := classManager classDescriptionAt: stream primitive getPositiveInteger.
	classesCounter := classesCounter + 1.
	classes add: classInfo.
	^classInfo realClass odbLoadVariables: self classInfo: classInfo
]

{ #category : #private }
ODBDeserializer >> newObjectOldClass [

	| classInfo |
	^(classInfo := classes at: stream primitive getPositiveInteger) realClass
		odbLoadVariables: self
		classInfo: classInfo
]

{ #category : #private }
ODBDeserializer >> odbNextObject [

	^ stream odbNextObject: self
]

{ #category : #private }
ODBDeserializer >> register: anObject [

	^objects at: (counter := counter + 1) put: anObject
]

{ #category : #public }
ODBDeserializer >> stream [

	^stream
]

{ #category : #private }
ODBDeserializer >> transaction [

	^transaction
]
