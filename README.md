<p>
    <img src="https://img.shields.io/badge/Port-enabled-green.svg" height="18">
</p>

# Port

Port is a VCS-agnostic Caché Studio utility to export or import Caché files based on projects instead of namespaces.
It's recommended to use Port locally, which makes it ideal for Studio users and quick open-source projects.

Its name origins from 'portability', 'export' and 'import'.

> __NOTE__: Although you can use Port for a shared instance, keep in mind that if two users are working in the same project their changes could overlap each other, this would cause an extremely undesired result. So if you plan on using Port for a single shared instance, then make sure that only one person works exclusively for a single project.

## The Five 'Why Projects?' Reasons

Since it uses a project based approach to handle the source code, we can consider the following advantages:

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

> __NOTE:__ Some configurations are not available when using the Wizard. For such cases, use the `Port.Configuration` class.

## How to use

Port will act whenever a file is saved (not compiled), as long as you're working on some project that isn't the 'Default'. You can see if Port is working correctly by checking the Studio's Output window.

### Source Control Menu

When installed, Port adds a Source Control menu, composed with the following options:

* __Export__: Exports only the modified items from the current project using the UDL format.
* __Export to XML__: Exports the current project to XML.
* __Export tests__: Exports all unit test classes related to the current project, only available if test format is set to XML.
* __Remove classes__: Shortcut for removing all classes from the current project.
* __Remove routines__: Shortcut for removing all routines from the current project.
* __Remove files__: Shortcut for removing all static (web) files from the current project.
* __Scan and fix__: Scans the project and remove all entries that are invalid (nonexistent or with an invalid name).
* __Run tests__: Runs all test suites associated to the current project.
* __Export (forced)__: Skips timestamp checks and exports all the current project items.
* __Import (forced)__: Skips timestamp checks and imports all tracked files from the project repository.

### Source Control Context Menu

* __Export from here__: Forces the current item to be exported to the repository overwriting it's current matching source code. If the target is a package or a folder, then all its children will be exported recursively.
* __Import from here__: Forces the current item to be imported to the project overwriting it's current matching project item. If the target is a package or a folder, then all its children will be imported recursively.
* __Run test__: Only available if there's an associated test. If it does, runs the test atomically.

### Ignoring paths

Sometimes you might want to ignore paths that aren't related to Caché but must be kept inside, files like a README.md to describe a package are a good example. You can do this by creating a file called `.portignore` in the root of the repository and putting the paths to ignore
inside it, one per line. Note that you __MUST__ provide the folder that indicates the item type since the paths are relative to the repository root.

In the example below, notice that cls and int folders are included. These are the item types.

```
cls/Package/ignoreme <- This ignores the folder called ignoreme and anything inside it.
int/ignoreme <- This also ignores the folder called ignoreme but only if it's inside the int folder.
```

### Workspaces

When using Port you'll notice the usage of the term _workspace_. This is basically the path where the project's source code is exported. There're two types of workspaces: _primary workspace_ and _custom workspaces_.

Whenever a new project is exported by Port it will use the primary workspace configuration pattern to 'seed' the path to the project being exported for the first time. After this, the resulting path will be always used for this project, this path is called a _custom workspace_.

You can modify that path by using the Wizard or the method `SetCustomWorkspace` from the `Port.Configuration` class. Modifying it will cause the project you selected to be exported to a new location. Port will detect a path change and warn the user about exporting the whole project again.

> __NOTE:__ This'll not move any of the existing source code from your old path, but instead it'll export the project straight from your instance again.

You can also modify the _primary workspace_ by using the Wizard or the method `SetPrimaryWorkspace` from the `Port.Configuration` class. However this will affect only the projects that weren't exported by Port yet or had their _custom workspace_ removed by calling the method `RemoveCustomWorkspace`.

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

> __WARNING!__ Make sure you know what you're doing! Bad hook implementations can cause Port and even the Source Control API to go awry thus resulting in code loss.

# Quick question: Why not Atelier?

This project started before Atelier was released, and it's still useful for developers that prefer using the Studio instead of installing Eclipse. The original idea was to bring to the developers the capability to export the source code using a scaffolding that is easy to manage, which is pretty much what Atelier does today, however Atelier is not made for working with the Studio's projects. Leaving that task for the Eclipse platform.

