# STT

A library that helps implement and use RxViper architecture. RxViepr is very similar to standard Viper, but has several improvements:

- This architecture does not use in/out layer, all events are passed by Rx.
- Each module may have its custom Router, but in most cases default (SttRouter) is enough.
- Use bindings.

STT module consist of:
- View
- Presenter
- Interactor(optional)
- Router(optional)
- Assembler

###### Diagram
![STT](https://user-images.githubusercontent.com/9388051/66329415-24b7a900-e937-11e9-9ba2-5329bcb8e168.png)
------------

## Module folder stracture

You should use our template to create a module, but you still have to create folders for it.

The template generates all files, but in 98% you won't need a custom router which is provided by default in template. You should delete its registration in assembler and replace resolving to creating an instance of SttRouter and replace type in presenter to `SttRouterType`.

Also in some cases, you do not need an interactor, so you may just delete it.

Each module has next structure

- *ModuleName* (folder)
 - Assembler (folder)
     - *ModuleName*Assembler.swift
 - Interactor (folder)
     - *ModuleName*InteractorType.swift
     - *ModuleName*Interactor.swift
 - Router (folder)
    - *ModuleName*RouterType.swift
    - *ModuleName*Router.swift
 - Presenter (folder)
    - *ModuleName*Presenter.swift
 - View (folder)
    - *ModuleName*ViewDelegate.swift
    - *ModuleName*ViewController.swift

---

## View Layer

- **View** - Represents only layout (wireframe) (without any specific design things (like fonts, colors, attributes, etc).

- **ViewDelegate** - Represents callbacks from presenter to its ViewController, in most cases is unused.

- **ViewController** - Represents a passive view without any business logic, contains only an outlet, bindings and code layout for elements if needs.

## Presenter 

**Presenter** -  is a layer between `ViewController` and `Interactor/Router`. It should contain only commands (`SttCommand`), command's handlers, and properties. All responsibility it passes to *router* or *interactor*.
But presenter can keep more than one *interactor* (For example if we have linked pages but for this we need some specific logic).

> **Remember**: all business logic has to be in ~~presenter~~ **interactor**.

## Interactor

**Interactor** - Contains business logic, generates errors for a view if something has happened (use `SttNotificationErrorService` for handling errors).
Interactor doesn't have direct connections to API or DB, all requests should be passed to a repository. Interactor only converts data, validates states of models, handles errors (if need).

## Router

**Router** - contains navigation between page, can pass parameter to a target controller.

## Assembler

**Assembler** - registers all dependencies for a module, resolves parameters for dependencies and creates presenter.

---

## Repository

**Repository** - works with API and DB using Provider, manages all data in a program and can get data from different source (API or DB) or gets from both and combines these models. Works with an API entities and return them. Repository should work only with grouped entities.

## Provider

**Provider** - represents *Data Layer*. Responsible for data transfer between client and API / DB. Program also has `KeyValueStorage` for storing local small data. To store some collections of data you may use `Realm` provider.
