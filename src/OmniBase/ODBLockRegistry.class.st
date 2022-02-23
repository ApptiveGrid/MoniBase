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
	^ registries removeKey: aRegistry path 
	
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
ODBLockRegistry >> addLock: anODBObjectLock [ 
	locks 
		at: anODBObjectLock objectID 
		put: anODBObjectLock 
]

{ #category : #'as yet unclassified' }
ODBLockRegistry >> checkRemoval [
	locks isEmpty ifTrue: [ 
		self remove ]
]

{ #category : #testing }
ODBLockRegistry >> hasLockFor: anODBObjectID [ 
	^ locks includesKey: anODBObjectID 
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

{ #category : #accessing }
ODBLockRegistry >> locks [
	^ locks
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
		removeKey: anODBObjectLock objectID 
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
