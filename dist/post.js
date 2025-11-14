import * as fs from "fs/promises";
import * as cache from "@actions/cache";
import * as core from "@actions/core";
import * as github from "@actions/github";
const QUEUE_FILE = ".workflow-orchestrator.json";
const ENABLE_CROSS_OS_ARCHIVE = true;
const data = await fs.readFile(QUEUE_FILE, "utf8");
const queue = JSON.parse(data);
const group = core.getInput("group", { required: true });
if (!queue.group) {
    core.warning(`No queue found for group '${group}'.`);
    process.exit(0);
}
if (!queue.group.includes(github.context.runId)) {
    core.warning(`Current run ID ${github.context.runId} not found in queue for group '${group}'.`);
    process.exit(0);
}
const runId = queue.group.shift();
if (runId != github.context.runId) {
    core.warning(`Current run ID ${github.context.runId} is not at the front of the queue for group '${group}'.`);
    process.exit(0);
}
await fs.writeFile(QUEUE_FILE, JSON.stringify(queue), "utf8");
cache.saveCache([QUEUE_FILE], group, {}, ENABLE_CROSS_OS_ARCHIVE);
core.info(`Updated queue file '${QUEUE_FILE}' with current run ID ${github.context.runId}.`);
