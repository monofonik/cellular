Object subclass: #ScratchMedia
	instanceVariableNames: 'mediaName '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-Objects'!
!ScratchMedia commentStamp: '<historical>' prior: 0!
I define the behavior common to all Scratch media objects. There are subclasses of me for still images, movies, and sounds.

All media objects have an editable name.
!


!ScratchMedia methodsFor: 'initialization' stamp: 'jm 5/15/2004 22:02'!
initialize

	super initialize.
	mediaName _ 'untitled'.
! !


!ScratchMedia methodsFor: 'accessing' stamp: 'jm 6/3/2004 18:23'!
infoString
	"Answer a string for this media, typically something about its size."

	self subclassResponsibility
! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 6/29/2004 21:53'!
isImage
	"Answer true if I am an image media object."

	^ false
! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 5/17/2004 11:09'!
isMovie
	"Answer true if I am a movie media object."

	^ false
! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 5/10/2004 18:47'!
isSound
	"Answer true if I am a sound media object."

	^ false
! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 5/4/2004 15:41'!
mediaName

	^ mediaName
! !

!ScratchMedia methodsFor: 'accessing' stamp: 'JM 5/18/2012 16:51'!
mediaName: aString

	mediaName _ aString.! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 10/20/2007 19:43'!
mediaSizeInKilobytes
	"Returns the storage size of this media in kilobytes, rounded to the nearest kilobyte."

	^ 0
! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 5/12/2004 16:26'!
mediaType
	"Answer a string describing this type of media."

	^ 'generic'
! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 10/17/2007 13:04'!
revertToUncompressed
	"Revert to my uncompressed version after temporary compression (e.g. when uploading a project). This default implementation does nothing."! !

!ScratchMedia methodsFor: 'accessing' stamp: 'jm 6/3/2004 18:21'!
thumbnailFormExtent: extent
	"Answer a Form of the given extent containing a thumbnail of me. This default implementation answers a blank thumbnail."

	^ (Form extent: extent depth: 2) fillWhite
! !


!ScratchMedia methodsFor: 'playing' stamp: 'jm 5/14/2004 21:16'!
mediaStep
	"Do one animation or movie step and answer true if my appearance has changed. This default implementation does nothing."

	^ false
! !

!ScratchMedia methodsFor: 'playing' stamp: 'jm 5/15/2004 20:47'!
resumePlaying
	"This method is called when switching costumes to resume playing a costume that was playing when it was switched out. This default implementaton does nothing."! !

!ScratchMedia methodsFor: 'playing' stamp: 'jm 5/14/2004 21:07'!
startPlaying
	"Start playing if I am a movie or animation."
! !

!ScratchMedia methodsFor: 'playing' stamp: 'jm 5/14/2004 21:07'!
stopPlaying
	"Stop playing if I am a movie or animation."
! !

!ScratchMedia methodsFor: 'playing' stamp: 'jm 5/15/2004 20:48'!
suspendPlaying
	"This method is called when switching costumes to suspect a playing costume. This default implementaton does nothing."! !


!ScratchMedia methodsFor: 'printing' stamp: 'jm 5/12/2004 16:28'!
printOn: aStream

	aStream nextPutAll: mediaName, ' [', self mediaType, ']'.
! !


!ScratchMedia methodsFor: 'object i/o' stamp: 'jm 6/1/2004 16:57'!
initFieldsFrom: anObjStream version: classVersion

	self initFieldsNamed: #(
		mediaName
	) from: anObjStream.
! !

!ScratchMedia methodsFor: 'object i/o' stamp: 'jm 6/1/2004 16:57'!
storeFieldsOn: anObjStream

	self storeFieldsNamed: #(
		mediaName
	) on: anObjStream.
! !
