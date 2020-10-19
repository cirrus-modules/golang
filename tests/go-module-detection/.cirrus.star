load("../../lib.star", "detect_tasks")

def main(ctx):
    for task in detect_tasks():
        if task["name"] != "Tests":
            continue

        if task.get("modules_cache"):
            return []

    fail("no modules_cache instruction found")
