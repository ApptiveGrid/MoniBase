Class {
	#name : #ODBLock,
	#superclass : #Object,
	#instVars : [
		'transaction',
		'lockIndex',
		'objectID',
		'lockID'
	],
	#category : #'OmniBase-Transaction'
}

{ #category : #testing }
ODBLock class >> isAbstract [
		
	^ self == ODBLock
]

{ #category : #public }
ODBLock class >> lockClassID [
	"Answer unique class ID used for storing locks or <nil> if lock does not need to be stored."

	self subclassResponsibility
]

{ #category : #testing }
ODBLock >> isSameTransaction: anODBLocalTransaction [ 
	^ transaction = anODBLocalTransaction
]

{ #category : #'public/load/store' }
ODBLock >> loadFromStream: aStream [ 
	^ self subclassResponsibility
]

{ #category : #'public/accessing' }
ODBLock >> lockID [

    ^lockID
]

{ #category : #'public/accessing' }
ODBLock >> lockID: anInteger [

    lockID := anInteger
]

{ #category : #'public/accessing' }
ODBLock >> lockIndex [

    ^lockIndex
]

{ #category : #'public/accessing' }
ODBLock >> lockIndex: anInteger [

    lockIndex := anInteger.
]

{ #category : #'public/accessing' }
ODBLock >> lockRegistryKey [ 
	^ objectID lockRegistryKey
]

{ #category : #'public/accessing' }
ODBLock >> objectID [

    ^objectID
]

{ #category : #'public/accessing' }
ODBLock >> objectID: anObjectID [

    objectID := anObjectID
]

{ #category : #'public/load/store' }
ODBLock >> storeOnStream: aStream [
	^ self subclassResponsibility
]

{ #category : #accessing }
ODBLock >> transaction [
	^ transaction
]

{ #category : #'public/accessing' }
ODBLock >> transaction: aTransaction [

    transaction := aTransaction
]

{ #category : #accessing }
ODBLock >> transactionObject [
	"Private - Get transaction object corresponding to objectID."

    ^transaction transactionObjectAt: objectID
]

{ #category : #locking }
ODBLock >> unlock [
	^ self subclassResponsibility
]
