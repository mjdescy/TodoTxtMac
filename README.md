# TodoTxtMac

# Overview

TodoTxtMac is a minimalist, keyboard-driven to-do manager for Mac OS X (10.8 Mountain Lion and higher) that conforms to the todo.txt format spec.


# Goals

This application is inspired by the [todotxt.net][] application for Microsoft Windows, with numerous improvements and modifications specific to the Mac OS X platform.

From a design perspective, the goal is to be the fastest, simplest, and cleanest implementation possible.

[todotxt.net]: http://benrhughes.github.io/todotxt.net/


# Features

## General features

- Full compliance with the todo.txt format spec.
- Fully keyboard-driven, with one-key bindings for commonly-used commands.
- Multiple selection in the task list.
- Shortcuts to toggle completion, change priority, set due dates, and delete all selected tasks.
- Archive completed tasks (to done.txt), either on command or automatically.
- Preserves Windows or Unix line endings in the todo.txt file for cross-platform compatability.

## Adding/removing tasks

- Paste one or more tasks into the task list from the clipboard.
- Import one or more tasks into the task list via drag-and-drop.
- Optionally prepend the task creation task on newly created tasks (including those pasted in from the clipboard).
- Copy selected tasks to the clipboard.
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
- Colors projects and contexts in dark gray in task list. Both these colors are user customizable.

## Mac-specific user interface features

- Autosave on change. (Note that the title bar will say "Edited" even after autosaving, because this is the Mac's default behavior.)
- Autocomplete project names.
- Autocomplete context names.
- Multiple document interface.
- Full screen mode.
- Open todo.txt files by dragging and dropping them onto the application icon.


# Keyboard Shortcuts

## Working with tasks

- n: new task
- j: move down to next task
- k: move up to previous task
- x: toggle task completion
- d or Backspace: delete task (with confirmation)
- u or Enter: update task
- p: postpone task by X (user-entered) days
- s: set due date
- a: archive completed tasks (archive file done.txt must be set)
- Command+Up: Increase priority
- Command+Down: Decrease priority
- Command+Left or Command+Right: Remove priority
- Command+C: Copy selected tasks to the clipboard
- Command+Shift+V: Paste tasks into the task list from the clipboard
- Command+Option+Up: Increase due date by 1 day
- Command+Option+Down: Decrease due date by 1 day
- Command+Option+Left or Command+Option+Right: Remove due date

## Working with files

- Command+N: new file
- Command+O: open file
- Command+S: save file (forces the file to save immediately)
- .: reload file

## Sorting the task list

- Command+0: order in file
- Command+1: priority
- Command+2: project
- Command+3: context
- Command+4: due date
- Command+5: creation date
- Command+6: completion date
- Command+7: alphabetical

## Filtering the task list

- f: define quick filters
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


## Caveats/Features Not Planned

- This application is not meant for direct reordering of tasks in the todo.txt file.
- This application does not retain blank lines in the todo.txt file.

# License

This application is dual-licensed under the GNU General Public License and the MIT License. See LICENSE.txt for full license information.


# For Contributors

## Source Code Conventions

I am striving for very clean code. I am following the following general coding conventions:

- For clarify, Limit nesting of brackets to two sets per line, as in: `[[thisString stringValue] isEqualToString:@"otherStringValue"]`
- Maximum line length of 100 characters.
- Indent with spaces rather than tabs.
- Always use curly braces for conditionals and loops.
- Use descriptive variable and method names.

## Pull Requests

The project uses [git-flow] to implement Vincent Driessen's [branching model]. All pull requests should be directed at the "develop" branch.

[git-flow]: https://github.com/nvie/gitflow
[branching model]: http://nvie.com/posts/a-successful-git-branching-model/

# Credits/Thanks

Thanks to Gina Tripani who created the [Todo.txt][] format and the community of developers who created the command line tools and iOS/Android apps.

Thanks to Ben Hughes whose Windows application [todotxt.net] formed the basis of this application's design and feature set. Todotxt.net is a fantastic program and did not have an analog on the Mac. After starting my application, I contributed some patches to todotxt.net and am happy to be a contributor on such a great project.

Thanks to Josh Wright <@BendyTree> for his [RegExCategories][] library.

Thanks to kuba for the image used as the icon. Image Credit: [OK Icon][] from [Vector.me][] (by kuba)

[Todo.txt]: http://www.todotxt.com
[RegExCategories]: https://github.com/bendytree/Objective-C-RegEx-Categories
[OK Icon]: http://vector.me/browse/329308/ok_icon
[Vector.me]: http://vector.me/