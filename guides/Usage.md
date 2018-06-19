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
- `--config` [default: current path] - Path to config file. File or Directory. See [Configuration file](usage.html#configuration-file).
- `--args` - Additional arguments to pass to templates. Each argument can have explicit value or will have implicit `true` value. Arguments should be separated with `,` without spaces (i.e. `--args arg1=value,arg2`) or should be passed one by one (i.e `--args arg1=value --args arg2`). Arguments are accessible in templates via `argument.name`. To pass in string you should use escaped quotes (`\"`) .
- `--watch` [default: false] - Watch both code and template folders for changes and regenerate automatically.
- `--verbose` [default: false] - Turn on verbose logging
- `--quiet` [default: false] - Turn off any logging, only emmit errors
- `--disableCache` [default: false] - Turn off caching of parsed data
- `--prune` [default: false] - Prune empty generated files
- `--version` - Display the current version of Sourcery
- `--help` - Display help information.
- `--cacheBasePath` - Path to Sourcery internal cache (available only in configuration file)

Use `--help` to see the list of all available options.

### Configuration file

You can also provide arguments using configuration file. Some of the configuration features (like excluding files) are only 
available when using configuration file. You provide path to this file using `--config` command line option.
If you provide path to directory Sourcery will search for file `.sourcery.yml` in this directory. You can also provide
path to config file itself. By default Sourcery will search for `.sourcery.yml` in your current path.

Configuration file should be a valid Yaml file, like this:

```yaml
sources:
  - <sources path> # you can provide either single path or several paths using `-`
  - <sources path>
templates:
  - <templates path> # as well as for templates
  - <templates path>
output:
  <output path> # note that there is no `-` here as only single output path is supported
args:
  <name>: <value>
```

#### Sources

You can provide sources using paths to directories or specific files.

```yaml
sources:
  - <sources dir path>
  - <source file path>
```

Or you can provide project which will be scanned and which source files will be processed. You can use several `project` or `target` objects to scan multiple targets from one project or to scan multiple projects.

```yaml
project:
  file: <path to xcodeproj file>
  target:
    name: <target name>
    module: <module name> //required if different from target name
```

#### Excluding sources or templates

You can specifiy paths to sources files that should be scanned using `include` key and paths that should be excluded using `exclude` key. These can be directory or file paths.

```yaml
sources:
  include:
    - <sources path to include>
    - <sources path to include>
  exclude:
    - <sources path to exclude>
    - <sources path to exclude>
```

You can also specify path to include and exclude for templates.
When source is a project you can use `exclude` key to exclude some of its source files.

```yaml
project:
  file: ...
  target: ...
  exclude:
    - <sources path>
    - <sources path>
```

#### Output

You can specify the output file using `output` key. This can be a directory path or a file path. If it's a file path, all generated content will be written into this file. If it's a directory path, for each template a separate file will be created with `TemplateName.generated.swift` name.

```yaml
output:
  <output path>
```

Alternatively you can use `path` key to specify output path.

```yaml
output:
  path: <output path>
```

You can use optional `link` key to automatically link generated files to some target.

```yaml
output:
  path: <output path>
  link:
    project: <path to the xcodeproj to link to>
    target: <name of the target to link to>
    group: <group in the project to add files to> // by default files are added to project's root group
```

> Note: Paths in configuration file are by default relative to configuration file path. If you want to specify absolute path start it with `/`.
