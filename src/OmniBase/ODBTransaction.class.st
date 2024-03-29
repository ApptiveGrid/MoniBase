Class {
	#name : #ODBTransaction,
	#superclass : #Object,
	#instVars : [
		'cacheMutex',
		'client',
		'dbConnection',
		'objectIndex',
		'objects',
		'transactionFile',
		'transactionManager',
		'versionDescriptor',
		'lockRegistry',
		'locks'
	],
	#category : #'OmniBase-Transaction'
}

{ #category : #private }
ODBTransaction class >> odbDeserialize: deserializer [

	^ deserializer transaction
]

{ #category : #public }
ODBTransaction >> abort [

	"Abort transaction. After aborting it, it can not be used anymore."

	transactionManager ifNotNil: [ 
		transactionManager critical: [ self basicAbort ] ].

	self triggerEvent: #finishedTransaction: with: self
]

{ #category : #public }
ODBTransaction >> basicAbort [

	"Private - Abort transaction. After aborting it, it can not be used anymore."

	| changes |
	dbConnection ifNotNil: [ 
		locks ifNotEmpty: [ 
			(changes := transactionFile recovery) ifNotNil: [ 
				changes
					transaction: self;
					rollback.
				transactionFile recovery: nil ].
			locks do: [ :each | 
				each unlock.
				lockRegistry removeLock: each ] ].
		transactionManager transactionAborted: self.
		client transactionRemove: self ].
	objects := nil.
	client := nil.
	dbConnection := nil.
	transactionManager := nil.

	objectIndex := nil.
	cacheMutex ifNotNil: [ 
		cacheMutex terminateProcess.
		cacheMutex := nil ]
]

{ #category : #public }
ODBTransaction >> cachedObjectAt: objectID [ 
	"Answer object identified by the given objectID.
	Answer <nil> if the object is not found in the local transaction cache.
	This method will not load the object from the disk drive."

	| transactionObject |
	^(objects isNil 
		or: [(transactionObject := self cachedTransactionObjectAt: objectID) isNil]) 
			ifFalse: [transactionObject value]
]

{ #category : #private }
ODBTransaction >> cachedTransactionObjectAt: objectID [ 
	"Private - Answer cached transaction object at objectID."

	^cacheMutex critical: [objects at: objectID].
]

{ #category : #'public/accessing' }
ODBTransaction >> client [

    ^client
]

{ #category : #public }
ODBTransaction >> environment [
	^dbConnection
]

{ #category : #public }
ODBTransaction >> freshObjectAt: objectID [

	"Answers a recently read object fount at objectID, <nil> if it does not exist."

	| transactionObject |
	objects ifNil: [ 
		OmniBase signalError: 'Transaction was already aborted' ].
	objectID containerID == 0 ifTrue: [ 
		^ self transactionReferenceAt: objectID index ].

	^ (transactionObject := self freshTransactionObjectAt: objectID) 
		  ifNotNil: [ transactionObject value ]
]

{ #category : #public }
ODBTransaction >> freshTransactionObjectAt: objectID [

	"Private - Answer transaction object at objectID
	that is guaranteed to be recently read, as opposed to a cached version."

	| holder transactionObject t2 |
	cacheMutex ifNil: [ ^ ODBExpiredProxyObject on: objectID ].
	(holder := dbConnection objectManager holderAt: objectID) ifNil: [ "OID (1:1) = nil"
		^ transactionObject := (objectID index = 1 and: [ 
			                        objectID containerID = 1 ]) ifFalse: [ 
			                       OmniBase signalError: 'Invalid object ID' ] ].
	[ versionDescriptor versionOK: holder versionNumber ] whileFalse: [ 
		holder loadPreviousVersionFrom: self oldHolders ].
	[ transactionObject := holder getObject makeTransactionObject: self ] 
		ifCurtailed: [ self becomeInconsistent ].

	cacheMutex critical: [ 
		(t2 := objects at: objectID) ifNil: [ 
			objects at: objectID put: transactionObject.
			objectIndex at: transactionObject value put: transactionObject ] ].
	^ t2 ifNil: [ transactionObject objectLoaded ] ifNotNil: [ t2 ]
]

{ #category : #public }
ODBTransaction >> getLoadedObjects [
	"Answer collection of associations of all objects loaded in current transaction."

	| coll |
	coll := OrderedCollection new.
	objectIndex do: [:each | each objectID containerID > 0 ifTrue: [coll add: each value]].
	^coll
]

{ #category : #public }
ODBTransaction >> getObjectID: anObject [

	"Answer <objectID> coresponding to anObject."

	| transactionObject oid |
	anObject odbObjectID ifNotNil: [ ^ anObject odbObjectID ].
	cacheMutex critical: [ transactionObject := objectIndex at: anObject ].
	transactionObject ifNil: [ 
		OmniBase signalError:
			'Object is not persistent or is contained in another persistent object' ].
	(oid := transactionObject objectID) index == 0 ifTrue: [ 
		OmniBase signalError:
			'Object ID is not allocated yet. Object ID will be allocated after transaction checkpoint or commit.' ].
	^ oid
]

{ #category : #public }
ODBTransaction >> getObjectIDOrNil: anObject [

	"Private - Answer <objectID> coresponding to anObject 
        or <nil> if not allready stored."

	| transactionObject oid |
	anObject odbObjectID ifNotNil: [ ^ anObject odbObjectID ].

	self isAborted ifTrue: [ ^ nil ].

	cacheMutex critical: [ transactionObject := objectIndex at: anObject ].
	^ transactionObject ifNotNil: [ 
		  (oid := transactionObject objectID) index == 0 ifFalse: [ oid ] ]
]

{ #category : #private }
ODBTransaction >> getTransactionObject: anObject ifAbsent: aBlock [

	"Private - Answer transaction object corresponding to anObject.
	Evaluate aBlock if none."

	| transactionObject |
	anObject isODBReference ifTrue: [ 
		anObject odbTransaction == self ifFalse: [ 
			OmniBase signalError: 'Reference from another transaction' ].
		^ anObject odbTransactionObject ].
	cacheMutex critical: [ transactionObject := objectIndex at: anObject ].
	^ transactionObject
		  ifNil: [ aBlock value ]
		  ifNotNil: [ transactionObject ]
]

{ #category : #initialization }
ODBTransaction >> initialize [
	cacheMutex := Semaphore forMutualExclusion.
	objects := ODBObjectIDDictionary new.
	objectIndex := ODBIdentityDictionary new
]

{ #category : #public }
ODBTransaction >> isAborted [

	^ objectIndex isNil and:[
	objects isNil and:[
	client isNil and:[
	dbConnection isNil and:[
	transactionManager isNil and:[
	cacheMutex isNil]]]]]
]

{ #category : #public }
ODBTransaction >> isChanged [
	"Answer <true> if changes were made to the database."

	^false
]

{ #category : #public }
ODBTransaction >> isGlobalLocked [
	"Answer <true> if transaction was started in 
	a global locked database session."

	^false
]

{ #category : #'public/accessing' }
ODBTransaction >> isReadOnly [
		"Answer <true> if this is a read-only transaction."

	^false
]

{ #category : #accessing }
ODBTransaction >> locks [
	^ locks
]

{ #category : #public }
ODBTransaction >> objectAt: objectID [

	"Answer object at objectID, <nil> if it does not exist."

	| transactionObject |
	objects ifNil: [ 
		OmniBase signalError: 'Transaction was already aborted' ].
	objectID containerID == 0 ifTrue: [ 
		^ self transactionReferenceAt: objectID index ].
	^ (transactionObject := self transactionObjectAt: objectID) 
		  ifNotNil: [ transactionObject value ]
]

{ #category : #private }
ODBTransaction >> objectHolderAt: objectID [

	"Private - Answer object holder at objectID."

	^ (self cachedTransactionObjectAt: objectID)
		  ifNil: [ dbConnection objectManager holderAt: objectID ]
		  ifNotNil: [ :trObj | trObj objectHolder ]
]

{ #category : #'private/unclassified' }
ODBTransaction >> odbBasicSerialize: serializer [

	serializer stream nextPutTransaction: self
]

{ #category : #'private/unclassified' }
ODBTransaction >> odbObjectID [

    ^ODBObjectID containerID: 0 index: 1000
]

{ #category : #'private/unclassified' }
ODBTransaction >> odbSerialize: serializer [
	self flag: #TODO. "Explain why we do not need to register?"
	self odbBasicSerialize: serializer
]

{ #category : #'private/accessing' }
ODBTransaction >> oldHolders [
        "Private - Answer file used to store old holder versions."

    ^transactionManager oldHolders
]

{ #category : #private }
ODBTransaction >> referenceAt: objectID [

	"Private - Answer reference at objectID. If object is already loaded, answer its value."

	| refObj |
	objectID containerID == 0 ifTrue: [ 
		^ self transactionReferenceAt: objectID index ].
	(refObj := self cachedTransactionObjectAt: objectID) ifNotNil: [ 
		^ refObj value ].
	refObj := ODBReference new.
	^ refObj odbSetLoader: (ODBDemandLoader new
			   setTransaction: self
			   objectID: objectID
			   proxyObject: refObj)
]

{ #category : #public }
ODBTransaction >> root [

	"Answer the database root object. Root object represents an entry point into the database.
	Only objects that are being referenced from the root object will remain after the garbage
	collection on the database."

	^ (self objectAt: (ODBObjectID containerID: 1 index: 1)) ifNotNil: [ 
		  :rootObjectHolder | rootObjectHolder rootObject ]
]

{ #category : #private }
ODBTransaction >> setClient: aClient environment: anOmniBase [ 
	client := aClient.
	dbConnection := anOmniBase.
	transactionManager := dbConnection transactionManager.
	lockRegistry := dbConnection lockRegistry
]

{ #category : #'private/accessing' }
ODBTransaction >> transactionFile [

    ^transactionFile
]

{ #category : #private }
ODBTransaction >> transactionObjectAt: objectID [

	"Private - Answer transaction object at objectID."

	| holder transactionObject t2 |
	cacheMutex ifNil: [ ^ ODBExpiredProxyObject on: objectID ].
	cacheMutex critical: [ transactionObject := objects at: objectID ].
	transactionObject ifNotNil: [ ^ transactionObject ].
	(holder := dbConnection objectManager holderAt: objectID) ifNil: [ "OID (1:1) = nil"
		^ transactionObject := (objectID index = 1 and: [ 
			                        objectID containerID = 1 ]) ifFalse: [ 
			                       OmniBase signalError: 'Invalid object ID' ] ].
	[ versionDescriptor versionOK: holder versionNumber ] whileFalse: [ 
		holder loadPreviousVersionFrom: self oldHolders ].
	[ transactionObject := holder getObject makeTransactionObject: self ] 
		ifCurtailed: [ self becomeInconsistent ].
	cacheMutex critical: [ 
		(t2 := objects at: objectID) ifNil: [ 
			objects at: objectID put: transactionObject.
			objectIndex at: transactionObject value put: transactionObject ] ].
	^ t2 ifNil: [ transactionObject objectLoaded ] ifNotNil: [ t2 ]
]

{ #category : #private }
ODBTransaction >> transactionReferenceAt: objectIDindex [ 
	"Private - Answer object at objectID index."

	objectIDindex == 1000 ifTrue: [^self].
	^transactionManager transactionReferenceAt: objectIDindex
]

{ #category : #private }
ODBTransaction >> transactionReferences [
	"Private - Answer collection of transaction dependent 
	objects and their object IDs (starting with 1000)."

	^(OrderedCollection new: 512)
		add: (Association key: self value: self odbObjectID);
		add: (Association key: dbConnection value: dbConnection odbObjectID);
		yourself
]

{ #category : #'public/accessing' }
ODBTransaction >> versionDescriptor [

    ^versionDescriptor
]

{ #category : #private }
ODBTransaction >> versionDescriptor: aVersionDescriptor [ 
	versionDescriptor := aVersionDescriptor
]

{ #category : #'public/accessing' }
ODBTransaction >> versionNumber [

    ^versionDescriptor versionNumber
]
