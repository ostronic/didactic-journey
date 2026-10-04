```markdown
# SE GPG Files

A small Bash script for signing and encrypting files to your own GPG key, or decrypting them later.

- `encrypt` creates a signed, encrypted copy named `<original-filename>.gpg`.
- `decrypt` decrypts a `.gpg` file to the filename without the `.gpg` suffix.
- Original files are left unchanged.
- Existing output files are not overwritten.
- Filenames with spaces or newline characters are supported.

## Requirements

- Bash
- GnuPG (`gpg`)
- A GPG key with a secret key available for signing and a public key available for encryption

## Setup

Set the `KEY` value near the top of `SE_gpg-files.sh` to your key's full fingerprint:

```bash
gpg --list-secret-keys --keyid-format=long
```

Edit the script:

```bash
KEY='YOUR_KEY_FINGERPRINT'
```

Make it executable:

```bash
chmod +x SE_gpg-files.sh
```

You can also run it with Bash directly:

```bash
bash SE_gpg-files.sh encrypt file.txt
```

## Usage

```text
SE_gpg-files.sh encrypt|decrypt [file ...]
```

### Encrypt files

Pass one or more filenames after `encrypt`:

```bash
./SE_gpg-files.sh encrypt sso.txt mzx.7z
```

This creates:

```text
sso.txt.gpg
mzx.7z.gpg
```

The files are signed with your secret key and encrypted to your own public key, so you can decrypt them using the matching secret key.

### Decrypt files

Pass one or more `.gpg` filenames after `decrypt`:

```bash
./SE_gpg-files.sh decrypt sso.txt.gpg mzx.7z.gpg
```

This restores:

```text
sso.txt
mzx.7z
```

GPG checks the embedded signature during decryption and reports the verification result.

### Filenames containing spaces or newlines

Quote filenames so Bash passes each as one argument. For example, Bash's `$'...'` syntax can represent newlines:

```bash
./SE_gpg-files.sh encrypt $'file\nwith\nnewlines.txt'
```

### Read filenames from standard input

If no filenames are supplied as arguments, the script reads a **NUL-delimited** filename list from standard input. Use `find -print0` to produce one:

```bash
find /path/to/files -type f -print0 |
./SE_gpg-files.sh encrypt
```

To decrypt `.gpg` files:

```bash
find /path/to/files -type f -name '*.gpg' -print0 |
./SE_gpg-files.sh decrypt
```

NUL delimiters are used because filenames can contain newline characters. A regular newline-separated list is not safe for arbitrary filenames.

## Behavior and limitations

- The script processes files individually; it does not package folders into one archive.
- Encryption creates a separate `.gpg` file for every input file.
- Decryption only accepts filenames ending in `.gpg`.
- If the output file already exists, that input is skipped to avoid overwriting data.
- To decrypt the files, keep a secure backup of your GPG secret key and its passphrase.
- A signature confirms that the decrypted content matches the signature. It does not protect against someone replacing both the encrypted file and the public key you use to check it.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

```
