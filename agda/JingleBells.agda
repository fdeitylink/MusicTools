{-# OPTIONS --without-K --safe #-}

module JingleBells where

open import Prelude

open import Music
open import Note
open import Pitch using (Octave)
open import Symbolic hiding (C; D; E; F; G; A; B)

C D E F G A B : Octave → SPitch
C = sp C♮
D = sp D♮
E = sp E♮
F = sp F♮
G = sp G♮
A = sp A♮
B = sp B♮

jingle : List (List SPitch)
jingle = (G 5 ∷ C 1 ∷ D 2 ∷ C 1 ∷ D 2 ∷ E 3 ∷ G 5 ∷ C 1 ∷ D 2 ∷ C 1 ∷ D 2 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ G 5 ∷ C 1 ∷ D 2 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ G 5 ∷ G 5 ∷ C 1 ∷ D 2 ∷ C 1 ∷ D 2 ∷ E 3 ∷ E 3 ∷ F 4 ∷ F 4 ∷ F 4 ∷ E 3 ∷ F 4 ∷ F 4 ∷ D 2 ∷ C 1 ∷ D 2 ∷ E 3 ∷ E 3 ∷ F 4 ∷ F 4 ∷ D 2 ∷ C 1 ∷ D 2 ∷ C 1 ∷ D 2 ∷ E 3 ∷ E 3 ∷ E 3 ∷ F 4 ∷ F 4 ∷ F 4 ∷ F 4 ∷ D 2 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ G 5 ∷ G 5 ∷ C 1 ∷ D 2 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ F 4 ∷ F 4 ∷ F 4 ∷ F 4 ∷ F 4 ∷ F 4 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ F 4 ∷ F 4 ∷ E 3 ∷ F 4 ∷ F 4 ∷ F 4 ∷ E 3 ∷ E 3 ∷ F 4 ∷ D 2 ∷ E 3 ∷ E 3 ∷ E 3 ∷ E 3 ∷ []) ∷ []

jingleLen : ℕ
jingleLen = 100

jinglem : List (List MPitch)
jinglem = map (map !!) jingle

jingleCantusm : List (List MPitch)
jingleCantusm = (replicate jingleLen (!! (C 4))) ∷ jinglem
