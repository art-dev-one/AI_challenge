**User**

find a bug in the code

---

**Cursor**

```javascript
stepRotors() {
  if (this.rotors[2].atNotch()) this.rotors[1].step();
  if (this.rotors[1].atNotch()) this.rotors[0].step();
  this.rotors[2].step();
}
```

Looking at this Enigma machine implementation, I can spot a significant bug in the encryption process.

## **Bug Found: Missing Second Plugboard Pass**

There's a critical bug in the `encryptChar` method on lines 63-77. The **plugboard is only applied once** instead of twice.

### The Problem

In the real Enigma machine, the signal passes through the plugboard **twice**:
1. **Before** entering the rotors
2. **After** exiting the rotors

But look at the current `encryptChar` method:

```63:77:enigma_source.js
encryptChar(c) {
  if (!alphabet.includes(c)) return c;
  this.stepRotors();
  c = plugboardSwap(c, this.plugboardPairs);        // ✅ First plugboard pass
  for (let i = this.rotors.length - 1; i >= 0; i--) {
    c = this.rotors[i].forward(c);
  }

  c = REFLECTOR[alphabet.indexOf(c)];

  for (let i = 0; i < this.rotors.length; i++) {
    c = this.rotors[i].backward(c);
  }

  return c;                                          // ❌ Missing second plugboard pass!
}
```

### The Correct Signal Path Should Be:
1. **Plugboard** → swap letter pairs
2. **Rotors forward** → through rotors right to left  
3. **Reflector** → bounce signal back
4. **Rotors backward** → through rotors left to right
5. **Plugboard again** → swap letter pairs again ← **THIS IS MISSING!**

### The Fix

The last line should be:
```javascript
return plugboardSwap(c, this.plugboardPairs);
```

Instead of:
```javascript
return c;
```

### Why This Matters

Without the second plugboard pass:
- **Encryption/decryption won't be symmetric** (crucial for Enigma)
- **Messages won't decrypt properly** with the same settings
- **The simulation is historically inaccurate** - real Enigma machines always applied plugboard twice

This bug would make encrypted messages impossible to decrypt correctly, completely breaking the Enigma simulation!

```javascript
encryptChar(c) {
  if (!alphabet.includes(c)) return c;
  this.stepRotors();
  c = plugboardSwap(c, this.plugboardPairs);        // ✅ First plugboard pass
  for (let i = this.rotors.length - 1; i >= 0; i--) {
    c = this.rotors[i].forward(c);
  }

  c = REFLECTOR[alphabet.indexOf(c)];

  for (let i = 0; i < this.rotors.length; i++) {
    c = this.rotors[i].backward(c);
  }

  return c;                                          // ❌ Missing second plugboard pass!
}
```

```javascript
return plugboardSwap(c, this.plugboardPairs);
```

```javascript
return c;
```
