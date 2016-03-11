# TodoTxtMac

# Overview

TodoTxtMac is a minimalist, keyboard-driven to-do manager for Mac OS X that conforms to the todo.txt format spec. Version 2.0.0 and up are supported only on Mac OS X 10.11 (El Capitan). Version 1.6.1 can be used on lower versions of Mac OS X, down to Mac OS X 10.8, though support is not guaranteed.

# Goals

This application is inspired by the [Todotxt.net][] application for Microsoft Windows with numerous improvements and modifications specific to the Mac OS X platform. It is designed to pair well with other todo.txt applications, such as [SwiftoDo][], [Todotxt.net][], [SimpleTask][], [topydo][], and [many others][].

From a design perspective the goal is to be the fastest, simplest, and cleanest implementation possible.

[todotxt.net]: http://benrhughes.github.io/todotxt.net/
[SwiftoDo]: https://itunes.apple.com/us/app/swiftodo-task-list-for-todo.txt/id1073798440?ls=1&mt=8
[SimpleTask]: https://play.google.com/store/apps/details?id=nl.mpcjanssen.todotxtholo
[topydo]: https://github.com/bram85/topydo
[many others]: http://todotxt.com

# Features

## General features

- Full compliance with the todo.txt format spec.
- Fully keyboard-driven, with one-key bindings for commonly-used commands.
- Multiple selection in the task list.
- Support for due dates, which are formatted "due:YYYY-MM-DD".
- Shortcuts to toggle completion, change priority, set due dates, and delete all selected tasks.
- Archive completed tasks (to done.txt), either on command or automatically.
- Preserves Windows or Unix line endings in the todo.txt file for cross-platform compatability.
- Automatic update checking.
- Displays general metadata (task counts, etc.) about the task list.
- Undo/redo support.

## Adding/removing tasks

- Paste one or more tasks into the task list from the clipboard.
- Import one or more tasks into the task list via drag-and-drop.
- Optionally prepend the task creation task on newly created tasks (including those pasted in from the clipboard).
- Copy selected tasks to the clipboard.
- Cut selected tasks to the clipboard.
- Reload file on command.

## Sorting and filtering

- Sort task list by priority, project, context, due date, etc.
- Filter task list.
- Quick filters: preset filters mapped to number keys.
- Search field for quick, ad-hoc filtering of the task list.

## Due dates

- Set arbitrary due dates on selected tasks.
- Increment, decrement, or remove due dates.
- Postpone tasks by X (user-entered) days.
- Supports relative due dates, such as "due:tomorrow" and "due:Saturday" for new tasks. These strings can be localized.

## Fonts and colors

- User-customizable font for the task list.
- Bold priorities in task list.
- Colors completed tasks in light gray and applies strikethrough.
- Colors overdue tasks in purple and tasks due today in red. Both these colors are user customizable.
- User-customizable colors for projects, contexts, due dates, threshold dates, creation dates, and arbitrary tags in task list.

## Mac-specific user interface features

