"
This class reads an object where the class was already registered before.
(see ODBSerializer>>#registerClass:)

In the end, this calls Object class>>#odbLoadVariables:classInfo:


type code is 3 (no named variable in ODBTypeCodes class>>#initializeTypeCodeMapping)
"
Class {
	#name : #ODBNewObject,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #serialization }
ODBNewObject class >> odbDeserialize: deserializer [

	^ deserializer newObjectOldClass
]
