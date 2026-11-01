const { App, Stack } = require("aws-cdk-lib");
const { Bucket, BucketAccessControl } = require("aws-cdk-lib/aws-s3");

const app = new App();
const stack = new Stack(app, "AdaptersSample", { analyticsReporting: false });
new Bucket(stack, "Logs", {
  accessControl: app.node.tryGetContext("public") === "true" ? BucketAccessControl.PUBLIC_READ : BucketAccessControl.PRIVATE,
});
