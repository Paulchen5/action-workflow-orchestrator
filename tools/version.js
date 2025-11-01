import { version } from "../package.json" with { type: "json" };
import process from "node:process";
import semver from "semver";

import { Bumper } from "conventional-recommended-bump";

const bumper = new Bumper().loadPreset("conventionalcommits");
const recommendation = await bumper.bump();

if (!recommendation.releaseType) {
    console.error("No release type specified.\nAbort releasing ...");
    process.exit(1);
}

const newVersion = semver.inc(version, recommendation.releaseType);

if (newVersion == null) {
    console.error(
        `Version increase for release type ${recommendation.releaseType} was not successfull.\nAbort releasing ...`
    );
    process.exit(1);
}

console.log(newVersion);
