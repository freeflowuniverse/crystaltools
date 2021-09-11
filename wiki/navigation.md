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
- [TFGrid 2.0 Manual](/tfgrid2/tfgrid2)
- [TFGrid 3.0 Manual](/tfgrid3/tfgrid3)
```

> note how to use /$dirname/$name_of_home_page_in_dir

important to start the link to a subdir with separate sidebar with / and name of the dir

so in this case /tfgrid2/ is a subdir and has page with name tfgrid2

```markdown
- [**Home**](readme)
-----------
**Manual v2.0**
- [eVDC](/tfgrid2/evdc_overview)
  - [What is eVDC?](/tfgrid2/evdc)
  - [Get Started](/tfgrid2/evdc_getting_started)
    - [Create](/tfgrid2/evdc_create)
    - [Access](/tfgrid2/evdc_access)
    - [My VDC](/tfgrid2/evdc_my_evdc)
    - [Manage Compute Nodes](/tfgrid2/evdc_
```

> note the trick how we link back to home

> carefull: all links on this section too need to start with /tfgrid2/ otherwise you will jump back to navigation on root