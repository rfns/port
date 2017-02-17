# Port

Port is a Caché Studio utility to export or import Caché files, but
based on projects instead of namespaces. It also includes a %Studio.SourceControl class to make it's functionality
more transparent for the developer.

## The Six Project Reasons

Since it uses a project based approach to handle the source code, many things have been taken in mind.

* **Development and organization**: Keep the development and versioning within the project scope.
* **Tests**: Isolated per project, close to it's source, can be run on-demand.
* **Source format**: While the Caché Studio allows projects to be exported, it uses the XML Format. Such format, though functional, provides low readability.
* **%Studio.SourceCode integration**: Exports the active item when when saved. No need to check-in or check-out the item. Let the project dictates the rules.
* **Synchronization**: Keeps your repository in-sync with the project. Removes extraneous items when exported.
* **Smart backup**: Mirrors the application directory and backups only what is changed.

## How to install

In order to install Port, you just need to follow the steps below:

1. Import the file [port.xml](https://github.com/rfns/port/blob/master/port.xml).
2. Run the class method ``##class(Port.SourceControl.Installer).Install()``.
3. Restart the Studio.

## Configuration

You might also want to check out the class ``Port.SourceControl.Config`` and configure
the source control integration according to your taste.

## TODO

There's still many missing features and bugs to be found. Check the [issues](https://github.com/rfns/port/issues) regularly.

## CONTRIBUTION

Contribution guide is planned to be added soon.

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






