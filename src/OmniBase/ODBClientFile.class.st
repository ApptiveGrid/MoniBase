Class {
	#name : #ODBClientFile,
	#superclass : #ODBFile,
	#category : #'OmniBase-Files'
}

{ #category : #public }
ODBClientFile >> clientDescription [
	"Answer client description string."

	| str |
	str := String new: 128.
	stream atPosition: self headerLength getBytesFor: str.
	^(ReadStream on: str) upTo: 0 asCharacter
]

{ #category : #public }
ODBClientFile >> clientDescription: aString [ 
	"Set client description string."

	stream 
		atPosition: self headerLength
		putBytesFrom: ((String new: 128) 
				replaceFrom: 1
				to: (aString size min: 128)
				with: aString
				startingAt: 1)
		len: 128
]

{ #category : #public }
ODBClientFile >> createOn: aFileReference [
	"client files can lay around so we delete it so everything
	looks as expected"
	aFileReference deleteIfAbsent: [].
	^ super createOn: aFileReference 
	
]

{ #category : #'private/unclassified' }
ODBClientFile >> created [
                "Private - Put default values into file."

        "client description = 128 bytes"
        "distributed objects hostname=32 bytes"
        "transactions count = 4 bytes"
        stream putBytesFrom: (ByteArray new: 164); flush
]

{ #category : #'private/initialization' }
ODBClientFile >> descriptionString [

    ^'OmniBase Client File
OmniBase 1.0, David Gorisek (c) 1998

'
]

{ #category : #'public/create/open/close' }
ODBClientFile >> openOn: aFileReference [
	"Open client file. Signal an error if failed."
	self fileShouldExist: aFileReference.
	stream := self 
		newCodecStreamOn: aFileReference  
		using: [ :s | s shareModeRead ].
   
	^ self compareHeader
]

{ #category : #public }
ODBClientFile >> transactionIDs [
	"Answer array of transaction IDs."

	| buf array count |
	buf := ByteArray new: 128.
	stream
		position: self headerLength + 160;
		getBytesFor: buf.
	count := buf odbLongAt: 1.
	array := Array new: count.
	1 to: (count min: 31) do: [:i | array at: i put: (buf odbLongAt: (i * 4) + 1)].
	count > 31 
		ifTrue: 
			[buf := ByteArray new: (count - 31) * 4.
			stream getBytesFor: buf.
			32 to: count do: [:i | array at: i put: (buf odbLongAt: (i * 4) - 127)]].
	^array
]

{ #category : #public }
ODBClientFile >> transactionIDs: anArray [ 
	"Set array of transaction IDs."

	| buf count |
	count := anArray size.
	buf := ByteArray new: count * 4 + 4.
	buf odbLongAt: 1 put: count.
	1 to: count do: [:i | buf odbLongAt: (i * 4) + 1 put: (anArray at: i)].
	stream
		position: self headerLength + 160;
		putBytesFrom: buf;
		flush
]
