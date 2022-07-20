"
This class reads large negative integers

NOTE: For the database, large negative intergers are those <= -5.
Do not confuse this with the Pharo LargeNegativeInteger!

type code ""ODBLargeNegativeIntegerCode""
"
Class {
	#name : #ODBLargeNegativeInteger,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #'no category' }
ODBLargeNegativeInteger class >> odbDeserialize: deserializer [

	^ deserializer stream nextLargeNegativeInteger
]
