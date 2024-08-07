import { FormattedMessage } from "react-intl";
import { InferType } from "yup";

import { Box } from "components/ui/Box";
import { Text } from "components/ui/Text";

import { JobStats } from "./JobStats";
import { ConnectionTimelineEventActions } from "../ConnectionTimelineEventActions";
import { ConnectionTimelineEventIcon } from "../ConnectionTimelineEventIcon";
import { ConnectionTimelineEventItem } from "../ConnectionTimelineEventItem";
import { ConnectionTimelineEventSummary } from "../ConnectionTimelineEventSummary";
import { syncEventSchema } from "../types";
import { getStatusByEventType, getStatusIcon, titleIdMap } from "../utils";

interface SyncEventProps {
  syncEvent: InferType<typeof syncEventSchema>;
}

export const SyncEventItem: React.FC<SyncEventProps> = ({ syncEvent }) => {
  const titleId = titleIdMap[syncEvent.eventType];

  const jobStatus = getStatusByEventType(syncEvent.eventType);

  return (
    <ConnectionTimelineEventItem>
      <ConnectionTimelineEventIcon icon="sync" statusIcon={getStatusIcon(jobStatus)} />
      <ConnectionTimelineEventSummary>
        <Text bold>
          <FormattedMessage id={titleId} />
        </Text>
        <Box pt="xs">
          <JobStats {...syncEvent.summary} />
        </Box>
      </ConnectionTimelineEventSummary>
      <ConnectionTimelineEventActions
        createdAt={syncEvent.createdAt}
        eventId={syncEvent.id}
        jobId={syncEvent.summary.jobId}
      />
    </ConnectionTimelineEventItem>
  );
};
