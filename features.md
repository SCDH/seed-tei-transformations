# Features

## Output

- HTML
- LaTeX

The project started with the idea to minimize redaction work an a
digital scholarly edition. Different output formats like preview while
editing, later web and print publications should have same content
guaranteed, so that only one review is required. The project achieved
this by developing and testing HTML and LaTeX output in parallel and
sharing common XSLT components. Hence the directory structure
`xsl/common/`, `xsl/html/`, `xsl/latex/`.

However, we currently cannot guarantee this feature, since output on
one format is developed as required.

One print edition with distinct critical apparatus and editorial
comments has been published.

## Internationalization

- supports right-to-left as well as left-to-right scripts
- provides fully configurable internationalization support for
  punctuation and text snippets added by the stylesheets e.g.
  scholarly terms like "omisit" in apparatus entries
  - by using JSON translation files
  - by using `i18next.js` javascript library and for HTML output
  - by internationalizing LaTeX, too
- requires TEI documents to have `@xml:lang` in the root element

### Currently Supported Languages

- en
- de
- ar

Adding a new language is as simple as adding a new one like
[`xsl/html/locales/en/translation.json`](xsl/html/locales/en/translation.json).

## Apparatus

- supports all methods of variant encoding (must be declared by
  `<variantEncoding>`)
  - parallel segmentation
  - double end-point, internal and external
  - location referenced, internal
  - simple encoding with multiple parallel `<seg>` elements contained
    in `<choice>`, where the content of the first segment is
    considered the lemma
- support an arbitrary number of distinct apparatus
  - critical apparatus
  - editorial comments
  - programming approach makes it easy to filter out elements by XPath
    expressions and send them to a arbitrarily defined apparatus, see
    [Wiki](https://github.com/SCDH/seed-tei-transformations/wiki/apparatus#generator-approach)
  - apparatus fontium
	- e.g. in LaTeX for the ALEA project to generate a register of
      cited passages of other poets
  - apparatus biblicus
	- e.g. in LaTeX for the ALEA project to generate a register of
      citations from Quran, see
      [Wiki](https://github.com/SCDH/seed-tei-transformations/wiki/alea-latex-quran)
- support a variety of ways of printing out (visualizing)
  - HTML, [demo](https://scdh.github.io/seed-tei-transformations/doc/crystals.html#TCAPVIZ)
	- popups
	- endnotes (footnotes) with backlinks
	- or linenumber-based referencing for short texts like poems
	- standalone apparatus to be scrolled with main text in sync
  - LaTeX: `reledmac`
- apparatus entries on the same text nodes get merged into a
  single entry by default

## Comments
Editorial comments can either be handled just as a type of apparatus
with lemma and lemma bracket to indicate the referenced passage.

- support an arbitrary number of separate comment types
- support the same ways of output as critical apparatus

## Other Supported Encoding

Most of the following supported elements will result in entries to the
critical apparatus, [as long as not configured
differently](https://github.com/SCDH/seed-tei-transformations/wiki/apparatus#generator-approach):

- `<choice>`
  - with nested `<corr>` + `<sic>` (also alone)
  - with nested `<orig>` + `<reg>` (also alone)
  - with nested `<abbr>` + `<expan>` (also alone)
  - with nested `<unclear>` alternatives (also alone)
- `<subst>`
  - with nested `<del>` + `<add>` (also alone)
- `<gap>`
- `<space>`
- `@reason` (partly)
- `@place`


## Named Entities

- output either as a type of comment or a type of critical apparatus
  or mixed into one of these

## Text Rendition

- supports TEI's `@rendition` and `@rend`

## Diplomatic vs. Reading Representation

- support for `<lb>` can be switched by stylesheet parameter, so that
  the HTML output either
  - has linebreaks from `<lb>` elements, with append hyphenation
    character for in-word line milestones encoded with `<lb
    break="no"/>` (diplomatic representation)
  - does not have linebreaks from `<lb>` elements, with stripped
    whitespace in case of in-word line milestones (reading
    representation)

## Text-Image Linking

Text-image linking is supported based on `<lb facs="#IDREF">`, where
`IDREF` points to a zone in the `<facsimile>` layer.

- based on milestone-like `<lb>` elements; no need to rewrite to `<l>`
  - whole line will be highlighted nevertheless
- propagation of mouse-over events with `IDREF` payload through
  iframe-borders through
  [post-message](https://developer.mozilla.org/de/docs/Web/API/Window/postMessage)
  protocol

## Textual Genres

For historical reasons, the support for lyrics is better developed
than for other textual genres. Other genres will be developed by
demand.

### Lyrics

- supports verses in `<l>` and grouped in `<lg>`
- supports `<caesura>`
  - aligned hemistiches
  - hemistich alignment by automatically inserted Kashida (Tatwir) in
    LaTeX/PDF output for Arabic poetry
  - may be supported by browsers some day
- variants with whole verses or caesuras have special get special
  representation with demarkation characters line "/" and "||"

### Prose

- navigatable text structure from `<div>` and `<divN>`


## Security

- written for running in a web service and with the specific security
  requirements of such a runtime environment in mind: Do not allow the
  caller to run arbitrary code by giving access to `<xsl:evaluate>`
