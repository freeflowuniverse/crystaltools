
# defs

to define a definition in a page use the following statement anywhere on the page

```
!!!def category:tech name:myname alias:alias1,alias2
``` 

- category is optional, defines e.g. category technology, useful for defs_list
- name is optional, if not specified will be the title of the page
  - if specified my_name will become 'My Name' when shown
- alias is optional, just to specify aliases for the definition

Chosen_Name will match all following

- `chosen_name`
- `chosen_Name`
- `Chosen_Name`
- `Chosen_name`
- `chosenname`
- `chosenName`
- `ChosenName`

In resulting wiki all found def's will be shown as a link and go back to the page of the definition (concept)
