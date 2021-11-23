# Navigation

## navbar.md

is the top navigation element

```markdown
- ThreeFold
  - [ThreeFold Website](https://threefold.io)
  - [ThreeFold Blog](threefold:blog)
  - [TF Knowledge Base](@threefold:threefold_home)
  - [TFGrid Capacity Explorer](https://explorer.threefold.io/)
  - [TF Token Stats](https://tokenstats.threefoldtoken.com/)
  - [TFGrid Manual](@manual:manual3_home_new)

```

- note the 2nd line, will use new tab because of !

## sidebar.md

Example with line in between

```markdown

- [**Home**](@threefold:threefold_home)
-----------

- [Release Notes](threefold:releasenotes)
- [Team](threefold:team)

```

## how to work with @ and !

```markdown
- [**Home**](@threefold:threefold_home)
- [**Team**](!threefold:team)
```

- '''@''' means we jump to the page and the sidebar we show is the bar from that location (or parent of that location)
- default the sidebar stays the same, if a page is linked too we show the page with the sidebar of where we jump from
- '''!''' means we open the page in a new tab

## use different navigation/sidebar depending sub directories

- the sidebar & navbar can be on sub directories
- if you jump to a page which is in  a dir which has a sidebar.md, that one will be shown (if you used @)


```markdown
- [**Home**](@threefold:threefold_home)
--------
- [P2P Cloud Concepts](@threefold:cloud_home)
- [TFGrid 2.0 Manual](@threefold:manual2_home)
- [TFGrid 3.0 Manual](@manual:manual3_home_new)
```

- note: trick with use to allow user to go back to home easily
- note we use @ to make sure we show the sidebar of that location