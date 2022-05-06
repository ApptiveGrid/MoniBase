Extension { #name : #False }

{ #category : #'*omnibase' }
False >> odbBasicSerialize: serializer [

	serializer stream nextPutFalse: self
]

{ #category : #'*omnibase' }
False >> odbObjectID [

	^ODBObjectID containerID: 0 index: 3
]

{ #category : #'*omnibase' }
False >> odbSerialize: serializer [
	"registration not needed, as we always return the one false on read"
	self odbBasicSerialize: serializer
]
