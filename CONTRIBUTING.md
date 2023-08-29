# Contributing

## Rules and Conventions

### Package names

A package's name must be a URI. The name of each package in this
repository is its relative name in this repository prefixed with the
following base URL.

```
https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/
```

For example the name of the package in
[xsl/libi18n.xsl](xsl/html/libi18n.xsl) is
`https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl`.


### Debugging

For performance reasons, debugging messages should be turned on or off
at compile time, not by a stylesheet parameter. We are using the
following compile time switch throughout the whole project:

```
@use-when="system-property('debug') eq 'true'"
```

To turn on debugging messages add `-Ddebug=true` when running the
program. E.g. for Saxon write:

```{shell}
java -Ddebug=true -jar saxon.jar ...
```
The same command line switch can be used for Oxygen.

The wrapper scripts have debugging turned on by default. Use `1>` and
`2>` to fork output from stdin and stderr.

### Directory structure

- `xsl` container for XSLT, except XSLT for managing this project
- `xsl/html`: XSLT for html output
- `xsl/json`: XSLT for json output
- `xsl/latex`: XSLT for LaTeX output
- `xsl/common`: XSLT common to all outputs
- `xsl/projects/NAME`: XSLT specific to project NAME (while the above
  are generic). Each project-specific folder should again contain
  subfolders named after their output format.

### Qualified names and namespaces

**Every component** from a package, that is **accessible from the outside**,
**must** have a **qualified** name! The same holds true for
parameters. This avoids name conflicts.

To set a parameter value, use `{NAMESPACE}LNAME=...` to specify its
qualified name.

This project use `http://scdh.wwu.de/transform/` as a base URI for
namespace names and append an other semantically motivated path
element and a hash tag, like in `http://scdh.wwu.de/transform/i18n#`
for components dealing with internationalization.

### Names of templates, functions, variables etc.

Do not duplicate work, that the XSLT compiler does for you! Keep names
of components in the semantic domain.

Examples of bad practise:

1. you declare a tunnel parameter for passing around wine and prefix its name with `tp`: `tpWine`
2. you declare a function for drinking and prefix its name with `fun`: `funDrink`


Instead:

- `wine`
- `drink`

More examples of this bad practise is found in the TEI's current
naming conventions for XSLT, however they are traded under the name of
good practise.

### Types everywhere

Declare the type of every variable, function, parameter.

Stylesheet parameters without declared type

Even declare the type of the result set of templates, at least if it's
not a node set.

### No XSLT 1.0

XSLT 1.0 was an untyped language. We do not use it in this
project. Use XSLT 2.0 or later.


### xsl:evaluate

You can use `xsl:evaluate`. However: **Do not pass any content to its
`xpath` input, that can be determined by runtime input** (source,
runtime parameters).

You can write super flexible great code using `xsl:evaluate`. But use
a static variable for determining its xpath input! Override this
variable for project-specific configurations, instead of passing in the
configuration as a runtime parameter.

This rule is for security!

Consider [**abstract
components**](https://www.w3.org/TR/xslt-30/#dt-visibility) as an
alternative!

### Write XSpec tests

Write [XSpec](https://github.com/xspec/xspec/wiki) tests. Learn from
the xspec files in this repository.

Add your tests to the [Ant test runner](build.xml).

Run tests with

```
target/bin/test.sh # all tests
```

```
target/bin/test.sh TARGET-NAME # single test
```

**Every transformation distributed for the SEED XML Transformer must
be tested.** At least is must compile. Otherwise, the REST service
will not pass its health test.


### Register packages

Register new packages in the `saxon.xml` configuration file.



## Pull Requests

Pull requests **will not be accepted**, if they are made on the
default or production branch directly. Use a feature branch!

## Keep changes.md up to date

Report changes in [`changes.md`](changes.md).

## Maven

The [Maven pom file](pom.xml) is the single point of truth in this
project. It keeps the magic version number.

It can install everything required for this project.

It knows how to build the various distributions of this project.
