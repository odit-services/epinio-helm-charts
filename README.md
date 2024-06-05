# A fork of the official Epinio Helm Charts extended with additional charts

Made to be used with the awesome [Epinio](https://github.com/epinio/epinio) by [ODIT.Services](https://odit.services)

## Usage

These are pretty much normal helm charts with some epinio-specific value names.
We reccomend using them with epinio, but you can use them for whatever you want to.

Official Epinio Docs: https://docs.epinio.io

## Charts

### Application charts

> Used to deploy epinio applications

* Application: Default epinio application chart customized with the ability to load additional ENV-values from a secret
* Application-Stateful: Epinio application as a statefulset with persistence (includes env from secret)
* Application-With-Volume: Epinio application with the ability to mount a volume to a configurable path (includes env from secret)

### Service charts

> Offer services that users can book in the epinio service marketplace

* Directus: A basic directus instance with ingress and persistence
