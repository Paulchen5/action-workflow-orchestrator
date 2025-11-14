import * as fs from "fs/promises";
import * as cache from "@actions/cache";
import * as core from "@actions/core";
import * as github from "@actions/github";
const QUEUE_FILE = ".workflow-orchestrator.json";
const ENABLE_CROSS_OS_ARCHIVE = true;
export function getInputs() {
    const settings = {};
    settings.group = core.getInput("group", { required: true });
    return settings;
}
async function run() {
    if (!cache.isFeatureAvailable()) {
        core.setFailed("Workflow Orchestrator failed: The cache service is not available for this action runner.");
        return;
    }
    core.debug(`GitHub Context: ${JSON.stringify(github.context, null, 2)}`);
    try {
        core.info("Workflow Orchestrator is initializing...");
        const settings = getInputs();
        core.debug(`Settings: ${JSON.stringify(settings, null, 2)}`);
        core.info(`Workflow Orchestrator started for group '${settings.group}'`);
        const primaryKey = settings.group;
        const cachePaths = [QUEUE_FILE];
        const cacheKey = await cache.restoreCache(cachePaths, primaryKey, [], { lookupOnly: false }, ENABLE_CROSS_OS_ARCHIVE);
        if (!cacheKey) {
            core.info(`No cache found for group '${primaryKey}'. Creating new queue file...`);
            await fs.writeFile(QUEUE_FILE, JSON.stringify({ primaryKey: [github.context.runId] }), "utf8");
            core.info(`Queue file '${QUEUE_FILE}' created.`);
        }
        else {
            let isPending = true;
            do {
                const data = await fs.readFile(QUEUE_FILE, "utf8");
                const queue = JSON.parse(data);
                if (!queue.primaryKey) {
                    queue.primaryKey = [github.context.runId];
                }
                if (!queue.primaryKey.includes(github.context.runId)) {
                    // Add current run to the queue
                    queue.primaryKey.push(github.context.runId);
                    await fs.writeFile(QUEUE_FILE, JSON.stringify(queue), "utf8");
                    cache.saveCache(cachePaths, primaryKey, {}, ENABLE_CROSS_OS_ARCHIVE);
                    core.info(`Updated queue file '${QUEUE_FILE}' with current run ID ${github.context.runId}.`);
                }
                const startedRunId = queue.primaryKey[0];
                if (startedRunId == github.context.runId) {
                    isPending = false;
                    break;
                }
                core.info(`⏱ Waiting for previous workflow run ${startedRunId} to complete...`);
                // Wait for the previous workflow run to complete
                // const octokit = github.getOctokit(core.getInput("github-token", { required: true }));
                // const { data: run } = await octokit.rest.actions.getWorkflowRun({
                //     owner: github.context.repo.owner,
                //     repo: github.context.repo.repo,
                //     run_id: startedRunId
                // });
                // Wait for 10 seconds before checking again
                await new Promise((resolve) => setTimeout(resolve, 10000));
            } while (false);
        }
    }
    catch (error) {
        if (error instanceof Error) {
            core.setFailed(`Workflow Orchestrator failed: ${error.message}`);
            return;
        }
        else {
            core.setFailed(`Workflow Orchestrator failed: ${error}`);
        }
    }
}
if (!core.getState("isPost")) {
    run();
}
else {
    core.setFailed("Main job was called on post job.");
}
