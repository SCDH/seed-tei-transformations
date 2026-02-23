[![Tests](https://github.com/SCDH/seed-tei-transformations/actions/workflows/test.yaml/badge.svg)](https://github.com/SCDH/seed-tei-transformations/actions/workflows/test.yaml)
[![Release](https://github.com/SCDH/seed-tei-transformations/actions/workflows/deploy.yaml/badge.svg)](https://github.com/SCDH/seed-tei-transformations/actions/workflows/deploy.yaml)

# SEED TEI Transformations

This project is a collection of XSL stylesheets and packages for
transforming TEI-XML documents to HTML and to LaTeX. It offers low
level building blocks for putting together sophisticated
transformations, as well example transformations put together from
these low building blocks. The [XSLT package
system](https://www.w3.org/TR/xslt-30/#packages-and-modules) makes the
building blocks highly reusable.

Documentation:

1. [Features](features.md)
1. [transformed encoding snippets](https://scdh.github.io/seed-tei-transformations/doc/crystals.html)
1. [Wiki](https://github.com/SCDH/seed-tei-transformations/wiki)!

This project is part of the SEED, which is an recursive acronym for
SEED *E*lectronic *Ed*itions, which is to mean *digital* scholarly
editions (DSEs). If you dislike recursion, take some iterations on
SCDH DSE until you got the letters in right order.

## Getting started

For using an XSLT package, the XSLT processor has to be told where to
find the package. The most convenient way to pass this information to
a Saxon processor is through a [Saxon configuration
file](https://www.saxonica.com/documentation11/index.html#!configuration/configuration-file).
Such a file can link packages names and versions to source files and
optionally compiled packages. [`saxon.xml`](saxon.xml) has such a
mapping for the packages defined in this repository.

The Saxon configuration file can be loaded from the commandline, from
an Ant XSLT target, or in an Oxygen project.

Please note, that the package names cannot be mapped to locations
through an XML catalog.

A Saxon configuration file also contains information about the edition
(home, enterprise, professional) of the processor.

### Commandline

If you have Saxon HE at hand, simply use it as follows.
 
1. Download released zip package of the project and unzip it with our
   accustomed tools. They are available as [release
   assets](https://github.com/SCDH/seed-tei-transformations/releases/).
2. Setup the class path for Saxon. E.g. on Linux:
   ```shell
   export SAXON_CMD="java -cp ... net.sf.saxon.Transform"
   ```
3. Transform:
   ```shell
   $SAXON_CMD -config:seed-tei-transformations/saxon.he.html.xml -xsl:seed-tei-transformations/xsl/html/prose-with-popups.xsl -s:YOUR_TEI.xml
   ```

If you don't have Saxon HE at hand but want to try from the command
line, have a look into the
[Wiki](https://github.com/SCDH/seed-tei-transformations/wiki/tooling)
and use the project's Tooling environment to get all you need.


### Oxygen

This whole project ist distributed as a plugin which can be installed from the following URL:

```
https://scdh.github.io/seed-tei-transformations/descriptor.xml
```

Unfortunately, it is not possible to provide transformation scenarios
from a plugin. However, there is a `scenarios` file in the [release
assets](https://github.com/SCDH/seed-tei-transformations/releases/)
which you can download and import to your project. These imported
scenarios will then use the packages from the plugin.

Further information on writing your own transformation scenarios using
this plugin is given in the
[Wiki](https://github.com/SCDH/seed-tei-transformations/wiki/oxygen).


### SEED XML Transformer

Running `./mvnw clean package` makes a distribution that can be
deployed as transformation resources on a *SEED XML Transformer*
RESTful web service.  The bundled resources are in
`target/seed-tei-transformations-VERSION-seed-resources.tar.zip` which
can be passed into the Kybernetes deployment as a
[configMap](https://kubernetes.io/docs/concepts/configuration/configmap/).

The tar ball contains a yaml file that defines all resources available
in the REST service. It is also in `target/seed-config.yaml` after
running Maven. Its content is determined by the `transformationSet`
using the `${seed-config-xsl.url}` as `stylesheet` in
[`pom.xml`](pom.xml).



## Conventions

There are many rules and conventions followed throughout this
projects. For details see the [contributing notes](CONTRIBUTING.md).


## Contributing

See [contributing notes](CONTRIBUTING.md)!


## License

MIT
