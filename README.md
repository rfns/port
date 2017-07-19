<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Port

Port is a VCS-agnostic Caché Studio source control utility to export or import Caché files based on projects instead of namespaces.

## The Five 'Why Projects?' Reasons

Since it uses a project based approach to handle the source code, the following advantages could be observed:

* **Development and organization**: Development and versioning is kept within the project scope.
* **Tests**: Allows the code to be tested atomically within the same project (which means no ^UnitTestRoot usage).
* **SourceControl integration**: Seamlessly exports the active item when saved. No need to check-in items manually.
* **Synchronization**: Keeps your repository in-sync with the project. Removes extraneous items when exported, thus avoiding check-out usage.
* **Smart backup**: Mirrors the application directory and backups only what is changed inside the project.

## How to install

<<<<<<< HEAD
In order to install Port, you just need to import the file [port.xml](https://github.com/rfns/port/blob/master/port.xml) with the compile flag enabled and restart your Studio.

## Configuration

You can configure advanced settings using the class `Port.Configuration`. You can also check what you can configure by running `##class(Port.Configuration).Help()` or using the wizard: `Wizard^Port`.
=======
In order to install Port, you just need to follow the steps below:

1. Import the file [port.xml](https://github.com/rfns/port/blob/master/port.xml).
2. Run the class method ``##class(Port.Installer).Install()``.
3. Restart the Studio.

## Configuration

You might also want to check out the class ``Port.Configuration`` and configure
the source control integration according to your taste.

Or you could simply call `do ##class(Port.Wizard).Start()` and let the wizard help you.
>>>>>>> f5ea291a33cffb45727f33fbb020a0a87d543f58

## How to use

### Source Control Menu

When installed, Port adds a Source Control menu, composed with the following options:

* __Export__: Exports only the modified items from the current project using the UDL format.
* __Export to XML__: Exports the current project to XML.
* __Export tests__: Exports all unit test classes related to the current project.
* __Remove classes__: Shortcut for removing all classes from the current project.
* __Remove routines__: Shortcut for removing all routines from the current project.
* __Remove files__: Shortcut for removing all static (web) files from the current project.
* __Scan and fix__: Scans the project and remove all entries that are invalid (nonexistent or with an invalid name).
* __Run tests__: Runs all test suites associated to the current project.
* __Export (forced)__: Bypass timestamp checks and exports all the current project items.
* __Import (forced)__: Bypass timestamp checks and imports all tracked files from the project repository.

### Source Control Context Menu

* __Export from here__: Forces the current item to be exported to the repository overwriting it's current matching source code.
* __Import from here__: Forces the current item to be imported to the project overwriting it's current matching project item. If the target is a package, then it will all classes inside the package directory will be imported recursively.
* __Run test__: Only available if there's an associated test. If it does, runs the test atomically.

### Ignoring paths

Sometimes you might want to ignore paths that aren't related to Caché but must be kept inside it's folder structures to keep things
sticked. You can do this by creating a file called `.portignore` in the root of the repository and putting the paths to ignore
inside it, one per line. Note that you __MUST__ provide the base type folder since the paths are relative to the repository root.

In the example below, notice that cls and int folders are included. These are the base type folders.

```
cls/Package/ignoreme <- This ignores the folder called ignoreme and anything inside it.
int/ignoreme <- This also ignores the folder called ignoreme but only if it's inside the int folder.
```

### Workspaces

Using this feature provides you the capability to export projects to different paths according to their custom exporth path setting. When a project is exported for the first time, Port records the export path used in order to prevent multiple projects from overlapping their exported source base.

Custom project export paths can be also set preemptively using the wizard.

This feature can be accesed using the Wizard and navigating to `1. Manage workspace settings`.

Using project workspaces can become a powerful ally for keeping multiple source codes organized if used correctly. For example, you could group multiple projects within a single repository and take a monorepository approach. It's all up to your creativity.

## FAQ: Why not Atelier?

Really, I started this project some few months before Atelier 1.0 was released, by that time Atelier hadn't support for static files.
I also wanted to provide an alternative for those who like me prefer to use something less bloated than Eclipse or simply that doesn't need integration with multiple 3rd party tools.

The deal is: you might want something simplier to do something simplier.

## FAQ: So, does that mean you are ignoring Atelier?

No, I've been [experimenting](https://github.com/rfns/port/blob/master/cls/Port/REST/API.cls) things out with it's REST API to provide integrations with [source code editors](https://en.wikipedia.org/wiki/Source_code_editor) like VSCode and Atom.

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






