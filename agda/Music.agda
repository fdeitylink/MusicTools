{-# OPTIONS --without-K --safe #-}

module Music where

open import Prelude

open import Relation.Binary.PropositionalEquality using (sym; subst)
open import Data.Nat.Properties using (<⇒≤)

open import Nat
open import Note
open import Pitch
open import Interval

-- A point in the music grid, which can either be a tone,
-- a continuation of a previous tone, or a rest.
data Point : Set where
  tone : Pitch → Point
  hold : Pitch → Point
  rest : Point

data Melody (n : ℕ) : Set where
  melody : Vec Point n → Melody n

unmelody : {n : ℕ} → Melody n → Vec Point n
unmelody (melody ps) = ps

infixr 5 _m++_
_m++_ : {m n : ℕ} → Melody m → Melody n → Melody (m + n)
melody a m++ melody b = melody (a ++v b)

note→melody : (n : Note) → Melody (noteDuration n)
note→melody (tone zero    p) = melody []
note→melody (tone (suc d) p) = melody (tone p ∷ rep _ (hold p))
note→melody (rest _)         = melody (rep _ rest)

notes→melody : (ns : List Note) → Melody (sum (map noteDuration ns))
notes→melody []       = melody []
notes→melody (n ∷ ns) = note→melody n m++ notes→melody ns

pitches→melody : {n : ℕ} → (d : Duration) → (ps : Vec Pitch n) → Melody (n * d)
pitches→melody d ps = melody (cat (vmap (unmelody ∘ note→melody ∘ tone d) ps))

-- Assumes melody is well-formed in that a held note has the
-- same pitch as the note before it.
-- Does not consolidate rests.
melody→notes : {n : ℕ} → Melody n → List Note
melody→notes (melody m) = (reverse ∘ mn 0 ∘ reverse ∘ toList) m
  where mn : ℕ → List Point → List Note -- c is the number of held points
        mn c []            = []
        mn c (tone p ∷ ps) = tone (suc c) p ∷ mn 0 ps
        mn c (hold _ ∷ ps) = mn (suc c) ps
        mn c (rest ∷ ps)   = rest 1 ∷ mn 0 ps

transposePoint : ℤ → Point → Point
transposePoint k (tone p) = tone (transposePitch k p)
transposePoint k (hold p) = hold (transposePitch k p)
transposePoint k rest     = rest

transposeMelody : {n : ℕ} → ℤ → Melody n → Melody n
transposeMelody k = melody ∘ vmap (transposePoint k) ∘ unmelody

data Chord (n : ℕ) : Set where
  chord : Vec Point n → Chord n

unchord : {n : ℕ} → Chord n → Vec Point n
unchord (chord ps) = ps

-- We represent music as a v × d grid where v is the number of voices and d is the duration.
-- The primary representation is as parallel melodies (counterpoint).
data Counterpoint (v : ℕ) (d : ℕ): Set where
  cp : Vec (Melody d) v → Counterpoint v d

uncp : {v d : ℕ} → Counterpoint v d → Vec (Melody d) v
uncp (cp m) = m

-- An alternative representation of music is as a series of chords (harmonic progression).
data Harmony (v : ℕ) (d : ℕ): Set where
  harmony : Vec (Chord v) d → Harmony v d

unharmony : {v d : ℕ} → Harmony v d → Vec (Chord v) d
unharmony (harmony h) = h

pitches→harmony : {n : ℕ} (d : Duration) → (ps : Vec Pitch n) → Harmony n d
pitches→harmony zero    ps = harmony []
pitches→harmony (suc d) ps = harmony (chord (vmap tone ps) ∷ rep _ (chord (vmap hold ps)))

pitchPair→Harmony : (d : Duration) → PitchPair → Harmony 2 d
pitchPair→Harmony d (p , q) = pitches→harmony d (p ∷ q ∷ [])

pitchInterval→Harmony : (d : Duration) → PitchInterval → Harmony 2 d
pitchInterval→Harmony d = pitchPair→Harmony d ∘ pitchIntervalToPitchPair

{-
pitchIntervalsToCounterpoint : PitchInterval → Counterpoint
pitchIntervalsToCounterpoint = pitchPairToCounterpoint ∘ pitchIntervalToPitchPair
-}

addEmptyVoice : {v d : ℕ} → Harmony v d → Harmony (suc v) d
addEmptyVoice (harmony h) = harmony (vmap (chord ∘ (rest ∷_) ∘ unchord) h)

infixl 5 _+H+_
_+H+_ : {v d d' : ℕ} → Harmony v d → Harmony v d' → Harmony v (d + d')
h +H+ h' = harmony (unharmony h ++v unharmony h')

foldIntoHarmony : {k n : ℕ} (ds : Vec Duration (suc k)) → (pss : Vec (Vec Pitch n) (suc k)) → Harmony n (foldr₁ _+_ ds)
foldIntoHarmony (d ∷ [])      (ps ∷ [])        = pitches→harmony d ps
foldIntoHarmony (d ∷ d' ∷ ds) (ps ∷ ps' ∷ pss) = (pitches→harmony d ps) +H+ (foldIntoHarmony (d' ∷ ds) (ps' ∷ pss))

-- matrix transposition
mtranspose : {A : Set}{m n : ℕ} → Vec (Vec A n) m → Vec (Vec A m) n
mtranspose []         = rep _ []
mtranspose (xs ∷ xss) = zipWith _∷_ xs (mtranspose xss)

counterpoint→harmony : {v d : ℕ} → Counterpoint v d → Harmony v d
counterpoint→harmony = harmony ∘ vmap chord ∘ mtranspose ∘ vmap unmelody ∘ uncp

harmony→counterpoint : {v d : ℕ} → Harmony v d → Counterpoint v d
harmony→counterpoint = cp ∘ vmap melody ∘ mtranspose ∘ vmap unchord ∘ unharmony

-- Fix length of a melody, either truncating or padding with rests
fixLength : {m : ℕ} → (n : ℕ) → Melody m → Melody n
fixLength {m} n (melody ns) with <-∨-≥ n m
... | inj₁ n<m = melody (vtake n (subst (Vec Point) (sym (m+n-m=n n m {<⇒≤ n<m})) ns))
... | inj₂ m≤n = melody (subst (Vec Point) (m+n-m=n m n) (ns ++v rep (n - m ⟨ m≤n ⟩) rest))

holdToTone : Point → Point
holdToTone (tone p) = tone p
holdToTone (hold p) = tone p
holdToTone rest     = rest

firstHoldToTone : {n : ℕ} → Melody n → Melody n
firstHoldToTone (melody [])       = melody []
firstHoldToTone (melody (x ∷ xs)) = melody (holdToTone x ∷ xs)

-- Drop points, but convert any held tones to tones.
dropPoints : {n : ℕ} → (m : ℕ) → Melody (m + n) → Melody n
dropPoints m = firstHoldToTone ∘ melody ∘ vdrop m ∘ unmelody
