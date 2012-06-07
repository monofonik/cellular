DividedImageFrameMorph subclass: #ScratchLibraryMorph
	instanceVariableNames: 'scrollPane stagePane thumbWidth itemExtent spritePane buttonPane spriteLabel '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Panes'!
!ScratchLibraryMorph commentStamp: '<historical>' prior: 0!
I am a Scratch library viewer. I display thumbnails of all the Scratch objects that exist in the world including the stage. Clicking on one of these thumbnails views the associated scratch object.
!


!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'JM 8/17/2011 10:39'!
buildPanes
	"Build my scroll pane."

	| bin |
	stagePane _ Morph new
		color: Color transparent;
		position: self position + (7@0).

	bin _ ScratchSpriteLibraryMorph new
		color: Color transparent;
		borderWidth: 0.

	scrollPane _ ScrollFrameMorph2 new
		color: Color transparent;
		contents: bin;
		showHorizontalScrollbar: false.

	spritePane _ Morph new
		color: Color gray;
		position: self position.
	spriteLabel _ self buildSpriteLabel.
	buttonPane _ self makeNewSpriteButtons: (self ownerThatIsA: ScratchFrameMorph).

	self addMorph: spritePane.
	self addMorph: spriteLabel.
	self addMorph: buttonPane.
	self addMorph: scrollPane.
	self addMorph: stagePane.
! !

