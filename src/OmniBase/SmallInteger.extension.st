Extension { #name : #SmallInteger }

{ #category : #'*OmniBase' }
SmallInteger >> odbSerialize: serializer [
	"Small Integers are immediate objects, no registration needed"
	self odbBasicSerialize: serializer
]
