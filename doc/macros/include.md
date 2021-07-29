# Include

include without specifying site:

```python
\!!!include:3bot
```

include and specify site:

```python
\!!!include:threefold:3bot
```

specify the minimal level to include, e.g. if the markdown doc to include has min header `# ...` and level is 3 it will convert it to `### ...` and all the other headers will be increased with 2 '##' as well.


```python
\!!!include:3bot level:3
```

...
