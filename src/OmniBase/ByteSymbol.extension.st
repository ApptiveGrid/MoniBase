Extension { #name : #ByteSymbol }

{ #category : #'*omnibase' }
ByteSymbol >> odbBasicSerialize: serializer [

	serializer stream nextPutSymbol: self
]

{ #category : #'*omnibase' }
ByteSymbol class >> odbDeserialize: deserializer [

	^ deserializer stream nextSymbol
]

{ #category : #'*omnibase' }
ByteSymbol >> odbSerialize: serializer [
	"Symbols are created by #asSymbol, thus we do not care that we store them multiple times,
	if the Symbol is larger than an inernal reference, we might waste space (most symbols are small)"
	
	self odbBasicSerialize: serializer
]
