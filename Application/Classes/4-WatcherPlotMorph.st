DialogBoxMorph subclass: #WatcherPlotMorph
	instanceVariableNames: 'graph dataPoints '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Watchers'!

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/21/2012 15:14'!
addDataPoint: aNumber

	aNumber isNumber ifFalse: [ ^ self ].
	dataPoints addLast: aNumber.
	"(dataPoints size > graph width) ifTrue: [ dataPoints removeFirst ]."
	
	self update! !

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/15/2012 15:20'!
copyToClipboard

	SystemDictionary new clipboardText: (dataPoints inject: '' into: [ :s :point |
		s _ s , point asString , ',']) allButLast.! !

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/21/2012 15:13'!
initialize

	super initialize withButtonsForYes: false no: false okay: true cancel: false.

	buttonRow addMorphFront: (self buttonLabel: 'Copy to clipboard' localized action: #copyToClipboard).
	buttonRow addMorphFront: (self buttonLabel: 'Clear' localized action: #clear).

	dataPoints _ OrderedCollection new.
	graph _ GraphMorph openOn: dataPoints.
	
	mainColumn addMorphFront: graph.
	self title: 'Graph'.! !

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/21/2012 15:15'!
update

	| scaled |
	
	scaled _ OrderedCollection new.
	
	"check for no data"
	dataPoints isEmpty ifFalse: [
		(1 to: graph width) do: [ :n |
			scaled addLast: (dataPoints at: (((dataPoints size / (graph width) * n) min: dataPoints size) max: 1)).
		].
	].

	graph data: scaled.! !


!WatcherPlotMorph methodsFor: 'nil' stamp: 'JM 5/21/2012 15:14'!
clear

	dataPoints _ OrderedCollection new.	
	self update! !
