+++
title = "Using Keycard as an OpenPGP card"
date = "2025-11-04"

[taxonomies]
tags = ["keycard", "openpgp", "gpg", "smartcard"]

[extra]
repo_view = true
comment = true
+++

## What is Keycard?

A [Keycard](https://keycard.tech) is an Ethereum hardware wallet built on JavaCard technology. It securely stores private keys on-device and can sign Ethereum transactions and messages without ever exposing the keys. The device runs the [Keycard applets](https://github.com/keycard-tech/status-keycard) on a JavaCard chip.

## What is an OpenPGP Card?

The [OpenPGP Card](https://en.wikipedia.org/wiki/OpenPGP_card) is a smartcard specification that defines how cryptographic keys can be stored and used for OpenPGP operations like signing, verification, encryption, decryption, and authentication. JavaCards are commonly used to implement this specification.

## Using Keycard as an OpenPGP Card

Since Keycard is built on JavaCard technology, you can load an OpenPGP applet onto it and use it with GPG and other OpenPGP-compatible programs. [SmartPGP](https://github.com/github-af/SmartPGP) is a well-maintained JavaCard implementation of the OpenPGP Card specification that works perfectly with Keycard.

This guide walks through installing SmartPGP on your Keycard and configuring it for use with GPG.

### Install the SmartPGP Applet

**Prerequisites:** Ensure the PCSC daemon is running on your system.

1. Download the CAP file from the [SmartPGP releases page](https://github.com/github-af/SmartPGP/releases/tag/v1.23.0-javacard-3.0.4)
2. Download the [GlobalPlatformPro CLI tool](https://github.com/martinpaljak/GlobalPlatformPro)
3. Install the applet using Keycard's development key:
   ```bash
   $ gp --key c212e073ff8b4bbfaff4de8ab655221f --install ./SmartPGPApplet-rsa_up_to_4096.cap
   ```

**Troubleshooting:** If the Keycard dev key doesn't work, try without the `--key` flag to use default GlobalPlatform keys. For production cards, you may need to obtain the correct key from your card provider.

### Verify Installation

Check that the SmartPGP applet is properly installed:

```bash
$ gpg --card-status
Reader ...........: Alcor Link AK9563 00 00
Application ID ...: D276000124010304AFAF000000000000
Application type .: OpenPGP
Version ..........: 3.4
Manufacturer .....: unknown
Serial number ....: 00000000
Name of cardholder: [not set]
Language prefs ...: en
...
```

If you see output similar to above with "Application type: OpenPGP", the installation was successful.

### Configure the Card

Use GPG's card editing interface to configure your card. The [SmartPGP README](https://github.com/github-af/SmartPGP/blob/master/README.md) provides comprehensive configuration details.

```bash
$ gpg --edit-card
gpg/card> admin
Admin commands are allowed

gpg/card> help
quit           quit this menu
admin          show admin commands
help           show this help
list           list all available data
name           change card holder's name
url            change URL to retrieve key
fetch          fetch the key specified in the card URL
login          change the login name
lang           change the language preferences
salutation     change card holder's salutation
cafpr          change a CA fingerprint
forcesig       toggle the signature force PIN flag
generate       generate new keys
passwd         menu to change or unblock the PIN
verify         verify the PIN and list all data
unblock        unblock the PIN using a Reset Code
factory-reset  destroy all keys and data
kdf-setup      setup KDF for PIN authentication (on/single/off)
key-attr       change the key attribute
uif            change the User Interaction Flag
openpgp        switch to the OpenPGP app
```

**Important first steps:**
1. Change the default PIN with `passwd`
2. Generate new keys with `generate` (or import existing ones)
3. Set your name and other metadata as needed

## Use Cases

Once configured, your Keycard can be used as an OpenPGP smartcard for various security-critical operations:

1. **LUKS Decryption** - Decrypt LUKS-encrypted partitions at boot time by encrypting a LUKS keyfile with your GPG key, storing it in `/boot`, and using the Keycard to decrypt it during the boot process
2. **SSH Authentication** - Use GPG authentication keys for SSH access to remote servers
3. **Git Commit Signing** - Sign your Git commits with your GPG key stored on the card
4. **Email Encryption** - Encrypt and decrypt emails using tools like Thunderbird/Enigmail or Mutt
5. **File Encryption** - Encrypt sensitive files and documents with GPG

The key advantage is that your private keys never leave the secure element on the Keycard, providing hardware-backed security for all these operations.
