DialogBoxMorph subclass: #WatcherPlotMorph
	instanceVariableNames: 'graph dataPoints '
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Scratch-UI-Watchers'!

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/15/2012 14:48'!
addDataPoint: aNumber

	| scaled |
	aNumber isNumber ifFalse: [ ^ self ].
	dataPoints addLast: aNumber.
	"(dataPoints size > graph width) ifTrue: [ dataPoints removeFirst ]."
	
	scaled _ OrderedCollection new.
	(1 to: graph width) do: [ :n |
		scaled addLast: (dataPoints at: (((dataPoints size / (graph width) * n) min: dataPoints size) max: 1)).
	].

	graph data: scaled.! !

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/15/2012 15:20'!
copyToClipboard

	SystemDictionary new clipboardText: (dataPoints inject: '' into: [ :s :point |
		s _ s , point asString , ',']) allButLast.! !

!WatcherPlotMorph methodsFor: 'as yet unclassified' stamp: 'JM 5/15/2012 15:12'!
initialize

	super initialize withButtonsForYes: false no: false okay: true cancel: false.

	buttonRow addMorphFront: (self buttonLabel: 'Copy to clipboard' localized action: #copyToClipboard).

	dataPoints _ OrderedCollection new.
	graph _ GraphMorph openOn: dataPoints.
	
	mainColumn addMorphFront: graph.
	self title: 'Graph'.! !
