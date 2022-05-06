Extension { #name : #HashedCollection }

{ #category : #'*OmniBase' }
HashedCollection >> odbDeserialized: deserializer [
	super odbDeserialized: deserializer.
	"We have to re-hash, as the elements are newly de-serialized objects.
	If the #hash is using #identityHash, we might not find it anymore"
	^self rehash 
]
