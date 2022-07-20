"
This class reads characters that are stored with two bytes. 

type code ""ODBDoubleByteCharacter""

For 1-byte characters, see Character class>>#odbDeserialize:



"
Class {
	#name : #ODBDoubleByteCharacter,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #serialization }
ODBDoubleByteCharacter class >> odbDeserialize: deserializer [

    ^ deserializer stream nextDoubleByteCharacter
]
