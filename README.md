# Starlark Cirrus templates for Go projects

## Quick start

```python
load("github.com/cirrus-templates/golang", "detect_tasks")

def main(ctx):
    return [detect_tasks()]
```

## Available functions

* `lint_task` - configures [`golangci-lint`](https://github.com/golangci/golangci-lint) task.
* `test_task(version="latest")` - configures `go test` task with modules cached if `go.mod` exists. Go version can be specified via `version` argument.
* `goreleaser_task` - configures [`goreleaser`](https://goreleaser.com/) task.
* `detect_tasks(versions=["latest"])` - configures all of the above tasks if possible.
