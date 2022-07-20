"
This class reads large positive integers

NOTE: For the database, large positive intergers are those > 16
Do not confuse this with the Pharo LargePositiveInteger!

type code ""ODBLargePositiveIntegerCode""
"
Class {
	#name : #ODBLargePositiveInteger,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #'no category' }
ODBLargePositiveInteger class >> odbDeserialize: deserializer [
 
	^ deserializer stream nextLargePositiveInteger
]
