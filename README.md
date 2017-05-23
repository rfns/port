<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Port

Port is a VCS-agnostic Caché Studio source control utility to export or import Caché files based on projects instead of namespaces.

## The Five 'Why Projects?' Reasons

Since it uses a project based approach to handle the source code, the following advantages could be observed:

* **Development and organization**: Development and versioning is kept within the project scope.
* **Tests**: Allows the code to be tested atomically within the same project (which means no ^UnitTestRoot).
* **SourceControl integration**: Seamlessly exports the active item when saved. No need to check-in items manually.
* **Synchronization**: Keeps your repository in-sync with the project. Removes extraneous items when exported avoiding check-out usage.
* **Smart backup**: Mirrors the application directory and backups only what is changed inside the project.

## How to install

In order to install Port, you just need to follow the steps below:

1. Import the file [port.xml](https://github.com/rfns/port/blob/master/port.xml).
2. Run the class method ``##class(Port.SourceControl.Installer).Install()``.
3. Restart the Studio.

## Configuration

You might also want to check out the class ``Port.SourceControl.Config`` and configure
the source control integration according to your taste.

Or you could simply call `do ##class(Port.SourceControl.Wizard).Start()` and let the wizard help you.

## How to use

### Source Control Menu

When installed, Port adds a Source Control menu, composed with the following options:

* __Export Current Project__: Exports only the modified items from the current project.
* __Export Current Project to XML__: Forces the project to export a new XML version.
* __Export Project Test Suites to XML__: Exports all Tests matching the Test package prefix to the test path.
* __Remove All Classes from the Current Project__: Shortcut for removing all classes from the current project.
* __Remove All Routines from the Current Project__: Shortcut for removing all routines from the current project.
* __Remove All Files from the Current Project__: Shortcut for removing all static (web) files from the current project.
* __Remove Invalid Items from the Current Project__: Scans the project removing invalid item entries.
* __Run Test Suites__: Runs all test suites associated to the current project.
* __Force Current Project to be Exported__: Bypasses the timestamp checks and exports the project overwriting the repository's source.
* __Force Current Project to be Exported__: Bypasses the timestamp checks and imports the source code overwriting the project item version.

### Source Control Context Menu

* __Export This Item__: Forces the current item to be exported to the repository overwriting it's current matching source code.
* __Import This Item__: Forces the current item to be imported to the project overwriting it's current matching project item.
* __Run Tests Associated to this Item__: Only available if there's an associated test. If it does, runs the test atomically.

### Ignoring paths

Sometimes you might want to ignore paths that aren't related to Caché but must be kept inside it's folder structures to keep things
sticked. You can do this by creating a file called `.portignore` in the root of the repository and putting the paths to ignore
inside it, one per line. Note that you __MUST__ provide the base type folder since the paths are relative to the repository root.

In the example below, notice that cls and int folders are included. These are the base type folders.

```
cls/Package/ignoreme <- This ignores the folder called ignoreme and anything inside it.
int/ignoreme <- This also ignores the folder called ignoreme but only if it's inside the int folder.
```

## FAQ: Why not Atelier?

Really, I started this project some few months before Atelier 1.0 was released, by that time Atelier hadn't support for static files.
I also wanted to provide an alternative for those who like me prefer to use something less bloated than Eclipse or simply that doesn't need integration with multiple 3rd party tools.

The deal is: you might want something simplier to do something simplier.

## FAQ: So, does that mean you are ignoring Atelier?

No, I've been [experimenting](https://github.com/rfns/port/blob/master/cls/Port/REST/API.cls.txt) things out with it's REST API to provide integrations with [source code editors](https://en.wikipedia.org/wiki/Source_code_editor) like VSCode and Atom.

There are already some few options like [cos-vscode](https://github.com/doublefint/cos-vscode). But since I wanted to focus on using projects, I decided to implement my own.

## TODO

Check the [Projects](https://github.com/rfns/port/projects).

## CONTRIBUTION

[Here](https://github.com/rfns/port/blob/master/CONTRIBUTING.md).

## LICENSE

MIT License

Copyright (c) 2017 Rubens F. N. da Silva

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.






