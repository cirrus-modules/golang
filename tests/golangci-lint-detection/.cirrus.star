load("../../lib.star", "detect_tasks")

def main(ctx):
    for task in detect_tasks():
        container = task.get("container")
        if container == None:
            continue

        image = container.get("image")
        if image == None:
            continue

        if "golangci/golangci-lint" in image:
            return []

    fail("no golangci-lint task found")
