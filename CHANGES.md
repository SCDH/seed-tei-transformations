# Changes

## 0.15.0

- function `app:prints-sigla($context as node()) as xs:boolean` that decides if sigla are to be printed
- changed signature of named template `app:sigla`
- new package `xsl/latex/libpreamble.xsl`:
  - named template `preamble:preamble` (abstract) for generating a preamble without document class
  - named template `preamble:header` for generating a preamble with a
    document class, with buisness logic for full preamble, or a
    preamble for subfile for a mainfile/subfiles setup based on LaTeX
    package `subfiles`
  - named template `preamble:mainfile` for generating a mainfile in a
    subfiles/mainfile setup
- `xsl/projects/alea/latex/prose.xsl` ready for production

## 0.14.2-8

- fixed deployment workflow on github

## 0.14.1

- fixed issues #43 and #44
- improvements in LaTeX output

## 0.14.0

- support `@rendition` when using `xsl/html/librend.xsl` (issue #39)
- apparatus by `xsl/html/libapp2c.xsl`:
  - make repetion of lemma optional (issue #28)
	- via boolean stylesheet parameter `app:lemma`
	- having no lemma makes sense, e.g., in a popup apparatus
  - remove trailing entries delimiter `|` from popups and footnotes (issue #26)
  - allow sigla from `<wit>` instead of `@wit` (issue #27)

## 0.13.3

- `xsl/html/bible-with-popups.xsl`
  - registered as reusable package

## 0.13.2
- fixed typo in `xsl/html/libtext.xsl` and `xsl/html/libcouplet.xsl`

## 0.13.1

- SEED and ZIP packages contain `seed-tei-transformations` root folder,
  so that they confirm the Tooling infrastructure

## 0.13.0

- `xsl/common/libapp2.xsl` and `xsl/html/libapp2.xsl`:
  - new template named `app:line-based-apparatus-block` for CSS grid
    layout
- `xsl/html/libcouplet.xsl`
  - use CSS grid layout instead of a table
- `xsl/projects/alea/html/diwan.xsl`:
  - use these new grid-based layouts
- `xsl/html/libhtml.xsl`:
  - Removed all components related to scroll target calculation, which
    is now done by SEED Frontend Components alone.
- `xsl/html/libprose.xsl`:
  - new boolean switch
    `{http://scdh.wwu.de/transform/prose#}linebreaks` for optional
    output of `<lb/>` elements as `<br/>`
  - this allows output of structural or of diplomatic HTML projections

## 0.12.0

- `xsl/html/libi18n.xsl` and its javascript:
  - allow setting local initial language with the `@data-i18n-lang`
    attribute
- `xsl/projects/alea/html/diwan.xsl`:
  - sort readings and witnesses
  - surah titles initially in english

## 0.12.0

- `xsl/common/libapp2.xsl`
  - sort readings

## 0.11.3

- `xsl/html/libhtml.xsl`
  - offer stylesheet parameter to pass in multiple CSS or JS files,
    separated by comma
  - offer stylesheet parameters to set the html title
  - unit tests

## 0.11.2

- `*/libtext.xsl`: do not reproduce text from `<span>` or `<interp>`

## 0.11.1

- fixed `alea/html/diwan-recension.xsl`
- `html/libbiblio.xsl`:
  - added some basic formatting for bibliographic entries
- `alea/html/diwan.xsl`:
  - italics and other formatting in footnotes

## 0.11.0

- `alea/tei/extract-recension.xsl`:
  - extract all recensions into a `teiCorpus`
  - extract all recensions and write them into separate files via `xsl:result-document`
- `alea/html/diwan.xsl`:
  - allow passing in multiple CSS files separated by comma

## 0.10.0

- NEW: `xsl/html/xml-source.xsl`
  - transform to html given a view on the source, formatted through html
- `alea/html/diwan.xsl`:
  - stylesheet parameter for setting the font size
  - italics and quotes

## 0.9.2

- `alea/html/diwan.xsl`: fix handling of Tadmin and Isarah

## 0.9.1

- `libapp2.xsl`: handle internal location-references apparatus
- `prose-with-popups.xml` enable `html:js` and `html:css` in
  downstream packages

## 0.9.0

- NEW: `bible-with-popups.xsl`
  - a new transformation for text segmented in chapters and verses
    like the books of the bible
  - available as a SEED resource for end users

## 0.8.0

- NEW: `prose-with-popups.xsl`
  - a new simple transformation for prose to HTML with critical
	apparatus presented as popups
  - available as a SEED resource for end users
- `libapp2.xsl`
  - implemented template for presenting apparatus entries in popups
  - Made critical apparatus a bit more robust by not using `app`
	elements with `@from` or `@to` with values of pure `#`, which may
	come from invalid imports to TEI. This condition is only tested in
	the default XPath expression for the generation of apparatus
	entries for a double end-point attached apparatus.
- `libhtml.xsl`
  - added variable `html:extra-css` for overriding in downstream
    packages, while leaving `html:css` as a parameter to end users

## 0.7.0

- `libbiblio.xsl`: allow punctuation marks in `<bibl>` when pulling in
  the reference from the bibliography. This is required when multiple
  `<biblscope>`s are separated by comma etc.
- ALEA's bibliography: handle references to multipe Surah or verses of
  them.

## 0.6.0

- get lemma right for apparatus entries that are nested in `<span>`
  which defines the boundary with `@from` and `@to`. This is
  especially good for editorial or explanatorial notes on analytical
  spans.
- added hooks `app:pre-reading-text` and `app:post-reading-text` for
  getting extra text into apparatus entries
- ALEA's Diwan:
  - output for new conventions for annotating Tadmin and Isarah

## 0.5.0

- ALEA's `diwan.xsl` and `diwan-recension.xsl` are up to date and used
  in production the edition of the complete works of Ibn Nubatah
  - added `libbiblio.xsl` for pulling in informations from the
	bibliography for printing bibliographic references
  - added `extract-recension.xsl` for extracting a single one from a
    document that contains multiple recensions
  - added regression tests for the critical apparatus (ALEA)
- changed to Saxon Home Edition in default config file `saxon.xml`
  - Users of the oXygen plugin should now use `saxon.ee.xml` in order
    to get the features of the enterprise edition!
- added `libsource.xsl` for including information, that makes an
  (HTML) projection transparent on the XML source.
- fixes in `xsl/json/witnesses.xsl`
- improved documentation
- made git commit tags the single source of truth for version numbers
  of releases

## 0.4.0

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
