#!/usr/bin/env python3

from collections import Counter

import numpy as np

# Melody for Jingle Bells
melody = [
    ('E', 3), ('E', 3), ('E', 3), ('E', 3), ('E', 3), ('E', 3), ('E', 3), ('G', 5), ('C', 1), ('D', 2), ('E', 3),
    ('F', 4), ('F', 4), ('F', 4), ('F', 4), ('F', 4), ('E', 3), ('E', 3), ('E', 3), ('E', 3), ('G', 5), ('G', 5), ('F', 4), ('D', 2), ('C', 1)
]

# Create Markov chain representing transitions between notes
notes = sorted(set(melody))

freqs = Counter(zip(melody, melody[1:]))

totals = {n: melody[:-1].count(n) for n in notes}

table = [[freqs[(n, m)] / totals[n] for m in notes] for n in notes]

# Create a new melody based on the chain, starting with E 3
new = []
n = ('E', 3)
for _ in range(100):
    i = np.random.choice(len(notes), p = table[notes.index(n)])
    m = notes[i]
    new.append(m)
    n = m

# Output Agda code for the melody
print('jingle : List (List SPitch)')
print('jingle = (' + ' ∷ '.join([f'{l} {o}' for (l, o) in new]) + ' ∷ []) ∷ []')

print('jingleLen : ℕ')
print(f'jingleLen = {len(new)}')
