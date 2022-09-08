Class {
	#name : #ODBObjectStorage,
	#superclass : #ODBFile,
	#category : #'OmniBase-Files'
}

{ #category : #public }
ODBObjectStorage >> createOn: aFileReference [ 
	"sometimes the file stays as leftover with 0 bytes size. If we 
	encounter an existing with 0 bytes size we delete it"
	(aFileReference exists and: [ aFileReference size = 0 ]) ifTrue: [ 
		aFileReference delete ].
	^ super createOn: aFileReference 

]

{ #category : #'private/initialization' }
ODBObjectStorage >> descriptionString [

    ^'OmniBase Object Storage
OmniBase 1.0, David Gorisek (c) 1998

'
]

{ #category : #public }
ODBObjectStorage >> isEmpty [
	^stream size == self headerLength
]

{ #category : #'public/unclassified' }
ODBObjectStorage >> removeAll [

	stream truncate: self headerLength
]
