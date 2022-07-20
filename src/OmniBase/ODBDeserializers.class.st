"
ODBTypeCodes class>>#initializeTypeCodeMapping registers which class is responsible for de-serializing a typecode. For the standard case, the class of of the object plays this role (e.g. Association class>>#odbDeserialize: is registerd for reading Association instances).

But for some encodings, we do not have a direct class: For example, we have a special encoding for small strings. For all these cases, subcasses of ODBSerializers are registered, for example ODBnCharacterString for the small string encoding.
"
Class {
	#name : #ODBDeserializers,
	#superclass : #Object,
	#category : #'OmniBase-Serializers'
}
