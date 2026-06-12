#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#!/bin/bash
set -euo pipefail

# Optional: download the official Apache Fluss Helm chart for offline use.
# Normal deployments use the public chart repo directly (see k8s/deploy.sh).
# The chart is extracted to helm-charts/fluss/ (gitignored).
#
# Usage:
#   source ../default.env.sh --fluss-version VERSION
#   ./download-helm-chart.sh

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
HELM_CHARTS_DIR="${SCRIPT_DIR}/helm-charts"

if [ -z "${FLUSS_VERSION:-}" ]; then
    echo "Error: FLUSS_VERSION is not set." >&2
    echo "Usage:" >&2
    echo "  source ../default.env.sh --fluss-version VERSION" >&2
    echo "  ./download-helm-chart.sh" >&2
    exit 1
fi

CHART_URL="https://downloads.apache.org/incubator/fluss/helm-chart/fluss-${FLUSS_VERSION}.tgz"

echo "Downloading Fluss Helm chart version ${FLUSS_VERSION}..."

# Create helm-charts directory if it doesn't exist
mkdir -p "${HELM_CHARTS_DIR}"

# Download chart
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

cd "${TEMP_DIR}"
curl -L -o "fluss-${FLUSS_VERSION}.tgz" "${CHART_URL}"

# Extract chart
tar -xzf "fluss-${FLUSS_VERSION}.tgz"

# Copy to helm-charts directory
if [ -d "fluss" ]; then
    rm -rf "${HELM_CHARTS_DIR}/fluss"
    cp -r "fluss" "${HELM_CHARTS_DIR}/"
    echo "✓ Fluss Helm chart extracted to ${HELM_CHARTS_DIR}/fluss"
else
    echo "Error: Chart extraction failed"
    exit 1
fi

echo "Chart download complete!"
