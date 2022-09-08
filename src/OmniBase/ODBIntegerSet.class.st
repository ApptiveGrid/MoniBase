Class {
	#name : #ODBIntegerSet,
	#superclass : #ODBFile,
	#instVars : [
		'bitField',
		'currentPage',
		'changed'
	],
	#category : #'OmniBase-Files'
}

{ #category : #public }
ODBIntegerSet >> add: anInteger [ 
	| pageNumber i j |
	pageNumber := anInteger bitShift: -15.	"-12-3=-15"
	i := ((anInteger bitAnd: 32767) bitShift: -3) + 1.	"8*4096=32768"
	j := 1 bitShift: (anInteger bitAnd: 7).
	self loadPage: pageNumber.
	((bitField at: i) bitAnd: j) == 0 
		ifTrue: 
			[changed := true.
			bitField at: i put: ((bitField at: i) bitOr: j)]
]

{ #category : #'create/open/close' }
ODBIntegerSet >> close [

	"Close stream associated with receiver."

	stream ifNotNil: [ 
		(changed and: [ currentPage notNil ]) ifTrue: [ 
			stream
				position: (currentPage bitShift: 12) + self headerLength;
				putBytesFrom: bitField len: 4096 "2^12=4096" ] ].
	^ super close
]

{ #category : #public }
ODBIntegerSet >> createOn: aFileReference [
	aFileReference deleteIfAbsent: [ ].
	^ super createOn: aFileReference 
]

{ #category : #accessing }
ODBIntegerSet >> includes: anInteger [

	| pageNumber i j |
	pageNumber := anInteger bitShift: -15. "-12-3=-15"
	i := ((anInteger bitAnd: 32767) bitShift: -3) + 1. "4096*8=32768"
	j := 1 bitShift: (anInteger bitAnd: 7).
	self loadPage: pageNumber.
	^((bitField at: i) bitAnd: j) == j
]

{ #category : #initialization }
ODBIntegerSet >> initialize [

    bitField := ByteArray new: 4096.
    changed := false.
]

{ #category : #public }
ODBIntegerSet >> loadPage: pageNumber [ 
	"Private - Check if page pageNumber is loaded. If not, 
	store current page to disk and load page pageNumber."

	| pagePos |
	pageNumber == currentPage ifTrue: [^self].
	changed 
		ifTrue: 
			[stream 
				atPosition: (currentPage bitShift: 12) + self headerLength
				putBytesFrom: bitField
				len: 4096].
	changed := false.
	(pagePos := (pageNumber bitShift: 12) + self headerLength) < stream size 
		ifTrue: 
			[stream 
				atPosition: pagePos
				getBytesFor: bitField
				len: 4096]
		ifFalse: 
			[1 to: bitField size do: [:i | bitField at: i put: 0].
			
			[stream 
				atPosition: stream size
				putBytesFrom: bitField
				len: 4096.
			pagePos > stream size] 
					whileTrue: []].
	currentPage := pageNumber
]
