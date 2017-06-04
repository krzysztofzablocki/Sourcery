## Usage

Sourcery is a command line tool, you can either run it manually or in a custom build phase using following command:

```
$ ./sourcery --sources <sources path> --templates <templates path> --output <output path>
```

> Note: this command may be different depending on the way in which you installed Sourcery (see [Installing](installing.html))

### Command line options

- `--sources` - Path to a source swift files. You can provide multiple paths using multiple `--sources` option.
- `--templates` - Path to templates. File or Directory. You can provide multiple paths using multiple `--templates` options.
- `--output` [default: current path] - Path to output. File or Directory.
- `--config` [default: current path] - Path to config file. Directory. See [Configuration file](usage.html#configuration-file).
- `--args` - Additional arguments to pass to templates. Each argument can have explicit value or will have implicit `true` value. Arguments should be separated with `,` without spaces (i.e. `--args arg1=value,arg2`). Arguments are accessible in templates via `argument.name`
- `--watch` [default: false] - Watch both code and template folders for changes and regenerate automatically.
- `--verbose` [default: false] - Turn on verbose logging
- `--quiet` [default: false] - Turn off any logging, only emmit errors
- `--disableCache` [default: false] - Turn off caching of parsed data
- `--prune` [default: false] - Prune empty generated files
- `--version` - Display the current version of Sourcery
- `--help` - Display help information

### Configuration file

You can also provide arguments using `.sourcery.yml` file in project's root directory, like this:

```yaml
sources:
  - <sources path>
  - <sources path>
templates:
  - <templates path>
  - <templates path>
output:
  <output path>
args:
  <name>: <value>
```

You can exlude some sources or templates using `include` and `exclude` keys:

```yaml
sources:
  include:
    - <sources path to include>
    - <sources path to include>
  exclude:
    - <sources path to exclude>
    - <sources path to exclude>
templates:
  include:
    - <templates path to include>
    - <templates path to include>
  exclude:
    - <templates path to exclude>
    - <templates path to exclude>
```

You can provide either sources paths or targets to scan:

```yaml
project:
  file:
    <path to xcodeproj file>
  root:
    <path to project sources root>
  target:
    name: <target name>
    module: <module name> //required if different from target name
  exclude:
    - <sources path>
    - <sources path>
```

You can use several `project` or `target` objects to scan multiple targets from one project or to scan multiple projects.

> Note: Paths in configuration file are by default relative to configuration file path. If you want to specify absolute path start it with `/`.