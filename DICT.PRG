/***
*
*	Dict.prg
*
*	Keyed dictionary utility.
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*  (слегка переделано 05.08.2002 Бабенко К.В.)
*
*	Uses an array to contain list of "dictionary" entries.
* Each entry consists of a key of any type and a value of any type.
*
*  Index of functions contained in Dict.prg (this file):
*  -----------------------------------------------------
*
*  DictNew() --> <aDictionary>
*
*     Creates and returns an empty dictionary.
*
*  DictAt( <aDictionary>, <cKey> ) --> <xValue>
*
*     Returns the <xValue> associated with <cKey> in dictionary,
*     NIL if <cKey> is not present in dictionary.
*
*  DictPut( <aDictionary>, <cKey>, <xValue> ) --> <xValue>
*
*     Associates <cKey> to <xValue> in <aDictionary>. Returns <xValue>.
*
*  DictPutPair( <aDictionary>, <aPair> ) --> <aPair>
*
*		Adds <aPair> to <aDictionary>. Returns <aPair>.
*     <aPair> is a <cKey>/<xValue> pair: { <cKey>, <xValue> }.
*
*  DictRemove( <aDictionary>, <cKey> ) --> <aDictionary>
*
*   Removes the <cKey>/<xValue> pair for <cKey>.
*		Returns <aDictionary>.
*
*  DictEval( <aDictionary>, <bBlock> ) --> <aDictionary>
*
*		Evaluates <bBlock> against each <cKey>/<xValue> pair in
*		dictionary. Pair is passed to block as { <cKey>, <xValue> }
*		Returns <aDictionary>.
*
*/

*****  Create a new, empty dictionary
FUNCTION DictNew()
return {}

*****  Return the value for a particular key
FUNCTION DictAt( aDict, cKey )
LOCAL nPairNo     // Location of the matching pair, zero if none matches
nPairNo := ASCAN( aDict, { |x| x[1] == cKey } )
RETURN iif(nPairNo == 0, NIL, aDict[nPairNo,2])

***** Add or replace the value for a particular key
*****  Returns the value being added
FUNCTION DictPut( aDict, cKey, xVal )
DictPutPair( aDict, { cKey, xVal } )   // Put an item by putting the pair
RETURN xVal

*****  Add or replace key/value pair for a particular key
*****  Returns the pair being added
FUNCTION DictPutPair( aDict, aPair )
LOCAL aBucket        // Contains the key/value pair
LOCAL cKey           // Key value of the pair to be 'put'
LOCAL nLocation      // Location in aDict where aPair will reside

cKey := aPair[1]
nLocation := ASCAN(aDict, { |x| x[1] == cKey } )
IF nLocation == 0
  AAdd( aDict, aPair )
  nLocation := Len( aDict )
ELSE
  aDict[nLocation] := aPair
ENDIF
RETURN ( aPair )

*****  Remove the key/value pair for a particular key
*****  Returns a reference to the dictionary
FUNCTION DictRemove( aDict, cKey )
LOCAL nLocation   // Location of the pair in aDict
nLocation := ASCAN( aDict, { |x| x[1] == cKey } )
IF nLocation != 0
  ADEL( aDict, nLocation )
  ASIZE( aDict, LEN( aDict ) - 1 )
ENDIF
RETURN aDict

*****  Evaluate block against each pair in the dictionary
FUNCTION DictEval( aDict, bCode )
AEVAL( aDict, { |aPair| EVAL( bCode, aPair ) } )
RETURN aDict
