Extension { #name : #Process }

{ #category : #'*omnibase' }
Process >> odbSerialize: serializer [
	"Not stored, thus no registration needed"
	serializer cantSave: self
]
