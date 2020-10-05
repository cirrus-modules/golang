load("cirrus", "fs", "env")
load("github.com/cirrus-templates/helpers", "task", "container", "script", "cache", "artifacts", "always")


def detect_tasks(versions=["latest"], env={}):
    all_tasks = [test_task(version, env) for version in versions]
    if fs.exists(".golangci.yml"):
        all_tasks.append(lint_task(env))
    tag = env["CIRRUS_TAG"]
    if tag != "" and fs.exists(".goreleaser.yml"):
        all_tasks.append(goreleaser_task(env))
    return all_tasks


def test_task(version="latest", env={}):
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
        env=env,
        instructions=instructions
    )

def lint_task(env={}):
    return task(
        name="Lint",
        instance=container("golangci/golangci-lint:latest"),
        env=env,
        instructions=[
            script("lint", "golangci-lint run -v --out-format json > golangci.json"),
            always(
                artifacts("report", "golangci.json", type="text/json", format="golangci")
            )
        ]
    )

def goreleaser_task(env={}):
    return task(
        name="Release",
        depends_on=["Test", "Lint"],
        instance=container("goreleaser/goreleaser:latest"),
        env=env,
        instructions=[script("release", "goreleaser")]
    )
