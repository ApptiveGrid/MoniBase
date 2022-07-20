"
This class reads an external reference to another object that is already in the database. 

See ODBInternalReference for objects not yet in the database.

type code ""ODBInternalReferenceCode""
"
Class {
	#name : #ODBExternalReference,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #serialization }
ODBExternalReference class >> odbDeserialize: deserializer [

	^ deserializer loadReference
]
