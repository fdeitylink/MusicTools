{-# OPTIONS --without-K #-}

module Main where

open import Prelude
open import IO.Primitive.Core

open import JingleBells
open import Counterpoint using (defaultConstraints)
open import Location     using (indexVoiceBeat; location; rectangle)
open import Midi         using (exportTracks; track→htrack)
open import MidiEvent    using (counterpoint→events; events→tracks; defaultVelocity)
open import Note         using (half; whole)
open import SmtInterface using (solveToMidi)
open import Variable     using (makeVars)

main : IO ⊤
main = do
  let ticksPerBeat = 2 -- (1 = quarter notes; 4 = 16th notes)
      source       = indexVoiceBeat jinglem
  song             ← solveToMidi half defaultConstraints source
  exportTracks "jingle.mid" ticksPerBeat (map track→htrack song)

  let
      range        = rectangle (location 1 1) (location 1 jingleLen)
      source       = makeVars range (indexVoiceBeat jingleCantusm)
  song             ← solveToMidi half defaultConstraints source
  exportTracks "jinglectr.mid" ticksPerBeat (map track→htrack song)
