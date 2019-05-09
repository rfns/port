<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Port

Port is a VCS-agnostic Caché Studio utility to export or import Caché files based on projects instead of namespaces.

## The Five 'Why Projects?' Reasons

Since it uses a project based approach to handle the source code, the following advantages could be observed:

* **Development and organization**: Development and versioning is kept within the project scope.
* **Tests**: Allows the code to be tested atomically within the same project (which means no ^UnitTestRoot usage).
* **SourceControl integration**: Seamlessly exports the active item when saved. No need to check-in items manually.
* **Synchronization**: Keeps your repository in-sync with the project. Removes extraneous items when exported, thus avoiding check-out usage.
* **Smart backup**: Mirrors the application directory and backups only what is changed inside the project.

## How to install

In order to install Port, you just need to import the file [port.xml](https://github.com/rfns/port/blob/master/port.xml) with the compile flag enabled and restart your Studio.

## Configuration

After installing Port, it'll define a set of default configurations. However sometimes these settings might not be adequate for you.

You can re-configure these settings using the class `Port.Configuration`. You can also check what you can configure by running `##class(Port.Configuration).Help()` or using the wizard: `Wizard^Port`.

It also includes settings that allow you more per-project customizations.

## How to use

Port will act whenever a file is saved (not compiled), as long as you're working on some project that isn't the
'Default'. You can see if Port is working correctly by checking the Studio's Output window.

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

When using Port, you'll notice the usage of the term _workspace_. This is basically the path where the project's source code is exported. There're two types of workspaces: _primary workspace_ and _custom workspaces_.

### Primary workspaces

Whenever a new project is exported by Port it will use the primary workspace configuration pattern to 'seed' the path to the project. Which means that after the first export, it'll be used as the custom workspace as well. This allows the user to modify it instead, thus affecting only the desired project.

### Custom workspaces

Since an existing project is seeded with the pattern from the _primary workspace_, future operations will always be affected by that workspace path. If you want to modify the path exclusively for that project, than you need to redefine the _custom workspace_ for that project.

## Extended Hooks

Extended hooks allows another source control class to take over the Studio event (hook) cycle and execute specific tasks. In order to create extended hooks, you need to create a class that implements one or more of the following hooks:

* OnBeforeLoad
* OnAfterLoad
* OnBeforeSave
* OnAfterSave
* OnAfterStorage
* OnBeforeCompile
* OnAfterCompile
* OnBeforeClassCompile
* OnAfterClassCompile
* OnBeforeAllClassCompile
* OnAfterAllClassCompile
* OnBeforeDelete
* OnAfterDelete
* UserAction
* AfterUserAction

You can check what each hook does by reading `%Studio.Extension.Base` [documentation](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?LIBRARY=%SYS&CLASSNAME=%25Studio.Extension.Base&MEMBER=&CSPCHD=000000000000oPMJCmLTaI$$s0x3lp1bujCh8EybMEuEEU5g8t&CSPSHARE=1).

Unlike `%Studio.Extension.Base`, each hook should be implemented as class method and receive the `%Studio.Extension.Base` as the first parameter: consider a case where you need to do some validation before the file is saved, you would use _OnBeforeSave_.

You must consider modifying the method signature from `%Studio.Extension.Base`:

> Method OnBeforeSave(InternalName As %String, Location As %String = "", Object As %RegisteredObject = {$$$NULLOREF}) As %Status

to:

> __ClassMethod__ OnBeforeSave(__SourceControl As %Studio.Extension.Base,__ InternalName As %String, Location As %String = "", Object As %RegisteredObject = {$$$NULLOREF}) As %Status

Finally, after implementing your hooks you need to register the class with:

> `do ##class(Port.Configuration).RegisterExtendedHooks("Your.Implementer.Class")`.

If you want to remove it, just call the same method with an empty string.

> __NOTE:__ Using extended hooks means that all output will be redirect to Port. That makes the class you specified responsible for whatever it writes. Port will attempt to capture its output and display it cleanly, but the class still must take care of messages that break into new lines.

## FAQ: Why not Atelier?

This project started before Atelier was released, and it's still useful for developers that prefer using the Studio instead of installing Eclipse. The original idea was to bring to the developers the capability to export the source code using a scaffolding that is easy to manage, which is pretty much what Atelier does today, however Atelier is not made for working with the Studio's projects. Leaving that task for the Eclipse platform.

The deal is: you might want something simplier to do something simple.

## CONTRIBUTION

[Here](https://github.com/rfns/port/blob/master/CONTRIBUTING.md).
