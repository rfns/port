<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Port

Port is a Caché Studio source control utility to export or import Caché files based on projects instead of namespaces.

## The Six 'Why Projects?' Reasons

Since it uses a project based approach to handle the source code, the following advantages could be observed:

* **Development and organization**: Development and versioning is kept within the project scope.
* **Tests**: Allows the code to be tested atomically within the same project (which means no ^UnitTestRoot).
* **Source format**: While the Caché Studio allows projects to be exported, it uses the XML Format. Such format, though functional, provides low readability. Port however, exports the source in plain format using the new UDL format.
* **SourceControl integration**: Seamlessly exports the active item when saved. No need to check-in items manually.
* **Synchronization**: Keeps your repository in-sync with the project. Removes extraneous items when exported avoiding check-out usage.
* **Smart backup**: Mirrors the application directory and backups only what is changed.

## How to install

In order to install Port, you just need to follow the steps below:

1. Import the file [port.xml](https://github.com/rfns/port/blob/master/port.xml).
2. Run the class method ``##class(Port.SourceControl.Installer).Install()``.
3. Restart the Studio.

## Configuration

You might also want to check out the class ``Port.SourceControl.Config`` and configure
the source control integration according to your taste.

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
* __Force Current Project to be Exported__: Bypasses the timestamp checks and imports the project overwriting the project.

### Source Control Context Menu

* __Export This Item__: Forces the current item to be exported to the repository overwriting it's current matching source code.
* __Import This Item__: Forces the current item to be imported to the project overwriting it's current matching project item.
* __Run Tests Associated to this Item__: Only available if there's an associated test. If it does, runs the test atomically.

## TODO

- [ ] Develop a protection algorithm to allow one or more paths to be excluded from the [cleanup](https://github.com/rfns/port/blob/master/cls/Port/Project/Exporter.cls.txt#L48-L118).
This might be useful when ignoring web bundles.

## CONTRIBUTION

[Here](https://github.com/rfns/port/master/blob/CONTRIBUTING.md).

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