The deal is: you might want something simplier to do something simple.

# Troubleshooting

## I installed Port but it seems to haven't changed anything!

Make sure to check the output and check for a 'All Done' message. After this message, there should have a note requesting you to restart the Studio. Follow this instruction, now see if the Source Control menu appears, if it's there then you're good to go.

## I installed Port and it even added the Source Control menu but the text there is empty!

This might be caused due to your current Caché language which is not supported by Port yet, try executing the following method and see check if it fixes the issue:

```objectscript
do ##class(%MessageDictionary).SetSessionLanguage("en-us")
```

If it does, you are encouraged to open a [PR](https://github.com/rfns/forgery/pull/new/master) and add your language.

## HELP! I removed an old item from my project and exported the project which removed my file, but I find out later that it was the wrong file!

Whenever you export the project Port will check for any files that aren't related to it in your instance. If there's any files that doesn't corresponds to the project, these are considered as _orphans_ and as such they'll be removed in order to keep the workspace synchronized. There are two circustances that can cause the purge: when you _remove_ the item or when you _delete_ the item.

As long as you REMOVE and don't DELETE the source from your instance you can simply re-add this item to the project and export it again, you might need to _force export_ or edit the item though.

If you want to avoid this kind of issue, remember to commit your changes before purging these files.

## I'm trying to import a file it seems I can't?

If the file you're trying to import failed or you didn't noticed any message warning you about it, then you must check if:

1. The file is inside one of the type folders. If it's not the file will be ignored and you won't see any messages regarding it.
2. The language syntax is acceptable (you can check the output for errors).
3. You removed this item recently, which in turn updated the last modified timestamp for your project. This will not cause any messages to be displayed as well.

For number 3, remember that Port doesn't check the source code but instead their modified date. So if you attempt to import an item whose last-modified attribute is older than your project's last change, this item will be skipped. This is a by-design limitation introduced to improve the performance for projects with many items, but you can remediate it by using the `Import (forced)` option. However be warned that it'll import the project as whole.

## I've imported/exported a source code but it seems to have broken my encoding? Strange characters are showing up!

This can be caused due to Port working with UTF-8 by default. You can change this behavior according to your preferences by providing exactly which encoding should be used for a specific extension, you can do so by using the following methods:

* `SetInputCharset("charset")` will transcode the incoming document content to the provided charset.
* `SetOutputCharset("charset")` will transcode the outgoing document content to the provided charset.

So, let's say if you are using ISO-8859-1 or Windows 1252 when handling CSPs, you can configure _Port_ to use it instead of UTF-8.
Note that by default Studio uses RAW format (which equals to non-unicode) for editing files. This might be a good use case for manually changing the charset for CSP files.

## It seems I'm not able to export GBL or any binary related files?

Yes, Port supports exporting only source codes, which is mostly plain-text. Anything binary-related is usually associated to the the public folder, e.g. an image. That being said, you can export the project XML that include binary files.

## I added a new item but it seems to not have been exported when I saved it?

That's because saving an item is not the same as saving the project. So even though the item was created and added to the current project, since the project wasn't saved as well the item entry is not persisted yet. If you create a new item always remember to save the project it belongs to before saving the item itself.

## I have a big project and that seems to be causing the output to freeze!

If you're working with big projects, you'll mostly face this issue. And the solution for that is: wait. Because the Source Control process runs in the same as the Studio itself, exporting or importing a big project will cause the Studio to become inoperable. However this is only visually, because the Source Control process still would be running.
The time it takes to finish depends on the amount of items the project has so don't attempt to interrupt the process because you would risk corrupting the project and the sources themselves.

## I'm trying to work with MultiValue Basic routines but I'm facing several errors with attempting to save it!

Even though implemented, the support for MVB routine types is highly bugged due to it using an obscure API, as long as this API keeps this way, I don't plan on improving the support for it as well.

However, working with MVI routines seems to be fine as long as you know the syntax for them.

## CONTRIBUTION

[Here](https://github.com/rfns/port/blob/master/CONTRIBUTING.md).
