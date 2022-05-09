Extension { #name : #True }

{ #category : #'*omnibase' }
True >> odbBasicSerialize: serializer [

	serializer stream nextPutTrue: self
]

{ #category : #'*omnibase' }
True >> odbObjectID [

	^ODBObjectID containerID: 0 index: 2
]

{ #category : #'*omnibase' }
True >> odbSerialize: serializer [
	"registration not needed, as we always return the one true on read"
	self odbBasicSerialize: serializer
]
