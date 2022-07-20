"
This class reads an object where the class is stored with the object, as it is the first time that class was seen. (see ODBSerializer>>#registerClass:)

In the end, this calls Object class>>#odbLoadVariables:classInfo:

type code is 3 (no named variable in ODBTypeCodes class>>#initializeTypeCodeMapping)

"
Class {
	#name : #ODBNewObjectNewClass,
	#superclass : #ODBDeserializers,
	#category : #'OmniBase-Serializers'
}

{ #category : #serialization }
ODBNewObjectNewClass class >> odbDeserialize: deserializer [

	^ deserializer newObjectNewClass
]
