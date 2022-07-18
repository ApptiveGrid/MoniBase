Extension { #name : #CompiledBlock }

{ #category : #'*OmniBase' }
CompiledBlock >> odbBasicSerialize: serializer [

	serializer stream nextPutCompiledBlock: self
]

{ #category : #'*OmniBase' }
CompiledBlock class >> odbDeserialize: deserializer [

	^ deserializer stream nextCompiledBlock: self
]
