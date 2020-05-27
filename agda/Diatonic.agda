{-# OPTIONS --without-K #-}

module Diatonic where

open import Data.Bool       using (Bool; false; true; if_then_else_; _∧_)
open import Data.Fin        using (Fin; toℕ; #_; _≟_) renaming (zero to fz; suc to fs)
open import Data.Nat        using (ℕ; _+_; zero; suc; _≡ᵇ_; _∸_)
open import Data.Nat.DivMod using (_mod_)
open import Data.Vec        using (Vec; []; _∷_; head; foldl; take; reverse; lookup)

open import Function using (_∘_)

open import Interval        using (Interval; interval; maj3; min3; _==_)
open import Pitch

data Mode : Set where
  major : Mode
  minor : Mode

data DiatonicDegree : Set where
  diatonicDegree : Fin diatonicScaleSize → DiatonicDegree

undd : DiatonicDegree → Fin diatonicScaleSize
undd (diatonicDegree d) = d

infix 4 _≡ᵈ_
_≡ᵈ_ : DiatonicDegree → DiatonicDegree → Bool
diatonicDegree d ≡ᵈ diatonicDegree e = toℕ d ≡ᵇ toℕ e

-- round down
pitchClass→Degree : Mode → PitchClass → DiatonicDegree

pitchClass→Degree major (pitchClass fz)                                                        = diatonicDegree (# 0)
pitchClass→Degree major (pitchClass (fs fz))                                                   = diatonicDegree (# 0)
pitchClass→Degree major (pitchClass (fs (fs fz)))                                              = diatonicDegree (# 1)
pitchClass→Degree major (pitchClass (fs (fs (fs fz))))                                         = diatonicDegree (# 1)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs fz)))))                                    = diatonicDegree (# 2)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs (fs fz))))))                               = diatonicDegree (# 3)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs (fs (fs fz)))))))                          = diatonicDegree (# 3)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs (fs (fs (fs fz))))))))                     = diatonicDegree (# 4)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs fz)))))))))                = diatonicDegree (# 4)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs (fs fz))))))))))           = diatonicDegree (# 5)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs (fs (fs fz)))))))))))      = diatonicDegree (# 5)
pitchClass→Degree major (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs (fs (fs (fs fz)))))))))))) = diatonicDegree (# 6)

pitchClass→Degree minor (pitchClass fz)                                                        = diatonicDegree (# 0)
pitchClass→Degree minor (pitchClass (fs fz))                                                   = diatonicDegree (# 0)
pitchClass→Degree minor (pitchClass (fs (fs fz)))                                              = diatonicDegree (# 1)
pitchClass→Degree minor (pitchClass (fs (fs (fs fz))))                                         = diatonicDegree (# 2)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs fz)))))                                    = diatonicDegree (# 2)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs (fs fz))))))                               = diatonicDegree (# 3)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs (fs (fs fz)))))))                          = diatonicDegree (# 3)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs (fs (fs (fs fz))))))))                     = diatonicDegree (# 4)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs fz)))))))))                = diatonicDegree (# 5)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs (fs fz))))))))))           = diatonicDegree (# 5)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs (fs (fs fz)))))))))))      = diatonicDegree (# 6)
pitchClass→Degree minor (pitchClass (fs (fs (fs (fs (fs (fs (fs (fs (fs (fs (fs fz)))))))))))) = diatonicDegree (# 6)

degree→PitchClass : Mode → DiatonicDegree → PitchClass

degree→PitchClass major (diatonicDegree fz)                               = pitchClass (# 0)
degree→PitchClass major (diatonicDegree (fs fz))                          = pitchClass (# 2)
degree→PitchClass major (diatonicDegree (fs (fs fz)))                     = pitchClass (# 4)
degree→PitchClass major (diatonicDegree (fs (fs (fs fz))))                = pitchClass (# 5)
degree→PitchClass major (diatonicDegree (fs (fs (fs (fs fz)))))           = pitchClass (# 7)
degree→PitchClass major (diatonicDegree (fs (fs (fs (fs (fs fz))))))      = pitchClass (# 9)
degree→PitchClass major (diatonicDegree (fs (fs (fs (fs (fs (fs fz))))))) = pitchClass (# 11)

degree→PitchClass minor (diatonicDegree fz)                               = pitchClass (# 0)
degree→PitchClass minor (diatonicDegree (fs fz))                          = pitchClass (# 2)
degree→PitchClass minor (diatonicDegree (fs (fs fz)))                     = pitchClass (# 3)
degree→PitchClass minor (diatonicDegree (fs (fs (fs fz))))                = pitchClass (# 5)
degree→PitchClass minor (diatonicDegree (fs (fs (fs (fs fz)))))           = pitchClass (# 7)
degree→PitchClass minor (diatonicDegree (fs (fs (fs (fs (fs fz))))))      = pitchClass (# 8)
degree→PitchClass minor (diatonicDegree (fs (fs (fs (fs (fs (fs fz))))))) = pitchClass (# 10)

pitch→DegreeCMajor : Pitch → DiatonicDegree
pitch→DegreeCMajor = pitchClass→Degree major ∘ pitchToClass

d1 d2 d3 d4 d5 d6 d7 : DiatonicDegree
d1 = diatonicDegree (# 0)
d2 = diatonicDegree (# 1)
d3 = diatonicDegree (# 2)
d4 = diatonicDegree (# 3)
d5 = diatonicDegree (# 4)
d6 = diatonicDegree (# 5)
d7 = diatonicDegree (# 6)

data Accidental : Set where
  𝄫 : Accidental
  ♭ : Accidental
  ♮ : Accidental
  ♯ : Accidental
  𝄪 : Accidental

-- pitch class letter name with accidental
data PC : Set where
  A : Accidental → PC
  B : Accidental → PC
  C : Accidental → PC
  D : Accidental → PC
  E : Accidental → PC
  F : Accidental → PC
  G : Accidental → PC

-- Accidental modifier. To stay in ℕ we map 𝄫 to 0.
accMod : Accidental → ℕ
accMod 𝄫 = 0
accMod ♭ = 1
accMod ♮ = 2
accMod ♯ = 3
accMod 𝄪 = 4

flatten : Accidental → Accidental
flatten 𝄫 = 𝄫 -- should make this an error
flatten ♭ = 𝄫
flatten ♮ = ♭
flatten ♯ = ♮
flatten 𝄪 = ♯

sharpen : Accidental → Accidental
sharpen 𝄫 = ♭
sharpen ♭ = ♮
sharpen ♮ = ♯
sharpen ♯ = 𝄪
sharpen 𝄪 = 𝄪 -- should make this an error

-- Convert raw PC letter to ℕ (in range [0,11]); C normalized to 0
letter→ℕ : PC → ℕ
letter→ℕ (A _) = 9
letter→ℕ (B _) = 11
letter→ℕ (C _) = 0
letter→ℕ (D _) = 2
letter→ℕ (E _) = 4
letter→ℕ (F _) = 5
letter→ℕ (G _) = 7

accidental : PC → Accidental
accidental (A x) = x
accidental (B x) = x
accidental (C x) = x
accidental (D x) = x
accidental (E x) = x
accidental (F x) = x
accidental (G x) = x

-- Convert PC to PitchClass with C♮ normalized to 0.
pcToC : PC → PitchClass
pcToC pc = pitchClass ((letter→ℕ pc + accMod (accidental pc) + 10) mod 12)

data Key : Set where
  key : PC → Mode → Key

data Step : Set where
  half  : Step
  whole : Step

stepUp : Step → PC → PC

stepUp half  (A x) = B (flatten x)
stepUp half  (B x) = C x
stepUp half  (C x) = D (flatten x)
stepUp half  (D x) = E (flatten x)
stepUp half  (E x) = F x
stepUp half  (F x) = G (flatten x)
stepUp half  (G x) = A (flatten x)

stepUp whole (A x) = B x
stepUp whole (B x) = C (sharpen x)
stepUp whole (C x) = D x
stepUp whole (D x) = E x
stepUp whole (E x) = F (sharpen x)
stepUp whole (F x) = G x
stepUp whole (G x) = A x

scaleSteps : Mode → Vec Step diatonicScaleSize
scaleSteps major = whole ∷ whole ∷ half ∷ whole ∷ whole ∷ whole ∷ half ∷ []
scaleSteps minor = whole ∷ half ∷ whole ∷ whole ∷ half ∷ whole ∷ whole ∷ []

scaleNotes : Key → Vec PC diatonicScaleSize
scaleNotes (key pc m) =
  let f : {n : ℕ} → Vec PC (suc n) → Step → Vec PC (suc (suc n))
      f pcs step = stepUp step (head pcs) ∷ pcs
  in reverse (foldl (Vec PC ∘ suc) f (pc ∷ []) (take 6 (scaleSteps m)))

data Root : Set where
  I   : Root
  II  : Root
  III : Root
  IV  : Root
  V   : Root
  VI  : Root
  VII : Root

data Quality : Set where
  maj : Quality
  min : Quality
  aug : Quality
  dim : Quality

_dd+_ : DiatonicDegree → ℕ → DiatonicDegree
(diatonicDegree d) dd+ n = diatonicDegree ((toℕ d + n) mod diatonicScaleSize)

thirdUp : DiatonicDegree → DiatonicDegree
thirdUp d = d dd+ 2

data Triad : Set where
  triad : Root → Quality → Triad

root→DiatonicDegree : Root → DiatonicDegree
root→DiatonicDegree I   = d1
root→DiatonicDegree II  = d2
root→DiatonicDegree III = d3
root→DiatonicDegree IV  = d4
root→DiatonicDegree V   = d5
root→DiatonicDegree VI  = d6
root→DiatonicDegree VII = d7

diatonicDegree→Root : DiatonicDegree → Root
diatonicDegree→Root (diatonicDegree fz)                               = I
diatonicDegree→Root (diatonicDegree (fs fz))                          = II
diatonicDegree→Root (diatonicDegree (fs (fs fz)))                     = III
diatonicDegree→Root (diatonicDegree (fs (fs (fs fz))))                = IV
diatonicDegree→Root (diatonicDegree (fs (fs (fs (fs fz)))))           = V
diatonicDegree→Root (diatonicDegree (fs (fs (fs (fs (fs fz))))))      = VI
diatonicDegree→Root (diatonicDegree (fs (fs (fs (fs (fs (fs fz))))))) = VII

rootQuality : Mode → Root → Quality

rootQuality major I   = maj
rootQuality major II  = min
rootQuality major III = min
rootQuality major IV  = maj
rootQuality major V   = maj
rootQuality major VI  = min
rootQuality major VII = dim

rootQuality minor I   = min
rootQuality minor II  = dim
rootQuality minor III = maj
rootQuality minor IV  = min
rootQuality minor V   = min
rootQuality minor VI  = maj
rootQuality minor VII = maj

-- Lower interval is first.
triadQuality : Interval → Interval → Quality
triadQuality i1 i2 =
  if      (i1 == maj3) ∧ (i2 == min3) then maj
  else if (i1 == min3) ∧ (i2 == maj3) then min
  else if (i1 == min3) ∧ (i2 == min3) then dim
  else if (i1 == maj3) ∧ (i2 == maj3) then aug
  else maj -- should not happen

makeTriad : Mode → Root → Triad
makeTriad m r =
  let d1 = root→DiatonicDegree r
      d2 = thirdUp d1
      d3 = thirdUp d2
      p1 = unPitchClass (degree→PitchClass m d1)
      p2 = unPitchClass (degree→PitchClass m d2)
      p3 = unPitchClass (degree→PitchClass m d3)
      i1 = interval (toℕ p2 ∸ toℕ p1)
      i2 = interval (toℕ p3 ∸ toℕ p2)
  in triad r (triadQuality i1 i2)

triadNotes : Key → Root → Vec PC 3
triadNotes k root =
  let d1 = root→DiatonicDegree root
      d2 = thirdUp d1
      d3 = thirdUp d2
      ns = scaleNotes k
  in lookup ns (undd d1) ∷ lookup ns (undd d2) ∷ lookup ns (undd d3) ∷ []

diatonic7thNotes : Key → Root → Vec PC 4
diatonic7thNotes k root =
  let d1 = root→DiatonicDegree root
      d2 = thirdUp d1
      d3 = thirdUp d2
      d4 = thirdUp d3
      ns = scaleNotes k
  in lookup ns (undd d1) ∷ lookup ns (undd d2) ∷ lookup ns (undd d3) ∷ lookup ns (undd d4) ∷ []

a1 = triadNotes (key (G ♭) major) III
a2 = diatonic7thNotes (key (G ♯) major) V
a3 = diatonic7thNotes (key (E ♮) major) V
a4 = diatonic7thNotes (key (B ♭) major) VII
a5 = scaleNotes (key (G ♯) major)
a6 = scaleNotes (key (G ♭) major)
a7 = scaleNotes (key (B ♮) minor)
