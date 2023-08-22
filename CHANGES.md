# Changes

## dev

- distribution for the SEED XML Transformer
- LaTeX
  - introduced functions for normalizing space in LaTeX output
  - fixed spacing problem after comments
- projects:
  - ALEA
	- improved LaTeX output for prose
    - enforced directory layout (common, html, latex)

## 0.3.1

- generate configuration for the SEED XML Transformer

## 0.3.0

- support for LaTeX using reledmac
- some improvements to HTML output


## 0.2.0

- various hooks
- supply output-specific librend.xsl
- use libapp2.xsl for all kinds of notes, that repeat the lemma, be it
  apparatus entries or editorial notes
- support `<supplied>`
- support `<quote>` and `<q>`
- unit tests

## 0.1.1

- ALEA's prose preview ro fit Andreas' needs
  - line width to 30em
  - font size to 1.2em

## 0.1.0

- introduced `libentry2` that provides common components for apparatus
  entries and editorial notes
- added `libnote2` package for editorial notes


## 0.0.6

- libi18n
  - fix link to `i18n.js`
- libtext
  - wrap front, body and back in their own divisions
- libprose
  - minimal support for verses
  - wrap pagebreaks in span
- alea-prose
  - CSS improved

## 0.0.5

- distribute as oXygen plugin:
  - the distributed files can be referenced with
	`${pluginDirURL(de.wwu.scdh.tei.seed-transformations)}/...`
- libapp2: support note-based apparatus
- libtext: support note-based apparatus
