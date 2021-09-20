# Navigation

## navbar.md

is the top navigation element

```markdown
- ThreeFold
  - [ThreeFold Website](https://threefold.io)
  - [ThreeFold Blog](https://threefold.io/blog)
  - [TF Knowledge Base](https://threefold.io/info/threefold)
  - [TFGrid Capacity Explorer](https://explorer.threefold.io/)
  - [TF Token Stats](https://tokenstats.threefoldtoken.com/)
  - [TFGrid Manual](https://threefold.io/info/sdk)

```

## sidebar.md

Example with line in between

```markdown

- [**Home**](readme)
-----------

- [Release Notes](cloud:releasenotes)
- [Team](team)

```

## sidebar/navbar different per subdir

the sidebar & navbar can be on sub directories

```markdown
- [Home](readme)
- [P2P Cloud Concepts](cloud:cloud_home)
- [TFGrid 2.0 Manual](tfgrid2)
- [TFGrid 3.0 Manual](/tfgrid3/tfgrid3)
```

> note how to use /$dirname/$name_of_home_page_in_dir

important to start the link to a subdir with separate sidebar with / and name of the dir

so in this case  is a subdir and has page with name tfgrid2

```markdown
- [**Home**](readme)
-----------
**Manual v2.0**
- [eVDC](evdc_overview)
  - [What is eVDC?](evdc)
  - [Get Started](evdc_getting_started)
    - [Create](evdc_create)
    - [Access](evdc_access)
    - [My VDC](evdc_my_evdc)
    - [Manage Compute Nodes](evdc_
```

> note the trick how we link back to home

> carefull: all links on this section too need to start with  otherwise you will jump back to navigation on root