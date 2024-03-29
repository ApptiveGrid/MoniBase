Class {
	#name : #ODBBTreeDictionary,
	#superclass : #ODBBTreeIndexDictionary,
	#instVars : [
		'initialSize',
		'deltaSize'
	],
	#category : #'OmniBase-Transaction'
}

{ #category : #private }
ODBBTreeDictionary >> addKey: key value: anObject [

	"Private - Add association to dictionary of changed associations."

	| value |
	(value := self valueAt: key) isRemoved
		ifTrue: [ deltaSize := deltaSize + 1 ]
		ifFalse: [ 
			transaction ifNotNil: [ "if the object is identical, do not save it again"
				(transaction getObjectIDOrNil: anObject) = value objectID ifTrue: [ 
					^ anObject ] ] ].
	value object: anObject.
	changed ifNil: [ changed := self newChangedDictionary ].
	changed at: key put: value.
	^ anObject
]

{ #category : #public }
ODBBTreeDictionary >> at: aKey put: anObject [ 
	"Associate aKey with anObject.
	aKey can be any object which implements method #asBtreeKeyOfSize:
	Trigger an exception if aKey has already been locked or changed in a concurrently running transaction."

	^self 
		at: aKey
		put: anObject
		ifLocked: [ODBCannotLockKey signal]
]

{ #category : #public }
ODBBTreeDictionary >> at: aKey put: anObject ifLocked: aBlock [

	"Associate aKey with anObject.
	Evaluate aBlock if aKey has been locked before in some other transaction."

	| key |
	key := self bytesFromKey: aKey.
	(self basicLockKey: key) ifFalse: [ ^ aBlock value ].
	transaction ifNotNil: [ 
		transaction makePersistent: anObject in: holder container ].
	^ self addKey: key value: anObject
]

{ #category : #private }
ODBBTreeDictionary >> basicLockKey: key [

	"Private - Lock key so that other transactions wont be able
	to change it. Answer <true> if successfull."

	| lock lockID value |
	dataBaseObject ifNil: [ ^ true ].
	(lockID := transaction lockID) ifNil: [ ^ false ].
	transaction isGlobalLocked ifTrue: [ ^ true ].
	"Does the registry contain a lock for this dictionary and key?"
	lock := transaction keyLockOn: self key: key ifAbsent: [ nil ].
	"A present lock is either inside the current transaction which makes
	it succeed or it is part of another transaction which indicates a
	locking conflict"
	lock ifNotNil: [ ^ lock isSameTransaction: transaction ].
	lock := ODBKeyLock new
		        objectID: holder objectID;
		        lockID: lockID;
		        key: key.
	value := self valueAt: key.
	dataBaseObject iterator critical: [ 
		(transaction addLoggedLock: lock) ifFalse: [ ^ false ].
		(dataBaseObject iterator
			 goTo: key;
			 lockCurrentValue: value contents with: lockID) ifFalse: [ 
			transaction removeLoggedLock: lock.
			^ false ] ].
	^ true
]

{ #category : #private }
ODBBTreeDictionary >> commitChanged [

	"Private - Commit changes on an already existing dictionary."

	| changesPackage newValue vn oldHolders |
	changesPackage := transaction changesPackage.
	changesPackage add:
		(ODBDictionaryChanged new transactionObject: self).
	deltaSize = 0 ifFalse: [ 
		changesPackage add: (ODBSizeChanged new
				 setObjectID: holder objectID transactionObject: self;
				 deltaSize: deltaSize) ].
	vn := transaction versionNumber.
	oldHolders := transaction oldHolders.
	changed ifNotNil: [ 
		changed keysAndValuesDo: [ :key :oldValue | 
			newValue := oldValue makeNewVersion: oldHolders.
			newValue versionNumber: vn.
			oldValue isRemoved ifFalse: [ 
				newValue objectID: (transaction getObjectID: newValue object) ].
			changesPackage add: (ODBAssociationChanged new
					 key: key;
					 setObjectID: holder objectID transactionObject: self;
					 oldValue: oldValue;
					 newValue: newValue) ] ]
]

{ #category : #private }
ODBBTreeDictionary >> commitNew [

	"Private - Commit changes when new database object needs to be created."

	| newHolder newDBObject vn |
	vn := transaction versionNumber.
	newHolder := (holder makeNewVersion: transaction oldHolders)
		             persistentClassID: self databaseObjectClass classID;
		             versionNumber: vn.
	newDBObject := self databaseObjectClass new
		               createOn: newHolder
		               keySize: keySize.
	changed ifNotNil: [ 
		changed keysAndValuesDo: [ :key :value | 
			value isRemoved ifFalse: [ 
				value
					objectID: (transaction getObjectID: value object);
					versionNumber: vn.
				newDBObject at: key put: value ] ] ].
	newDBObject iterator
		updateSizeAt: vn
		oldHolders: nil
		deltaSize: deltaSize.
	transaction changesPackage
		add: (ODBNewObjectVersion new
				 setObjectID: holder objectID transactionObject: self;
				 oldVersion: holder;
				 newVersion: newHolder);
		add: (ODBDictionaryChanged new
				 transactionObject: self;
				 dataBaseObject: newDBObject)
]

{ #category : #private }
ODBBTreeDictionary >> databaseObjectClass [
	^ODBDBBTreeDictionary
]

{ #category : #initialization }
ODBBTreeDictionary >> initialize [

    super initialize.
    initialSize := 0.
    deltaSize := 0
]

{ #category : #public }
ODBBTreeDictionary >> isEmpty [
	^self size = 0
]

{ #category : #public }
ODBBTreeDictionary >> isKeyLocked: aKey [

	"Answer <true> if aKey is locked."

	| key result |
	dataBaseObject ifNil: [ ^ false ].
	transaction isGlobalLocked ifTrue: [ ^ false ].
	key := self bytesFromKey: aKey.
	dataBaseObject iterator critical: [ 
		result := (self hasLockAt: aKey) or: [ 
			          dataBaseObject iterator
				          goTo: key;
				          isLocked ] ].
	^ result
]

{ #category : #public }
ODBBTreeDictionary >> lockKey: aKey [ 
	"Lock key aKey so that other transactions wont be able
	to change it. Answer <true> if successfull."

	^self basicLockKey: (self bytesFromKey: aKey)
]

{ #category : #private }
ODBBTreeDictionary >> objectCommitted [
	"Changes have been committed, update object."

	changed := nil.
	initialSize := initialSize + deltaSize.
	deltaSize := 0
]

{ #category : #private }
ODBBTreeDictionary >> objectLoaded [
	"Sent to transaction object when it is loaded into transaction."

	initialSize := dataBaseObject iterator getSizeAt: transaction versionDescriptor
				oldHolders: transaction oldHolders
]

{ #category : #private }
ODBBTreeDictionary >> objectStored [
	"Sent to transaction object when it is stored for the first time."
	
	changed ifNotNil: [ 
		| container |
		container := holder container.
		changed do: [ :eachValue | 
			eachValue isRemoved ifFalse: [ 
				transaction makePersistent: eachValue object in: container ] ] ]
]

{ #category : #public }
ODBBTreeDictionary >> removeKey: aKey [ 
	^self removeKey: aKey ifLocked: [ODBCannotLockKey signal]
]

{ #category : #public }
ODBBTreeDictionary >> removeKey: aKey ifLocked: aBlock [

	| key value |
	key := self bytesFromKey: aKey.
	(self basicLockKey: key) ifFalse: [ ^ aBlock value ].
	value := self valueAt: key ifAbsent: [ ^ nil ].
	value isRemoved ifTrue: [ ^ self ].
	
	value removed.
	changed ifNil: [ changed := self newChangedDictionary ].
	changed at: key put: value.
	deltaSize := deltaSize - 1
]

{ #category : #public }
ODBBTreeDictionary >> size [
	"Answer number of keys in receiver.
	(metodo je treba spremeniti, ce so reference na objekte iz 
	transakcije weak -> sizeHolder mora biti iz verzije pred startom transakcije)"

	^initialSize + deltaSize
]

{ #category : #public }
ODBBTreeDictionary >> unlockKey: aKey [

	"Unlocks key aKey. Answer <true> if successfull."

	| lock key |
	dataBaseObject ifNil: [ ^ true ].
	key := self bytesFromKey: aKey.
	changed ifNotNil: [ (changed includes: key) ifTrue: [ ^ false ] ].
	transaction hasLocks ifFalse: [ ^ transaction isGlobalLocked ].
	lock := transaction keyLockOn: self key: key ifAbsent: [ ^ false ].
	(dataBaseObject unlockKey: key with: lock lockID) ifFalse: [ ^ false ].
	transaction removeLoggedLock: lock.
	^ true
]
