Extension { #name : #WideSymbol }

{ #category : #'*OmniBase' }
WideSymbol >> asBtreeKeyOfSize: keySize [
	"workaround to the missing #asByteArray, see pharo issue #11015"
	^self asString asByteArray asBtreeKeyOfSize: keySize
]

{ #category : #'*OmniBase' }
WideSymbol >> odbBasicSerialize: serializer [

	serializer stream nextPutWideSymbol: self
]

{ #category : #'*OmniBase' }
WideSymbol class >> odbDeserialize: deserializer [

	^ deserializer stream nextWideSymbol 
]

{ #category : #'*OmniBase' }
WideSymbol >> odbSerialize: serializer [
	"Symbols are created by #asSymbol, thus we do not care that we store them multiple times,
	if the Symbol is larger than an inernal reference, we might waste space (most symbols are small)"
	
	self odbBasicSerialize: serializer
]
