Class {
	#name : #ODBLockRegistry,
	#superclass : #Object,
	#instVars : [
		'path',
		'locks'
	],
	#classInstVars : [
		'registries'
	],
	#category : #'OmniBase-Base'
}

{ #category : #'as yet unclassified' }
ODBLockRegistry class >> forPath: aString [ 
	| path |
	path := aString asFileReference asAbsolute.
	^ registries 
		at: path 
		ifAbsentPut: [ 
			self new path: path  ] 
]

{ #category : #initialization }
ODBLockRegistry class >> initialize [ 
	registries := WeakValueDictionary new
]

{ #category : #'as yet unclassified' }
ODBLockRegistry class >> registeredPaths [
	^ self registries keys
]

{ #category : #accessing }
ODBLockRegistry class >> registries [ 
	^ registries 
]

{ #category : #'as yet unclassified' }
ODBLockRegistry class >> remove: aRegistry [ 
	^ registries 
		removeKey: aRegistry path 
		ifAbsent: [ ] 
]

{ #category : #'as yet unclassified' }
ODBLockRegistry class >> removePath: aString [ 
	^ registries removeKey: aString 
	
]

{ #category : #initialization }
ODBLockRegistry class >> reset [ 
	registries := Dictionary new
]

{ #category : #adding }
ODBLockRegistry >> addLock: aKeyLock [ 
	^ self 
		lockAt: aKeyLock lockRegistryKey 
		put: aKeyLock 
]

{ #category : #'as yet unclassified' }
ODBLockRegistry >> checkRemoval [
	locks isEmpty ifTrue: [ 
		self remove ]
]

{ #category : #testing }
ODBLockRegistry >> hasForeignLockFor: aTransactionObject transaction: aTransaction [
	"test if there is a lock that is present and that belongs to aTransaction"
	^ locks 
		at: aTransactionObject lockRegistryKey 
		ifPresent: [ :lock | (lock transaction = aTransaction) not  ]
		ifAbsent: [ false ]
]

{ #category : #testing }
ODBLockRegistry >> hasKeyLockOn: aBtreeDictionary key: key [ 
	^ locks includesKey: (aBtreeDictionary lockRegistryKeyAt: key)
]

{ #category : #initialization }
ODBLockRegistry >> initialize [ 
	super initialize.
	locks := Dictionary new
]

{ #category : #testing }
ODBLockRegistry >> isEmpty [
	^ locks isEmpty
]

{ #category : #testing }
ODBLockRegistry >> keyLockOn: aBtreeDictionary key: key ifAbsent: aBlock [
	^ locks 
		at: (aBtreeDictionary lockRegistryKeyAt: key) 
		ifAbsent: aBlock
]

{ #category : #adding }
ODBLockRegistry >> lockAt: key put: aLock [ 
	locks 
		at: key
		ifPresent: [ :lock |
			^ lock isSameTransaction: aLock transaction ].
	locks 
		at: key 
		put: aLock.
	^ true
]

{ #category : #'as yet unclassified' }
ODBLockRegistry >> locksWithTransaction: aTransaction [ 
	^ locks values 
		select: [ :lock | lock transaction = aTransaction ]
]

{ #category : #accessing }
ODBLockRegistry >> path [

	^ path
]

{ #category : #accessing }
ODBLockRegistry >> path: aFileReference [ 
	path := aFileReference 
]

{ #category : #removing }
ODBLockRegistry >> remove [
	self class remove: self
]

{ #category : #removing }
ODBLockRegistry >> removeLock: anODBObjectLock [ 
	locks 
		removeKey: anODBObjectLock lockRegistryKey 
		ifAbsent: [  ].
	self checkRemoval 
]

{ #category : #initialization }
ODBLockRegistry >> reset [
	locks removeAll
]

{ #category : #accessing }
ODBLockRegistry >> size [ 
	^ locks size
]
