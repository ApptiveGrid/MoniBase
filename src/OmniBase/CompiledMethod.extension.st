Extension { #name : #CompiledMethod }

{ #category : #'*OmniBase' }
CompiledMethod >> odbBasicSerialize: serializer [

	serializer stream nextPutCompiledMethod: self
]

{ #category : #'*OmniBase' }
CompiledMethod class >> odbDeserialize: deserializer [

	^ deserializer stream nextCompiledMethod: self
]