!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'jm 5/19/2009 13:48'!
buildSpriteLabel

	^ StringMorph new
		font: (ScratchFrameMorph getFont: #Tab);
		color: Color white;
		contents: 'New sprite:' localized
! !

!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'jm 5/1/2009 10:50'!
clearLibrary
	"Remove all library items. My step method will re-add items for existing objects."

	| sFrame |
	stagePane removeAllMorphs.
	scrollPane contents removeAllMorphs.
	scrollPane vScrollRelative: 0.

	spriteLabel delete.
	spriteLabel _ self buildSpriteLabel.

	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	(sFrame isNil or:
	 [sFrame viewMode = #normal]) ifTrue: [
		self addMorph: spriteLabel].

	buttonPane delete.
	buttonPane _ self makeNewSpriteButtons: sFrame.
	self addMorph: buttonPane.

	topSectionHeight _ ((spriteLabel height + 10) max: 40).
	self fixLayout.
! !

!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'jm 5/1/2009 10:51'!
initialize

	super initialize.
	self buildPanes.
	self
		initFrontFromForm: (ScratchFrameMorph skinAt: 'spriteLibraryPaneFrameTransparent2')
		topSectionHeight: ((spriteLabel height + 10) max: 40).
	self middleBarLeftMargin: 0 rightMargin: 6.
	self extent: 200@100.
! !

!ScratchLibraryMorph methodsFor: 'initialization' stamp: 'JM 8/17/2011 10:54'!
makeNewSpriteButtons: aScratchFrameMorph
	"Return a morph containing a set of new sprite buttons."

	| panel buttonSpecs buttons button butonExtent x |
	panel _ Morph new color: Color transparent.

	buttonSpecs _ #(
		"	icon name				selector					tooltip"
		(newSpritePaint			paintSpriteMorph		'Paint new sprite')
		(newSpriteLibrary		addSpriteMorph			'Choose new sprite from file')
		(newSpriteSurprise 		surpriseSpriteMorph		'Get surprise sprite')
	).

	buttons _ buttonSpecs collect: [:spec |
		button _ ToggleButton new
			onForm: (ScratchFrameMorph skinAt: (spec at: 1))
			offForm: (ScratchFrameMorph skinAt: (spec at: 1)).

		button
			target: aScratchFrameMorph;
			actionSelector: (spec at: 2);
			setProperty: #balloonText toValue: (spec at: 3) localized.
		button].

	butonExtent _ ScratchFrameMorph isXO ifTrue: [37@27] ifFalse: [37@27].
	x _ 0.
	buttons do: [:b |
		b extent: butonExtent.
		panel addMorph: (b position: x@1).
		x _ x + 5 + b width].

	panel extent: x@(butonExtent y + 1).

	^ panel
! !


!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'ee 11/10/2008 14:10'!
spriteButtonsTarget: anObject

	buttonPane submorphs do: [:m |
		(m isKindOf: ToggleButton) ifTrue: [
			m target: anObject]].! !

!ScratchLibraryMorph methodsFor: 'accessing' stamp: 'tis 9/11/2006 10:46'!
spriteThumbnails

	^ scrollPane contents submorphs
! !


!ScratchLibraryMorph methodsFor: 'geometry' stamp: 'ee 12/30/2008 13:55'!
fixLayout
	"Position and size thumbnails."

	| libPane x y rMargin sFrame |
	scrollPane isNil | stagePane isNil | spritePane isNil ifTrue: [^ self].

	spritePane width: self width.
	spritePane height: topSectionHeight.

	spriteLabel position: (self left + 15)@(self top + (topSectionHeight // 2) - (spriteLabel height // 2) + 3).
	sFrame _ self ownerThatIsA: ScratchFrameMorph.
	(sFrame isNil or: [sFrame viewMode = #normal])
		ifTrue: [buttonPane position: (spriteLabel right + 10)@(self top + (topSectionHeight // 2) - (buttonPane height // 2) + 3)]
		ifFalse: [buttonPane position: (self left + 12)@(self top + (topSectionHeight // 2) - (buttonPane height // 2) + 3)].
	

	stagePane height = self height ifFalse: [
		stagePane height: self height].
	scrollPane height = self height ifFalse: [
		scrollPane height: self height - topSectionHeight].
	scrollPane width = (self right - stagePane right) ifFalse: [
		scrollPane width: self right - stagePane right].

	scrollPane position: scrollPane left @ (self top + topSectionHeight + 3).
	stagePane position: stagePane left @ (self top + topSectionHeight + 3).

	libPane _ scrollPane contents.
	ScratchTranslator isRTL
		ifTrue: [x _ libPane left + 30]
		ifFalse: [x _ libPane left + 8].
	y _ libPane top + 7.
	rMargin _ x + scrollPane width - 5.
	libPane submorphs do: [:m |
		(x + m width) > rMargin ifTrue: [
			ScratchTranslator isRTL
				ifTrue: [x _ libPane left + 30]
				ifFalse: [x _ libPane left + 8].
			y _ y + m height].
		m position: x@y.
		x _ x + m width].

	stagePane submorphCount > 0 ifTrue: [
		m _ stagePane firstSubmorph.
		m position: stagePane topLeft + ((stagePane extent - stagePane firstSubmorph extent) // 2) + (0@15) - (0@topSectionHeight)].
! !


!ScratchLibraryMorph methodsFor: 'drawing' stamp: 'ee 11/10/2008 14:16'!
drawBackgroundOn: aCanvas
	"Draw my background."

	| r |
	"color isTransparent ifTrue: [^ self]."
	color _ Color gray darker.

	aCanvas fillRectangle: (myBox insetBy: 7) color: color.

	r _ ((stagePane right + 3) @ (myBox top + topSectionHeight + 12)) extent: (1 @ (myBox height - topSectionHeight - 30)).
	aCanvas fillRectangle: r color: (Color gray: 0.3).

	r _ (r origin + (1@0)) extent: (1 @ r height).
	aCanvas fillRectangle: r color: Color gray.
! !


!ScratchLibraryMorph methodsFor: 'stepping' stamp: 'jm 12/22/2008 13:01'!
step
	"Update my thumbnail list if morphs have been added or deleted."

	| sFrame workPane morphsWithThumbnails doLayout workPaneObjects |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	sFrame paintingInProgress
		ifTrue: [^ self]
		ifFalse: [scrollPane owner ifNil: [self addMorph: scrollPane]].

	workPane _ sFrame workPane.

	"remove thumbnails for any objects that have been deleted"
	morphsWithThumbnails _ IdentitySet new.
	doLayout _ false.
	scrollPane contents submorphs do: [:m |
		(m target isNil or: [m target owner isNil])
			ifTrue: [m delete. doLayout _ true]
			ifFalse: [morphsWithThumbnails add: m target]].
	stagePane submorphs do: [:m |
		(m target isNil or: [m target owner isNil])
			ifTrue: [m delete. doLayout _ true]
			ifFalse: [morphsWithThumbnails add: m target]].

	"add thumbnail for the background, if necessary"
	(morphsWithThumbnails includes: workPane) ifFalse: [
		self addThumbnailFor: workPane.
		doLayout _ true].

	"add thumbnails for any new objects"
	workPaneObjects _ workPane sprites select: [:s |
		(s isKindOf: ScriptableScratchMorph) and: [s isScriptable & s isClone not]].
	workPaneObjects do: [:m |
		(morphsWithThumbnails includes: m) ifFalse: [
			self addThumbnailFor: m.
			doLayout _ true]].

	doLayout ifTrue: [
		self changed.
		self fixLayout.
		self isInWorld ifTrue: [self world startSteppingSubmorphsOf: self]].

	self updateHighlight.
! !

!ScratchLibraryMorph methodsFor: 'stepping' stamp: 'jm 6/30/2004 14:17'!
stepTime

	^ 500
! !


!ScratchLibraryMorph methodsFor: 'private' stamp: 'JM 8/17/2011 13:17'!
addThumbnailFor: aMorph
	"Add a thumbnail for the given morph."

	| newThumbnail isSprite |
	
	"If this is a clone, dont bother"
	aMorph prototype ifNotNil: [ ^ self ].

	newThumbnail _ LibraryItemMorph new.
	isSprite _ (aMorph isKindOf: ScratchStageMorph) not.

	"Different width for stage sprite icon - no clone count"
	newThumbnail extent: itemExtent thumbWidth: thumbWidth isSprite: isSprite.
	
	newThumbnail target: aMorph.
	(newThumbnail target isKindOf: ScratchStageMorph)
		ifTrue: [ stagePane addMorph: newThumbnail. ]
		ifFalse: [scrollPane contents addMorphBack: newThumbnail ].
	newThumbnail step.
! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'JM 8/17/2011 11:13'!
extent: aRectangle

	| nameHeight cloneCountHeight |
	super extent: aRectangle.
	scrollPane isNil | stagePane isNil ifTrue: [^ self].
	
	thumbWidth _ 50.
	nameHeight _ (ScratchTranslator stringExtent: ('Sprite1' localized) font: (ScratchFrameMorph getFont: #LibraryItemName)) y.
	cloneCountHeight _ (UpdatingStringFieldMorph new) height.

	itemExtent _ (70)@(54 + nameHeight + cloneCountHeight).




	stagePane width: itemExtent x.
	scrollPane left: stagePane right.

	self fixLayout.
! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'jm 11/21/2006 16:02'!
unhighlightAll

	scrollPane contents submorphs do: [:m | m highlight: false].
	stagePane submorphs do: [:m | m highlight: false].
! !

!ScratchLibraryMorph methodsFor: 'private' stamp: 'jm 11/21/2006 16:02'!
updateHighlight

	| sFrame viewedObj |
	(sFrame _ self ownerThatIsA: ScratchFrameMorph) ifNil: [^ self].
	viewedObj _ sFrame viewerPane target.

	scrollPane contents submorphs do: [:m | 
		m highlight: (m target = viewedObj)].
	stagePane submorphs do: [:m | 
		m highlight: (m target = viewedObj)].
! !


!ScratchLibraryMorph methodsFor: 'BYOB' stamp: 'jens 3/9/2011 22:15'!
doesNotUnderstand: aMessage 

	| sel frame |
	sel _ self spriteThumbnails detect: [:tn |
		tn target objName = aMessage selector] ifNone: [nil].
	sel ifNil: [	^ super doesNotUnderstand: aMessage].

	frame _ self ownerThatIsA: ScratchFrameMorph.
	frame ifNil: [^ self].

	sel select.
	frame viewerPane target: sel target.
	sel target viewBlocksAndScriptsQuickly.
	sel childrenMenu

! !
