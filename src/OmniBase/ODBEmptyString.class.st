"
This class reads empty character byte Strings

type code ""ODBSmallStringBaseCode""
"
Class {
	#name : #ODBEmptyString,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #accessing }
ODBEmptyString class >> odbDeserialize: deserializer [

    ^ deserializer register: String new
]
