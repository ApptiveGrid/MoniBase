Extension { #name : #SmallFloat64 }

{ #category : #'*OmniBase' }
SmallFloat64 >> odbBasicSerialize: serializer [ 
	serializer stream nextPutSmallFloat64: self
]

{ #category : #'*OmniBase' }
SmallFloat64 >> odbSerialize: serializer [
	"immediate object, no registration needed"
	self odbBasicSerialize: serializer
]