- Autosave on change (Note that the title bar will say "Edited" even after autosaving, because this is the Mac's default behavior).
- Autocomplete project names.
- Autocomplete context names.
- Multiple document interface.
- Full screen mode.
- Open todo.txt files by dragging and dropping them onto the application icon.

# Keyboard Shortcuts

## Working with tasks

- N: new task
- J: move down to next task
- K: move up to previous task
- X: toggle task completion
- D or Backspace: delete task (with confirmation)
- U or Enter: update task
- P: postpone task by X (user-entered) days
- S: set due date
- Option+S: set threshold date
- I: set priority to user-entered value (A-Z)
- T: append text to end of selected tasks
- R: prepend text to beginning of selected tasks (after priority and creation date if they exist)
- A: archive completed tasks (archive file done.txt must be set)
- Command+Up: Increase priority
- Command+Down: Decrease priority
- Command+Left or Command+Right: Remove priority
- Command+C: Copy selected tasks to the clipboard
- Command+X: Cut selected tasks (copy to the clipboard and delete from task list)
- Command+Shift+V: Paste tasks into the task list from the clipboard
- Command+Option+Up: Increase due date by 1 day
- Command+Option+Down: Decrease due date by 1 day
- Command+Option+Left or Command+Option+Right: Remove due date

## Undo/redo

- Command+Z: Undo
- Command+Shift+Z: Redo

## Working with files

- Command+N: new file
- Command+O: open file
- Command+S: save file (forces the file to save immediately)
- .: reload file
- Command+I: view task list metadata (task counts, etc.)
- Command+W: close file
- Command+Option+W: close all files

## Sorting the task list

- Command+0: order in file
- Command+1: priority
- Command+2: project
- Command+3: context
- Command+4: due date
- Command+5: creation date
- Command+6: completion date
- Command+7: threshold date
- Command+8: alphabetical

## Filtering the task list

- Command+F: find within displayed tasks (moves focus to the search field)
- F: define quick filters
- 1: apply quick filter 1
- 2: apply quick filter 2
- 3: apply quick filter 3
- 4: apply quick filter 4
- 5: apply quick filter 5
- 6: apply quick filter 6
- 7: apply quick filter 7
- 8: apply quick filter 8
- 9: apply quick filter 9
- 0: remove applied filter

# Features Not Planned

- This application is not meant for direct reordering of tasks in the todo.txt file.
- This application does not retain blank lines in the todo.txt file.
- This application does not support line breaks, long-form notes, attachments, or other features not part of the todo.txt format specification.

# Frequently Asked Questions (FAQ)

## Is there a preference to re-open my todo.txt file on launch?

Yes, but most people will not need such a preference, because the default behavior of TodoTxtMac is to reopen whatever todo.txt files were open when you last quit the app. To enjoy this behavior, do not close your todo.txt file's window prior to quitting the app.

If the TodoTxtMac is not reopening your files, or keeping a list of them in the "File > Open Recent" menu, then you should check the following preferences under System Preferences > General:

1. "Close windows when quitting an app" must be unchecked.
2. "Recent items" must not be "None".

If you need to force TodoTxtMac to open a particular todo file on launch, you may set a default todo.txt file in TodoTxtMac's Preferences > Startup.

You may also force TodoTxtMac to open a particular todo file on launch, you may launch the app with the command-line argument "todo-file", in the Terminal, as follows:

    $ open /Applications/TodoTxtMac.app --args -todo-file ~/Documents/todo.txt

## Is this application Dropbox-enabled?

No. Unlike the official Todo.txt iOS application, this application does not call Dropbox's API. You can sync your file outside of TodoTxtMac via Dropbox or other services.

## TodoTxtMac says my todo.txt file cannot be autosaved. The file has been changed by another application.

Your todo.txt file can get modified outside of TodoTxtMac, especially if you are syncing the file via Dropbox or a similar service. TodoTxtMac uses Cocoa's default document object model to handle the file interactions. This means that the application will warn you of file changes that came from outside the application when you try to make changes to the file, not at the moment the file was changed. To avoid file conflicts, try the following strategies:

1. Reload your TodoTxtMac file manually (press `.`) before making changes to it, if you believe the file was updated (by Dropbox for example) recently.
2. Close TodoTxtMac when not using it for extended periods.
3. When presented with the option to "Save Anyway" or "Revert" changes, always revert changes. You will have to re-do your last action in TodoTxtMac, but you will not lose the changes that originated outside the application.

## Will this project be ported from Objective C to Swift?

When Apple officially deprecates Objective C, the plan is to migrate this project to Swift.

# License

This application is dual-licensed under the GNU General Public License and the MIT License. See LICENSE.txt for full license information.

# For Contributors

## Source Code Conventions

I am striving for very clean code. I am following the following general coding conventions:

- For clarity, limit nesting of brackets to two sets per line, as in: `[[thisString stringValue] isEqualToString:@"otherStringValue"]`.
- Maximum line length of 100 characters.
- Indent with spaces rather than tabs.
- Always use curly braces for conditionals and loops.
- Use descriptive variable and method names.

## Pull Requests

The project uses [git-flow] to implement Vincent Driessen's [branching model]. All pull requests should be directed at the "develop" branch.

[git-flow]: https://github.com/nvie/gitflow
[branching model]: http://nvie.com/posts/a-successful-git-branching-model/

# Credits/Thanks

Thanks to Gina Trapani who created the [Todo.txt][] format and the community of developers who created the command line tools and iOS/Android apps.

Thanks to Ben Hughes whose Windows application [todotxt.net][] formed the basis of this application's design and feature set. Todotxt.net is a fantastic program and did not have an analog on the Mac. After starting my application, I contributed some patches to todotxt.net and am happy to be a contributor on such a great project.

Thanks to Josh Wright <@BendyTree> for his [RegExCategories][] library.

Thanks to Sam Daitzman <@sdaitzman> for the application icon.

Thanks to Andy Matuschak and the other contributors for the [Sparkle framework].

[Todo.txt]: http://www.todotxt.com
[RegExCategories]: https://github.com/bendytree/Objective-C-RegEx-Categories
[OK Icon]: http://vector.me/browse/329308/ok_icon
[Vector.me]: http://vector.me/
[Sparkle framework]: http://sparkle.andymatuschak.org/
