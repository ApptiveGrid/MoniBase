Class {
	#name : #ODBReference,
	#superclass : #ProtoObject,
	#instVars : [
		'transactionObject',
		'demandLoader'
	],
	#category : #'OmniBase-Model'
}

{ #category : #accessing }
ODBReference >> demandLoader [

	^ demandLoader
]

{ #category : #'predefined intercepted messages' }
ODBReference >> doesNotUnderstand: aMessage [

    ^demandLoader
        perform: aMessage selector
        withArguments: aMessage arguments
]

{ #category : #public }
ODBReference >> halt [
	"This is the typical message to use for inserting breakpoints during debugging."
	<debuggerCompleteToSender>
	<ignoreForCoverage>
	Halt now
]

{ #category : #public }
ODBReference >> inspect [
	"Create and schedule an Inspector in which the user can examine the receiver's variables."
	<ignoreForCoverage>
	^ Smalltalk tools inspector inspect: self
]

{ #category : #accessing }
ODBReference >> isIdenticalTo: anObject [ 
	"Answer true if anObject is identical to receiver. This is necessary since with database
	proxies the real object identity is lost because while the object is not yet loaded from the
	database it is represented by its proxy. Later when the real object is loaded this proxy still
	represents the identical object but the #== identity check will answer false because it is not
	aware of this. It is implemented in this way because the #== method is inlined and can not
	be overridden."

	anObject isODBReference ifTrue: [^self odbObjectID = anObject odbObjectID].
	(anObject isNil or: [self odbNotLoaded]) ifTrue: [^false].
	^self odbTransactionObject value == anObject
]

{ #category : #hacks }
ODBReference >> isMorph [
	^ false
]

{ #category : #public }
ODBReference >> isODBPersistent [

	^ true
]

{ #category : #accessing }
ODBReference >> isODBReference [
	"Answer <true> if receiver is kind of ODReference."

	^true
]

{ #category : #accessing }
ODBReference >> makePersistent [
	"Do nothing, object is already persistent."
]

{ #category : #accessing }
ODBReference >> markDirty [
	self odbNotLoaded ifFalse: [self odbGetTransaction markDirty: self odbResolve]
]

{ #category : #'predefined intercepted messages' }
ODBReference >> notNil [

    ^true
]

{ #category : #accessing }
ODBReference >> odbGetOID [

	^ transactionObject
		  ifNil: [ demandLoader odbObjectID ]
		  ifNotNil: [ :trObject | trObject objectID ]
]

{ #category : #accessing }
ODBReference >> odbGetTransaction [

	"Answer transaction that owns the reference."

	^ transactionObject
		  ifNil: [ demandLoader transaction ]
		  ifNotNil: [ :trObject | trObject transaction ]
]

{ #category : #private }
ODBReference >> odbNotLoaded [

	"Answer <true> if the referenced object has not been loaded yet."

	transactionObject ifNotNil: [ ^ false ].
	^ (demandLoader transaction cachedObjectAt: demandLoader odbObjectID)
		  isNil
]

{ #category : #accessing }
ODBReference >> odbObjectID [

	^ transactionObject
		  ifNil: [ demandLoader odbObjectID ]
		  ifNotNil: [ :obj | obj objectID ]
]

{ #category : #public }
ODBReference >> odbResolve [

	"See Object>>#odbResolve for comment."

	^ transactionObject
		  ifNil: [ demandLoader getObject ]
		  ifNotNil: [ :trObject | trObject value ]
]

{ #category : #serialization }
ODBReference >> odbSerialize: serializer [
	"registration happens in the demandLoader"
	^demandLoader odbSerialize: serializer
]

{ #category : #accessing }
ODBReference >> odbSetLoader: aDemandLoader [

    demandLoader := aDemandLoader
]

{ #category : #accessing }
ODBReference >> odbSetTransactionObject: anODBTransactionObject [ 
	"Private - Set transaction object and answer its value."

	transactionObject := anODBTransactionObject.
	^demandLoader := transactionObject value
]

{ #category : #accessing }
ODBReference >> odbTransaction [
	"Answer transaction that owns the reference."

	^ transactionObject
		  ifNil: [ demandLoader transaction ]
		  ifNotNil: [ :trObject | trObject transaction ]
]

{ #category : #private }
ODBReference >> odbTransactionObject [

	transactionObject ifNil: [ demandLoader getObject ].
	^ transactionObject
]
