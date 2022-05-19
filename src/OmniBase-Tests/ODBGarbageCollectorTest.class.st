Class {
	#name : #ODBGarbageCollectorTest,
	#superclass : #ODBDiskBasedTest,
	#category : #'OmniBase-Tests'
}

{ #category : #tests }
ODBGarbageCollectorTest >> testGC [

	"Test garbage collection, this is a smoke test"

	self timeLimit: 1 minute.
	db garbageCollect
]
