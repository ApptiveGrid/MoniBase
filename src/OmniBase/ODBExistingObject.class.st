"
This class reads an internal reference to another object that is serialized together and not yet in the database. See ODBExternalReference for objects already in the database.

type code ""ODBInternalReferenceCode""


"
Class {
	#name : #ODBExistingObject,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #serialization }
ODBExistingObject class >> odbDeserialize: deserializer [

    ^ deserializer existingObject
]
