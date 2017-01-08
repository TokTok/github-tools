// 1. Any 3 reviewers must have reviewed the file at the latest revision.
// 2. 3/5 (minimum of 1) of the assigned reviewers must have given LGTM at any revision
// 3. There must be no open comments from any assigned reviewers.
// 4. at least 1 person in the admin list must have given a LGTM at the latest revision.
//
// This code will check that all discussions have been resolved,
// and all files reviewed at the latest revision by all the
// assignees and by at least the required number of people, while
// ignoring the pull request's author.  It makes use of Lodash
// (_), which is supplied by the execution environment.



const numReviewersRequired = 3; // TODO(grayhatter) do we want to calculate this number by size of diff, or number of files?
// Part 1 Check that each file has been reviewed by at least numReviewersRequired at the latest revision.
const unreviewedFiles = _(review.files)
  .filter(file => _.size(_.last(file.revisions).reviewers) < numReviewersRequired)
    .value();

// Part 2 Verify there are no open comments of assigned reviewers
const fileBlockers = _(unreviewedFiles)
  .map(file => _(file.revisions)
    .pluck('reviewers')
    .flatten()
    .pluck('username')
    .uniq()
    .difference(_.pluck(_.last(file.revisions).reviewers, 'username'))
    .value()
  )
  .flatten()
  .uniq()
  .value();

const assignees = _.pluck(review.pullRequest.assignees, 'username');
const unresolvedDiscussions = _(review.discussions)
  .where({resolved: false})
  .filter(discussion => _.intersection(
    _(discussion.participants).where({resolved: false}).pluck('username').value(),
    assignees
  ))
  .value();

const discussionBlockers = _(unresolvedDiscussions)
  .pluck('participants')
  .flatten()
  .where({resolved: false})
  .pluck('username')
  .uniq()
  .intersection(assignees)
  .value();

// Gather LGTM info
const lastRevisionTimestamp = _.last(review.revisions).snapshotTimestamp;
// Approval by username: true if current LGTM, false if stale, missing if not given or canceled.
const approvals = {};
_.each(review.sentiments, function(sentiment) {
  const emojis = _.indexBy(sentiment.emojis);
  if (emojis.lgtm_cancel) {
    delete approvals[sentiment.username];
  } else if (emojis.lgtm_strong) {
    approvals[sentiment.username] = true;
  } else if (emojis.lgtm && !approvals[sentiment.username]) {
    approvals[sentiment.username] =
      sentiment.timestamp >= lastRevisionTimestamp;
  }
});


// Part 2 Check that everyone assigned has LGTM'd at some point
const lgtmBlockers = _.filter(assignees, username => !_.has(approvals, username));

// Part 4 Check that a trusted reviewer has a current LGTM.
const trustedReviewers = ['GrayHatter', 'iphydf', 'nurupo'];
const adminApproved = _.some(trustedReviewers, username => approvals[username]);

// Combine the above to compute final status
const completed = !unreviewedFiles.length && !unresolvedDiscussions.length && !lgtmBlockers.length && adminApproved;

// Generate the status message
const pendingReviewers = _(fileBlockers)
  .concat(discussionBlockers, lgtmBlockers, adminApproved ? [] : trustedReviewers)
  .uniq()
  .value();

const descriptionPieces = [];
if (unreviewedFiles.length) {
  descriptionPieces.push(`${unreviewedFiles.length} files need more reviewers`);
}
if (unresolvedDiscussions.length) {
  const s = unresolvedDiscussions.length == 1 ? '' : 's';
  descriptionPieces.push(`${unresolvedDiscussions.length} open discussion${s} remaining`);
}
if (lgtmBlockers.length) {
  descriptionPieces.push(`${lgtmBlockers.length} assignee LGTMs are missing`);
}

if (!adminApproved) {
  descriptionPieces.push(`missing Admin LGTM at current revision.`);
}

return {
  completed, 
  description: descriptionPieces.join(', '),
  pendingReviewers: pendingReviewers.join(', '), 
  debug: approvals
};
