+++
title = "Automated IPFS Deployment and Serving over eth.limo"
date = "2025-10-19"

[taxonomies]
tags = ["development", "ipfs", "ipns", "eth.limo", "ethereum", "ens"]

[extra]
repo_view = true
comment = true
+++

About my experience trying to publish my website to [0xferrous.eth.limo](https://0xferrous.eth.limo/)

---

## The Problem

You want to deploy your static site automatically to IPFS via CI/CD pipeline like
github actions.

## Some context

[IPFS](https://ipfs.io) is a decentralized open protocol for storing and serving data
over a peer-to-peer network.

[IPNS](https://docs.ipfs.tech/concepts/ipns/) is a mutable pointer to a content hash on IPFS.
It is necessary and useful to use IPNS for providing static links to users that work even
when you update the content of your files. Since the CID is a hash of the file content, it keeps
changing as the content changes.

[eth.limo](https://eth.limo) is an HTTPS gateway that reads ENS records to get the content hash
and uses it to serve the content at `<ens-name>.eth.limo`, making decentralized websites accessible
from regular browsers without special extensions or configuration.

So, the way to serve a website on IPFS is by uploading the whole static build of the website, usually
something like `build/` or `public/` folder to IPFS, use the CID of the root folder and update
your IPNS to point to the new CID on every update.

For continuous deployment from your github actions, it will automate this whole process.

## State of the art

There are not many github actions that can do ipfs deployment, etc. in a simple to use
interface.

I used claude to generate me a github action that uploads my `build` folder to ipfs and
also pin it at the same time using the [pinata api](https://pinata.cloud). However,
after I completed the integration, I realized pinata didn't support IPNS management.

So I had to look for another solution and found [filebase](https://filebase.com). They provide
IPNS management/integration via their API. So I ended up keeping using pinata for pinning the
content, but using filebase for updating the IPNS to the new CIDs.

You can find the code related to this and example github action usage in my own workflow:
1. The [actions code](https://github.com/0xferrous/0xferrous.github.io/tree/main/.github/actions/pinata-upload)
2. The [workflow code](https://github.com/0xferrous/0xferrous.github.io/blob/main/.github/workflows/zola.yml) is like the following snippet:
   ```yaml
   - name: IPFS publishing, pinning and IPNS update
     uses: ./.github/actions/pinata-upload
     with:
       pinata-jwt: ${{ secrets.PINATA_JWT }}
       build-location: './public'
       ipns-name: ${{ secrets.IPNS_NAME }}
       filebase-access-key: ${{ secrets.FILEBASE_ACCESS_KEY }}
       filebase-secret-key: ${{ secrets.FILEBASE_SECRET_KEY }}
   ```

So, with all this setup, I set the content hash on my ENS `0xferrous.eth` which now allows me to
serve this website using the `eth.limo` service making the website available on web2 internet and
browsers at `https://0xferrous.eth.limo`.


You can set the content hash on the [ENS frontend](https://app.ens.domains) under the records tab.

![Setting content hash using the ENS frontend](/images/ens-domains-content-hash-record-setting.png)

## Security Considerations

I am using filebase for IPNS management, which means they are managing the key that does the signing
of the IPNS record. So, if they are compromised, 0xferrous.eth.limo can be made to point to something
else and malicious. But, for now, this works.
