# Low-Level Function API

As well as providing convenient types for analysis.
This package also provides low-level functions for dealing with
data in its raw form.
These low-level functions are described below.

Note: Currently sorting out the docs, so its a bit of a mess.
Is there an automated way to list all functions using documenter?

---

```@meta
CurrentModule = Neuroimaging
```

## Preprocessing

### Filtering

```@docs
compensate_for_filter
```

### Referencing

```@docs
rereference
remove_template
```

### Epoching


```@docs
epoch_rejection
peak2peak
extract_epochs
```


## Channels

```@docs
match_sensors
channel_rejection
```

## Triggers

TODO: Make a type subsection similar to EEG and ASSR.

```@docs
join_triggers
validate_triggers
clean_triggers
```


## Dipoles

TODO: Make a type subsection similar to EEG and ASSR.

```@docs
find_dipoles
find_location
```
