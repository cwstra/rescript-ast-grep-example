module Shell: {
  let echo: string => unit
  let cd: string => unit
  let ls: string => array<string>
  let exec: string => unit
  let cat: string => string
  let sed: (~searchFor: RegExp.t, ~new: string, ~file: string) => array<string>
  let sedInPlace: (~searchFor: RegExp.t, ~new: string, ~file: string) => array<string>
} = {
  module Internal = {
    type t
    @module("shelljs")
    external it: t = "default"
    @send external echo: (t, string) => unit = "echo"
    @send external cd: (t, string) => unit = "cd"
    @send external ls: (t, string) => array<string> = "ls"
    @send external exec: (t, string) => unit = "exec"
    @send external cat: (t, string) => string = "cat"
    @send external sed: (t, RegExp.t, string, string) => array<string> = "sed"
    @send external sedInPlace: (t, @as("-i") _, RegExp.t, string, string) => array<string> = "sed"
  }
  let echo = str => Internal.it->Internal.echo(str)
  let cd = path => Internal.it->Internal.cd(path)
  let ls = path => Internal.it->Internal.ls(path)
  let exec = cmd => Internal.it->Internal.exec(cmd)
  let cat = path => Internal.it->Internal.cat(path)
  let sed = (~searchFor, ~new, ~file) => Internal.it->Internal.sed(searchFor, new, file)
  let sedInPlace = (~searchFor, ~new, ~file) =>
    Internal.it->Internal.sedInPlace(searchFor, new, file)
}

exception CouldNotFindBinary
exception MultipleBinaries(array<string>)

Shell.cd("node_modules/tree-sitter-rescript")
Shell.exec("../.bin/tree-sitter build")
let binary_name = switch Shell.ls("rescript.*") {
| [] => raise(CouldNotFindBinary)
| [binary_name] => binary_name
| binaries => raise(MultipleBinaries(binaries))
}
Shell.cd("../../")
Console.log(
  Shell.sedInPlace(
    ~searchFor=RegExp.fromString("libraryPath:.*$"),
    ~new=`libraryPath: ./node_modules/tree-sitter-rescript/${binary_name}`,
    ~file="sgconfig.yml",
  ),
)
