Class {
	#name : #ODBObjectManager,
	#superclass : #Object,
	#instVars : [
		'containers',
		'environment',
		'idTable',
		'infoFile'
	],
	#category : #'OmniBase-Base'
}

{ #category : #'create/open/close' }
ODBObjectManager >> close [

	"Close object manager and all opened containers."

	| cnt |
	1 to: containers size do: [ :i | 
		(cnt := containers at: i) ifNotNil: [ 
			cnt close.
			containers at: i put: nil ] ].
	containers := OrderedCollection new.
	idTable ifNotNil: [ idTable close ].
	infoFile ifNotNil: [ infoFile close ]
]

{ #category : #public }
ODBObjectManager >> containerAt: containerID [
        "Answer container at containerID or default container if none."

    ^self containerAt: containerID ifAbsent: [^self defaultContainer]
]

{ #category : #public }
ODBObjectManager >> containerAt: containerID ifAbsent: aBlock [

	"Answer container at containerID. Evaluate aBlock if absent."

	| cont pos |
	containerID < 1 ifTrue: [ ^ aBlock value ].
	containerID > containers size ifFalse: [ 
		(cont := containers at: containerID) ifNotNil: [ ^ cont ] ].
	pos := idTable at: containerID ifAbsent: [ ^ aBlock value ].
	pos == 0 ifTrue: [ ^ aBlock value ].
	^ self initContainerAt: pos
]

{ #category : #public }
ODBObjectManager >> containerNamed: containerName [
   "Answer container with containerName or default container, if container is not found."

    ^self containerNamed: containerName ifAbsent: [ self defaultContainer ]
]

{ #category : #public }
ODBObjectManager >> containerNamed: containerName ifAbsent: aBlock [ 
	"Answer container with containerName. 
        Evaluate aBlock, if container is not found."

	| name pos |
	name := self unifyContainerName: containerName.
	containers do: [:each | (each isNil or: [each name ~= name]) ifFalse: [^each]].
	pos := infoFile at: name ifAbsent: [^aBlock value].
	pos == 0 ifTrue: [^aBlock value].
	^self initContainerAt: pos
]

{ #category : #public }
ODBObjectManager >> containerNew: aString [
	"Create new container named aString. Answer container created."

	^ self containerNew: aString path: ''
]

{ #category : #public }
ODBObjectManager >> containerNew: aString path: path [

	"Private - Create new container named aString 
	on given path. Signal an error if failed."

	| containerName containerID containerPath dirName cont pos stream |
	path = '' ifFalse: [ OmniBase signalError: 'Not supported' ].
	infoFile isLocked ifTrue: [ 
		OmniBase signalError: 'Object manager is currently locked !' ].
	idTable waitForAddingLock.

	[ 
	(cont := self containerNamed: aString ifAbsent: [  ]) ifNotNil: [ 
		OmniBase signalError: 'Container with this name allready exists' ].
	containerName := self unifyContainerName: aString.
	containerID := idTable add: 0.
	pos := 0.
	dirName := self convert: aString.

	[ 
	containerPath := (path isEmpty
		                  ifTrue: [ self path ]
		                  ifFalse: [ path ]) / dirName.
	containerPath exists ] whileTrue: [ 
		pos := pos + 1.
		dirName := (dirName copyFrom: 1 to: (dirName size min: 7))
		           , pos printString ].
	containerPath ensureCreateDirectory.
	cont := ODBContainer new
		        name: containerName;
		        id: containerID;
		        objectManager: self;
		        createOn: containerPath.
	stream := infoFile stream.
	pos := stream
		       setToEnd;
		       position.
	stream
		putWord: containerID;
		putString: containerName;
		putString: path;
		putString: dirName.
	idTable at: containerID put: pos.
	infoFile at: containerName put: pos ] ensure: [ idTable unlockAdding ].
	containerID > containers size ifTrue: [ 
		pos := Array new: containerID.
		pos
			replaceFrom: 1
			to: containers size
			with: containers
			startingAt: 1.
		containers := pos ].
	^ containers at: containerID put: cont
]

{ #category : #public }
ODBObjectManager >> containers [
        "Answer collection of all containers in database."

    | coll |
    coll := OrderedCollection new.
    idTable indexesAndValuesDo: [:i :pos | coll add: (self containerAt: i)].
    ^coll
]

{ #category : #private }
ODBObjectManager >> convert: containerName [ 
	"Private - Answer a String which is a directory name 
	abbreviated from containerName. Lower case
	vowels are dropped from the right of containerName
	until it is less than or equal to 8 characters."

	| size dirName asciiInteger |
	dirName := containerName select: 
					[:char | 
					asciiInteger := char asInteger.
					((asciiInteger > 96 and: [asciiInteger < 123]) 
						or: [asciiInteger > 64 and: [asciiInteger < 91]]) 
							or: [asciiInteger > 47 and: [asciiInteger < 58]]].
	size := dirName size.
	dirName := (dirName reverse select: 
					[:char | 
					(char isVowel and: [char isLowercase]) ifTrue: [(size := size - 1) < 8] ifFalse: [true]]) 
				reverse.
	^dirName isEmpty 
		ifTrue: ['Contanr0']
		ifFalse: [dirName copyFrom: 1 to: (dirName size min: 8)]
]

{ #category : #public }
ODBObjectManager >> createOn: anOmniBase [ 
	"Create new object manager."

	environment := anOmniBase.
	
	[
		self path exists
			ifFalse: [ self path ensureCreateDirectory ].
	idTable := ODBIDTable createOn: self idFileName.
	infoFile := ODBContainerInfoFile createOn: self infoFileName.
	self containerNew: 'Default'] 
			ifCurtailed: [self close]
]

{ #category : #public }
ODBObjectManager >> defaultContainer [
	"Answer default container."
	
	^ (containers at: 1)
		  ifNil: [ self initContainerAt: (idTable at: 1) ]
		  ifNotNil: [:cont | cont ]
]

{ #category : #public }
ODBObjectManager >> defaultObjectSpace [
	^infoFile defaultObjectSpace
]

{ #category : #public }
ODBObjectManager >> defaultObjectSpace: anInteger [

	^infoFile defaultObjectSpace: anInteger
]

{ #category : #accessing }
ODBObjectManager >> environment [

    ^ environment
]

{ #category : #public }
ODBObjectManager >> flushContainers [

	"Flush all containers before commit."

	containers do: [ :each | each ifNotNil: [ each flushBytes ] ]
]

{ #category : #public }
ODBObjectManager >> holderAt: objectID [ 
	"Answer persistent object holder at objectID."

	^(self containerAt: objectID containerID ifAbsent: [^nil]) at: objectID index
]

{ #category : #private }
ODBObjectManager >> idFileName [
	^ environment path / 'omnibase.cid'
]

{ #category : #private }
ODBObjectManager >> infoFileName [
	^ environment path / 'omnibase.cif'
]

{ #category : #private }
ODBObjectManager >> initContainerAt: position [ 
	"Private - Initialize container stored in infoFile at position.
	Answer container."

	| id name path cont dirName stream newArray |
	stream := infoFile stream.
	stream position: position.
	id := stream getWord.
	name := stream getString.
	path := stream getString.
	path isEmpty ifTrue: [path := self path].
	dirName := stream getString.
	id > containers size 
		ifTrue: 
			[newArray := Array new: id.
			newArray 
				replaceFrom: 1
				to: containers size
				with: containers
				startingAt: 1.
			containers := newArray].
	cont := (ODBContainer new)
				name: name;
				id: id;
				objectManager: self;
				openOn: path / dirName.
	^containers at: id put: cont
]

{ #category : #initialization }
ODBObjectManager >> initialize [

    containers := Array new: 32
]

{ #category : #public }
ODBObjectManager >> isLocked [
        "Answer <true> if object manager is locked."

    ^infoFile isLocked
]

{ #category : #public }
ODBObjectManager >> lock [
        "Lock object manager."

    ^infoFile lock
]

{ #category : #public }
ODBObjectManager >> openOn: anOmniBase [ 
	"Open receiver. Trigger an exception if failed."

	environment := anOmniBase.
	
	[idTable := ODBIDTable openOn: self idFileName.
	infoFile := ODBContainerInfoFile openOn: self infoFileName] 
			ifCurtailed: [self close]
]

{ #category : #private }
ODBObjectManager >> path [
	"Private - Answer directory where containers are placed."

	^ environment path / 'Objects'
]

{ #category : #public }
ODBObjectManager >> reopen [
	idTable close.
	[ idTable := ODBIDTable openOn: self idFileName ] 
		ifCurtailed: [environment close]
]

{ #category : #public }
ODBObjectManager >> reopenExclusively [
	| result |
	result := false.
	idTable close.
	
	[idTable := ODBIDTable new openExclusivelyOn: self idFileName.
	result := true] on: Error
			do: [:ex | [idTable := ODBIDTable openOn: self idFileName] ifCurtailed: [environment close]].
	^result
]

{ #category : #private }
ODBObjectManager >> unifyContainerName: aString [ 
	"Private - unifies aString that represents a container name."
	
	| str |
	str := aString withBlanksCondensed.
	^str size > 20 ifTrue: [str first: 20] ifFalse: [str]
]

{ #category : #public }
ODBObjectManager >> unlock [
        "Unlock object manager."

    ^infoFile unlock
]
