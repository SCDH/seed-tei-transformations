# XSL Transformations for TEI-XML documents


## Packages

### Using the packages

For using an XSLT package, the XSLT processor has to be told where to
find the package. The most convenient way to pass the information to
the Saxon processor is through a [Saxon configuration
file](https://www.saxonica.com/documentation11/index.html#!configuration/configuration-file).
Such a file can link packages names and versions to source files and
optionally compiled packages. [`saxon.xml`](saxon.xml) has such a
mapping for the packages defined in this directory.

The configuration file can be loaded from the commandline or in an
Oxygen project.

Please note, that the package names cannot be mapped to locations
through an XML catalog.

#### Oxygen

Distribution as plugin from URL

```
https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/seed-tei-transformations/descriptor.xml
```

##### Per scenario configuration

The Saxon config file can be declared on the basis of an XSLT
Transformation scenario. See [Oxygen
docs](https://www.oxygenxml.com/doc/versions/21.1/ug-editor/topics/advanced-saxon-xslt-options-x-publishing2.html).

What to enter into the URL field? If you want to use the packages via
the internet from a release of this project, enter `PAGES-CONFIG-URL`,
see below. If you want to use the packages from the plugin use
`PLUGIN-CONFIG-URL`, see below. While the latter enables you to run
your transformations even when your offline, the former requires you
to access the internet for each transformation based on the packages.


`PLUGIN-CONFIG-URL` is

```
${pluginDirURL(de.wwu.scdh.tei.seed-transformations)}/saxon.xml
```

`PAGES-CONFIG-URL` is

```
https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/seed-tei-transformations/saxon.xml
```



##### Project-wide configuration

A project-wide config is very helpful for developing XSL
transformations based on the packages. But please note, that it is not
needed for defining, distributing and using scenarios.

- See [Oxygen docs]
(https://www.oxygenxml.com/doc/versions/21.1/ug-editor/topics/preferences-xslt-saxon8.html)

(**Use a configuration file ("-config")**) how to set this up. This
option can be set on a *project-basis*. The options dialog is
accessible from the **Options** menu, menu item **Preferences**; then
descend into **XML**, **XSLT-Proc**, **XSLT**, **Saxon**,
**Saxon-HE/PE/EE**.

- See [tei-transform.xpr](tei-transform.xpr) for an example for a
project-wide configuration: The options named
`saxon.latest.config.file` and `saxon.latest.use.config.file` do the
thing.

#### Commandline

```{shell}
java -jar saxon.jar -config:PATH/TO/saxon.xml ...
```

You can also tell Saxon about every single package with the `-lib` option.

#### XSpec

For testing a stylesheet that uses a package, put a configuration into
the XSpec file, see [XSpec issue
762](https://github.com/xspec/xspec/issues/762).


### Package names

A package's name must be a URI. The name of each package in this
repository is its relative name in this repository prefixed with the
base URL
`https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/`.

For example the name of the package in
[xsl/libi18n.xsl](xsl/libi18n.xsl) is
`https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/libi18n.xsl`.


## Conventions

### Debugging

For performance reasons, debugging messages should be turned on or off
at compile time, not by a stylesheet parameter. We are using the
following compile time switch throughout the packages and stylesheets:

```
xsl:use-when="system-property('debug') eq 'true'"
```

To turn on debugging messages add `-Ddebug=true` when running the
program. E.g. for Saxon write:

```{shell}
java -Ddebug=true -jar saxon.jar ...
```
The same command line switch can be used for Oxygen.


### Qualified names and namespaces

**Every component** from package, that is accessible from the outside,
**must** have a *qualified* name! The same holds true for
parameters. This avoids name conflicts.

| scdh | |
| i18n | http://scdh.wwu.de/transform/i18n# |

To set a parameter value, use `{NAMESPACE}LNAME=...` to specify its
qualified name.



## Convenience

### `jar` files in `target/lib`

If you once ran `mvn package`, then `jar` files are present on `target/lib`.

```{shell}
java -cp target/lib/Saxon-HE-11.4.jar:target/lib/xmlresolver-4.5.1.jar net.sf.saxon.Transform ...
```

### Wrapper scripts

If you once ran `mvn package`, then the following wrapper scripts are
present in the project directory:

- `test.sh` is a wrapper around ant to run all the tests.

- `xslt.sh` is a wrapper around Saxon to run a transformation.

Example: run ALEA preview:

```{shell}
./xslt.sh -s:test/samples/BAlam53.tei.xml -xsl:xsl/projects/alea/preview.xsl -lib:xsl/html/libapp2.xsl:xsl/html/libi18n.xsl:xsl/common/libbetween.xsl:xsl/common/libcommon.xsl:xsl/html/libcouplet.xsl:xsl/html/librend.xsl:xsl/projects/alea/libmeta.xsl:xsl/html/libwit.xsl:xsl/common/libwit.xsl
```
