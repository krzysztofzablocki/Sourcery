## Usage

Sourcery is a command line tool `sourcery`, you can either run it manually or in a custom build phase using following command:

```
$ ./sourcery --sources <sources path> --templates <templates path> --output <output path> [--args arg1=value,arg2]
```

### Command line options

- `--sources` - Path to a source swift files. You can provide multiple paths using multiple `--sources` option.
- `--templates` - Path to templates. File or Directory. You can provide multiple paths using multiple `--templates` options.
- `--output` - Path to output. File or Directory.
- `--args` - Additional arguments to pass to templates. Each argument can have explicit value or will have implicit `true` value. Arguments should be separated with `,` without spaces. Arguments are accessible in templates via `argument.name`
- `--watch` [default: false] - Watch both code and template folders for changes and regenerate automatically.
- `--verbose` [default: false] - Turn on verbose logging for ignored entities
- `--disableCache` [default: false] - Turn off caching of parsed data
- `--prune` [default: false] - Prune empty generated files

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
```

You can use several `project` or `target` objects to scan multiple targets from one project or to scan multiple projects.
