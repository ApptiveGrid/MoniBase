Extension { #name : #BinaryFileStream }

{ #category : #'*OmniBase' }
BinaryFileStream >> asODBPrimitiveEncodingStream [
	^ ODBFileStreamWrapper on: self
]

{ #category : #'*OmniBase' }
BinaryFileStream >> odbFileHandle [

	^ handle pointerAt: 9
]

{ #category : #'*OmniBase' }
BinaryFileStream >> odbFlockClass [ 
	^ OSPlatform current odbFlockClass
]

{ #category : #'*OmniBase' }
BinaryFileStream >> odbLockAt: position length: length [
	^ self odbFlockClass
		lock: self odbFileHandle
		from: position 
		to: position + length - 1
]

{ #category : #'*OmniBase' }
BinaryFileStream >> odbUnlockAt: position length: length [

	^ self odbFlockClass  
		unlock: self odbFileHandle
		from: position 
		to: position + length - 1
]

{ #category : #'*OmniBase' }
BinaryFileStream >> releaseLockAndClose [
	"Close file associatied with receiver."

	self unlock.
	self closed 
		ifFalse: [ self close ]
]

{ #category : #'*OmniBase' }
BinaryFileStream >> setShareMode: shareMode [ 
	"Set the special byte appropriately for the desired share mode.  Signal a locking conflict if there is a problem.
	See the class comment for more information on what's going on here."

	shareMode ifNotNil: [
		(self odbFlockClass
			lock: self odbFileHandle
				from: self shareModeFlagLocation
				to: self shareModeFlagLocation
				exclusive: shareMode)
			ifNil: [ ODBLockingConflict signal ] ]
]

{ #category : #'*OmniBase' }
BinaryFileStream >> shareModeExclusive [
	self setShareMode: true
]

{ #category : #'*OmniBase' }
BinaryFileStream >> shareModeFlagLocation [
	"This is the byte location at which the share mode lock is made (see the class comment for details).  This value should probably be less than ODBObjectHolder>>lockStartPosition to avoid conflicts, though it appears that the index file is currently always opened with #shareModeShareAll, so we are actually probably fine in practice."

	^ 999999999
]

{ #category : #'*OmniBase' }
BinaryFileStream >> shareModeRead [
	self setShareMode: false
]

{ #category : #'*OmniBase' }
BinaryFileStream >> unlock [
	^ self odbFlockClass 
		unlock: self odbFileHandle 
		from: 0 
		to: self size.
]

{ #category : #'*OmniBase' }
BinaryFileStream >> writeFrom: aString startingAt: aNumber for: length [ 

	^ File 
		write: handle 
		from: aString 
		startingAt: aNumber 
		count: length
]
