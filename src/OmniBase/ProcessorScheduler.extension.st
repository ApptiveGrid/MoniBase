Extension { #name : #ProcessorScheduler }

{ #category : #'*omnibase' }
ProcessorScheduler >> odbBasicSerialize: serializer [
	self class == ProcessorScheduler ifFalse: [ ^ super odbBasicSerialize: serializer ].
	serializer stream nextPutProcessorScheduler: self
]

{ #category : #'*omnibase' }
ProcessorScheduler >> odbSerialize: serializer [
	"registration not needed, as we always return the current Process value on read"
	self odbBasicSerialize: serializer
]
