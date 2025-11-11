import { FeatureSet } from "@src/core/services/features/types";
import { Experiments } from "@src/hooks/services/Experiment/experiments";

declare namespace Cypress {
  interface AUTWindow {
    document: Document;
    navigator: Navigator;
    _e2eOverwrites?: Partial<Experiments>;
    _e2eFeatureOverwrites?: FeatureSet;
  }
}
