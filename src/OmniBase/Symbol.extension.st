Extension { #name : #Symbol }

{ #category : #'*omnibase' }
Symbol >> odbBasicSerialize: serializer [

	serializer stream nextPutSymbol: self
]

{ #category : #'*omnibase' }
Symbol class >> odbDeserialize: deserializer [

	^ deserializer stream nextSymbol
]

{ #category : #'*omnibase' }
Symbol >> odbSerialize: serializer [
	"Symbols are created by #asSymbol, thus we do not care that we store them multiple times,
	if the Symbol is larger than an inernal reference, we might waste space (most symbols are small)"
	
	self odbBasicSerialize: serializer
]
