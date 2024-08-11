/*
 * Copyright (c) 2020-2024 Airbyte, Inc., all rights reserved.
 */

package io.airbyte.commons.features;

import java.util.function.Function;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Feature Flags pulled from Environment Variables. This is the old way of doing things.
 */
public class EnvVariableFeatureFlags implements FeatureFlags {

  private static final Logger log = LoggerFactory.getLogger(EnvVariableFeatureFlags.class);
  // Set this value to true to see all messages from the source to destination, set to one second
  // emission
  public static final String LOG_CONNECTOR_MESSAGES = "LOG_CONNECTOR_MESSAGES";

  @Override
  public boolean logConnectorMessages() {
    return getEnvOrDefault(LOG_CONNECTOR_MESSAGES, false, Boolean::parseBoolean);
  }

  /**
   * Get env variable.
   *
   * @param key name of env variable
   * @param defaultValue default value if env variable is not present
   * @param parser function to parse the env variable
   * @param <T> type of the env variable
   * @return the env variable
   */
  // TODO: refactor in order to use the same method than the ones in EnvConfigs.java
  public <T> T getEnvOrDefault(final String key, final T defaultValue, final Function<String, T> parser) {
    final String value = System.getenv(key);
    if (value != null && !value.isEmpty()) {
      return parser.apply(value);
    } else {
      log.debug("Using default value for environment variable {}: '{}'", key, defaultValue);
      return defaultValue;
    }
  }

}
