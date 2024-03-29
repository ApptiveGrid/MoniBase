Class {
	#name : #ODBBTreeIdentityDictionary,
	#superclass : #ODBBTreeDictionary,
	#instVars : [
		'newKeys'
	],
	#category : #'OmniBase-Transaction'
}

{ #category : #public }
ODBBTreeIdentityDictionary >> at: aKey ifAbsent: aBlock [
	^ transaction
		  ifNil: [ newKeys at: aKey odbResolve ifAbsent: aBlock ]
		  ifNotNil: [ 
			  (transaction getObjectIDOrNil: aKey)
				  ifNil: [ newKeys at: aKey ifAbsent: aBlock ]
				  ifNotNil: [:oid| super at: oid ifAbsent: aBlock ] ]
]

{ #category : #public }
ODBBTreeIdentityDictionary >> at: aKey put: anObject ifLocked: aBlock [

	"Associate aKey with anObject.
	Evaluate aBlock if aKey has been locked before in some other transaction."

	^ transaction
		  ifNil: [ newKeys at: aKey odbResolve put: anObject ]
		  ifNotNil: [ 
			  (transaction getObjectIDOrNil: aKey)
				  ifNil: [ newKeys at: aKey put: anObject ]
				  ifNotNil: [ :oid | super at: oid put: anObject ifLocked: aBlock ] ]
]

{ #category : #private }
ODBBTreeIdentityDictionary >> bytesFromKey: anObjectID [ 
	^anObjectID contents
]

{ #category : #private }
ODBBTreeIdentityDictionary >> commit: serializer [ 
	"Object IDs have been allocated. Add associations."

	newKeys keysAndValuesDo: 
			[:eachKey :eachValue | 
			self addKey: (self bytesFromKey: (transaction getObjectID: eachKey)) value: eachValue].
	super commit: serializer
]

{ #category : #private }
ODBBTreeIdentityDictionary >> databaseObjectClass [
	^ODBDBBTreeIdentityDictionary
]

{ #category : #public }
ODBBTreeIdentityDictionary >> includesKey: aKey [

	^ transaction
		  ifNil: [ newKeys includesKey: aKey odbResolve ]
		  ifNotNil: [ 
			  (transaction getObjectIDOrNil: aKey)
				  ifNil: [ newKeys includesKey: aKey ]
				  ifNotNil: [ :oid | super includesKey: oid ] ]
]

{ #category : #initialization }
ODBBTreeIdentityDictionary >> initialize [
	super initialize.
	keySize := ODBObjectID sizeInBytes.
	newKeys := IdentityDictionary new
]

{ #category : #public }
ODBBTreeIdentityDictionary >> isChanged [
	^super isChanged or: [newKeys notEmpty]
]

{ #category : #public }
ODBBTreeIdentityDictionary >> isKeyLocked: aKey [ 
	"Answer <true> if aKey is locked."

	| oid |
	^(transaction isNil or: [(oid := transaction getObjectIDOrNil: aKey) isNil]) 
		ifTrue: [false]
		ifFalse: [super isKeyLocked: oid]
]

{ #category : #private }
ODBBTreeIdentityDictionary >> keyFromBytes: aByteArray [ 
	transaction referenceAt: (ODBObjectID new fromBytes: aByteArray at: 1)
]

{ #category : #public }
ODBBTreeIdentityDictionary >> keys [

	"Answer collection of all keys in the dictionary.
	NOTE: All objects will be loaded in one transaction at once.
	Do not use this method if there are a lot of objects in the dictionary since this could block your image for some time."

	| coll assoc |
	coll := OrderedCollection new: self size.
	coll addAll: newKeys keys.
	transaction ifNotNil: [ 
		assoc := self getFirst.
		[ assoc isNil ] whileFalse: [ 
			coll add:
				(transaction referenceAt:
					 (ODBObjectID new fromBytes: assoc key at: 1)).
			assoc := self getNext ] ].
	^ coll
]

{ #category : #public }
ODBBTreeIdentityDictionary >> keysFrom: key1 to: key2 do: aBlock [ 
	"Evaluate aBlock for each key in the given key range."

	self error: 'Invalid message for this class'
]

{ #category : #public }
ODBBTreeIdentityDictionary >> lockKey: aKey [ 
	"Lock key aKey so that other transactions wont be able
	to change it. Answer <true> if successfull."

	| oid |
	^(transaction isNil or: [(oid := transaction getObjectIDOrNil: aKey) isNil]) 
		ifTrue: [true]
		ifFalse: [super lockKey: oid]
]

{ #category : #private }
ODBBTreeIdentityDictionary >> objectCommitted [
	"Changes have been committed, update object."

	super objectCommitted.
	newKeys := IdentityDictionary new
]

{ #category : #private }
ODBBTreeIdentityDictionary >> objectStored [

	"Sent to transaction object when it is stored for the first time.
	Remove all persistent objects which were put into dictionary before itself was persistent."

	super objectStored.
	newKeys copy keysAndValuesDo: [ :eachKey :eachValue | 
		(transaction getObjectIDOrNil: eachKey) ifNotNil: [ :oid | 
			super at: oid put: eachValue ifLocked: [ ODBCannotLockKey signal ].
			newKeys removeKey: eachKey ] ]
]

{ #category : #private }
ODBBTreeIdentityDictionary >> odbAboutToCommitIn: anOmniBaseTransaction [ 
	"Sent before transaction writes changes to the database (right before commit).
	In this method you can use transaction the same way as usual."

	| container |
	container := holder container.
	newKeys keysAndValuesDo: 
			[:eachKey :eachValue | 
			transaction
				makePersistent: eachKey in: container;
				makePersistent: eachValue in: container]
]

{ #category : #public }
ODBBTreeIdentityDictionary >> removeKey: aKey ifLocked: aBlock [

	^ transaction
		  ifNil: [ newKeys removeKey: aKey odbResolve ifAbsent: nil ]
		  ifNotNil: [ 
			  (transaction getObjectIDOrNil: aKey)
				  ifNil: [ newKeys removeKey: aKey ifAbsent: nil ]
				  ifNotNil: [:oid |super removeKey: oid ifLocked: aBlock ] ]
]

{ #category : #public }
ODBBTreeIdentityDictionary >> size [
	^super size + newKeys size
]

{ #category : #public }
ODBBTreeIdentityDictionary >> unlockKey: aKey [ 
	"Unlocks key aKey. Answer <true> if successfull."

	| oid |
	^(transaction isNil or: [(oid := transaction getObjectIDOrNil: aKey) isNil]) 
		ifTrue: [true]
		ifFalse: [super unlockKey: oid]
]

{ #category : #public }
ODBBTreeIdentityDictionary >> values [
	^newKeys values , super values
]
