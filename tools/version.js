import packageJSON from "../package.json" with { type: "json" };
import process from "node:process";
import semver from "semver";

import { Bumper } from "conventional-recommended-bump";

const bumper = new Bumper().loadPreset("conventionalcommits");
const recommendation = await bumper.bump();

if (!recommendation.releaseType) {
    console.error("No release type specified.\nAbort releasing ...");
    process.exit(1);
}

const version = semver.inc(packageJSON.version, recommendation.releaseType);

if (version == null) {
    console.error(
        `Version increase for release type ${recommendation.releaseType} was not successfull.\nAbort releasing ...`
    );
    process.exit(1);
}

console.log(version);
