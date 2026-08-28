# protect — LOCAL FORK

Forked from `protect: ^1.0.0` ([pub.dev](https://pub.dev/packages/protect)).

## What changed

| Field | Original | Fork |
|---|---|---|
| spinCount | 100,000 | **10,000** |

`spinCount` is the PBKDF2 iteration count used by Office Open XML
(`Agile Encryption`) when deriving the AES key from a password. The package
calls `_convertPasswordToKey` **3 times** per encrypt — at the original value
that is **300,000 pure-Dart SHA-512 hashes** in JavaScript, which costs about
30 seconds for a 9 KB xlsx on Flutter web.

10,000 iterations × 3 = 30,000 hashes ≈ **3 seconds** on the same workload —
fast enough to keep the export UX pleasant while still requiring meaningful
GPU brute-force effort.

## Compatibility

`spinCount` is stored as a `UInt32BE` field in the EncryptionInfo XML header
(MS-OFFCRYPTO). Microsoft Excel reads this field back when verifying the
password and accepts any value; LibreOffice and other OOXML consumers behave
the same way. The encrypted package format is otherwise unchanged, so a file
produced by this fork opens with the same password in Excel as the upstream
package.

## Security note

10,000 SHA-512 iterations is the lower end of what is still defensible
against offline brute-force on consumer GPUs. Users must choose a strong
password; do not rely on the iteration count alone.

## How it is wired

`pubspec.yaml` (root) has:

```yaml
dependency_overrides:
  protect:
    path: lib/_vendor/protect
```

All `import 'package:protect/protect.dart' deferred as p;` sites in the app
remain unchanged — `dependency_overrides` redirects them to this folder.
