# defs

to define a definition in a page use the following statement anywhere on the page

```
!!!defs:Chosen_Name:alias1:alias2
```

When replaced Chosen_Name becomes `Chose Name`

Chosen_Name will match all following

- `chosen_name`
- `chosen_Name`
- `Chosen_Name`
- `Chosen_name`
- `chosenname`
- `chosenName`
- `ChosenName`

In resulting wiki all found def's will be shown as a link and go back to the page of the definition (concept)
