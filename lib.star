load("cirrus", "fs", "env")
load("github.com/cirrus-modules/helpers@main", "task", "container", "script", "cache", "artifacts", "always")


def detect_tasks(versions=["latest"]):
    all_tasks = [test_task(version) for version in versions]
    if fs.exists(".golangci.yml"):
        all_tasks.append(lint_task())
    tag = env.get("CIRRUS_TAG", "")
    if tag != "" and fs.exists(".goreleaser.yml"):
        all_tasks.append(goreleaser_task())
    return all_tasks


def test_task(version="latest"):
    instructions = [
        script("get", "go get ./..."),
        script("build", "go build ./..."),
        script("test", "go test ./..."),
    ]
    if fs.exists("go.sum"):
        instructions.insert(0, cache("modules", "$GOPATH/pkg/mod", fingerprint_script=["cat go.sum"]))
    return task(
        name="Tests",
        instance=container("golang:%s" % version),
        instructions=instructions
    )

def lint_task():
    return task(
        name="Lint",
        instance=container("golangci/golangci-lint:latest"),
        instructions=[
            script("lint", "golangci-lint run -v --output.json.path golangci.json"),
            always(
                artifacts("report", "golangci.json", type="text/json", format="golangci")
            )
        ]
    )

def goreleaser_task():
    return task(
        name="Release",
        depends_on=["Tests", "Lint"],
        instance=container("goreleaser/goreleaser:latest"),
        instructions=[script("release", "goreleaser")]
    )
