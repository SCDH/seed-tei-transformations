# XSL Transformations for TEI-XML documents

This is a collection of XSL stylesheets and packages for TEI-XML
documents. [XSLT's package
system](https://www.w3.org/TR/xslt-30/#packages-and-modules) makes
them highly reusable. The transformations were written for running in
a web service and with the specific security requirements of such a
runtime environment in mind.

## Getting started

### Using the packages

For using an XSLT package, the XSLT processor has to be told where to
find the package. The most convenient way to pass this information to
a Saxon processor is through a [Saxon configuration
file](https://www.saxonica.com/documentation11/index.html#!configuration/configuration-file).
Such a file can link packages names and versions to source files and
optionally compiled packages. [`saxon.xml`](saxon.xml) has such a
mapping for the packages defined in this directory.

The Saxon configuration file can be loaded from the commandline or in
an Oxygen project.

Please note, that the package names cannot be mapped to locations
through an XML catalog.

A Saxon configuration file also contains information about the edition
(home, enterprise, professional) of the processor.

### Commandline

By running the following command, you will get a current Saxon HE
(home edition), wrapper scripts and a configuration file for this
edition.

```{shell}
./mvnw package
```

After a successful build there is:
1. a current Saxon HE and dependencies in `target/lib/*`
1. wrapper scripts for running XSLT in `target/bin/*`
1. `saxon.he.xml`, a Saxon configuration for the Home Edition, derived
   from `saxon.xsml`

Using all the packages is now as simple as running

```{shell}
target/bin/xslt.sh -config:saxon.he.xml -xsl:path-to-stylesheet.xsl -:s:path-to-source.xml
```

The commandline parameters are just passed through to the Saxon
processor. Run `target/bin/xslt.sh -?` for help or have a look at the
[Saxon
documentation](https://www.saxonica.com/documentation10/index.html#!using-xsl/commandline).

The wrapper scripts have [debugging](CONTRIBUTING.md#debugging) turned
on by default. Use Saxons `-o:...` option or the shell's `1>` and `2>`
redirection to fork output from stdout and stderr.

Alternatively, you can go the hard way and not let Maven help you and
use `-lib` to point to every package you want to use:

```{shell}
java -jar path-to-saxon.jar -lib:xsl/common/libentry2.xsl -lib:xsl/common/libapp2.xsl -lib:xsl/html/libapp2.xsl -lib:... -xsl:... -s:...
```


### Oxygen

This whole project ist distributed as plugin which can be installed from the following URL:

```
https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/seed-tei-transformations/descriptor.xml
```

There are no transformation scenarios in the distribution, because we
do not want to transformations with project-specific parameters, but
only reusable resources. However, the XSLT resources can be used to
declare scenarios based on it. We suggest to define such scenarios
either project-wide in the xpr-file or in a framework.

#### Per scenario configuration

The Saxon config file can be declared on the basis of an XSL
Transformation scenario. See [Oxygen
docs](https://www.oxygenxml.com/doc/versions/21.1/ug-editor/topics/advanced-saxon-xslt-options-x-publishing2.html).

What to enter into the URL field?

```
${pluginDirURL(de.wwu.scdh.tei.seed-transformations)}/saxon.xml
```

#### Project-wide configuration

A project-wide config is very helpful for developing XSL
transformations based on the packages. But please note, that it is not
needed for defining, distributing and using scenarios.

- See [Oxygen
  docs](https://www.oxygenxml.com/doc/versions/21.1/ug-editor/topics/preferences-xslt-saxon8.html)
  (**Use a configuration file ("-config")**) how to set this up. This
  option can be set on a *project-basis*. The options dialog is
  accessible from the **Options** menu, menu item **Preferences**;
  then descend into **XML**, **XSLT-Proc**, **XSLT**, **Saxon**,
  **Saxon-HE/PE/EE**.

- See [tei-transform.xpr](tei-transform.xpr) for an example for a
  project-wide configuration: The options named
  `saxon.latest.config.file` and `saxon.latest.use.config.file` do the
  thing.


### XSpec

For testing a stylesheet that uses a package, put a configuration into
the XSpec file, see [XSpec issue
762](https://github.com/xspec/xspec/issues/762). See any of the XSpec
files in this repository.



## SEED XML Transformer

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

There are many rules followed in this projects.

For details see the [contributing notes](CONTRIBUTING.md).


## Contributing

See [contributing notes](CONTRIBUTING.md)!


## License

MIT
