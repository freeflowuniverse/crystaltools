# Section Examples


```charty
{
  "title":  "Labels and numbers",
  "config": {
    "type":    "section",
    "labels":  true,
    "numbers": true
  },
  "data": [
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2010", "value": 0.2 },
    { "label": "2012", "value": 0.3 }
  ]
}
```

```charty
{
  "title":  "Labels, no numbers",
  "config": {
    "type":    "section",
    "labels":  true,
    "numbers": false
  },
  "data": [
    { "label": "2012", "value": 0.1, "color": "var(--mb-colour-blue)"   },
    { "label": "2010", "value": 0.2, "color": "var(--mb-colour-green)"  },
    { "label": "2012", "value": 0.3, "color": "var(--mb-colour-yellow)" }
  ]
}
```

```charty
{
  "title":  "No labels or numbers",
  "config": {
    "type":    "section",
    "labels":  false,
    "numbers": false
  },
  "data": [
    { "label": "2012", "value": 0.1, "color": "var(--mb-colour-blue)"   },
    { "label": "2010", "value": 0.2, "color": "var(--mb-colour-green)"  },
    { "label": "2012", "value": 0.3, "color": "var(--mb-colour-yellow)" }
  ]
}
```


```json
charty:
{
  "title":  "Labels and numbers",
  "config": {
    "type":    "section",
    "labels":  true,
    "numbers": true
  },
  "data": [
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2012", "value": 0.1 },
    { "label": "2010", "value": 0.2 },
    { "label": "2012", "value": 0.3 }
  ]
}

charty:
{
  "title":  "Labels, no numbers",
  "config": {
    "type":    "section",
    "labels":  true,
    "numbers": false
  },
  "data": [
    { "label": "2012", "value": 0.1, "color": "var(--mb-colour-blue)"   },
    { "label": "2010", "value": 0.2, "color": "var(--mb-colour-green)"  },
    { "label": "2012", "value": 0.3, "color": "var(--mb-colour-yellow)" }
  ]
}

charty:
{
  "title":  "No labels or numbers",
  "config": {
    "type":    "section",
    "labels":  false,
    "numbers": false
  },
  "data": [
    { "label": "2012", "value": 0.1, "color": "var(--mb-colour-blue)"   },
    { "label": "2010", "value": 0.2, "color": "var(--mb-colour-green)"  },
    { "label": "2012", "value": 0.3, "color": "var(--mb-colour-yellow)" }
  ]
}


```

> back to home [charts](charts)