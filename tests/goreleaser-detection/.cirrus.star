load("../../lib.star", "detect_tasks")

def main(ctx):
    for task in detect_tasks():
        container = task.get("container")
        if container == None:
            continue

        image = container.get("image")
        if image == None:
            continue

        if "goreleaser/goreleaser" in image:
            return []

    fail("no GoReleaser task found")
