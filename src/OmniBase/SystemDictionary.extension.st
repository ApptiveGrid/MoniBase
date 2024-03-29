Extension { #name : #SystemDictionary }

{ #category : #'*omnibase' }
SystemDictionary >> odbBasicSerialize: serializer [

	serializer stream nextPutSystemDictionary: self
]

{ #category : #'*omnibase' }
SystemDictionary >> odbSerialize: serializer [
	"registration not needed, as we always return the current Smalltalk globals value on read"
	self odbBasicSerialize: serializer
]
