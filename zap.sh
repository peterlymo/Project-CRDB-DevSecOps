#!/bin/bash

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

# first run this
# chmod 777 $(pwd)
# echo $(id -u):$(id -g)
# docker run -v $(pwd):/zap/wrk/:rw -t quay.io/anshuk6469/owaspzap-report zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -r zap_report.html


# # comment above cmd and uncomment below lines to run with CUSTOM RULES
# #docker run -v $(pwd)/zap-report:/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -c zap_rules -r zap_report.html

# exit_code=$?



# # HTML Report
#  sudo mkdir -p owasp-zap-report
#  sudo mv zap_report.html owasp-zap-report


# echo "Exit Code : $exit_code"

#  if [[ ${exit_code} -ne 0 ]];  then
#     echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
#     exit 1;
#    else
#     echo "OWASP ZAP did not report any Risk"
#  fi;



# Parameters passed from Jenkins
SCAN_TYPE=$1
TARGET=$2

# Define report directory
REPORT_DIR="/zap/wrk"
REPORT_FILE="zap_report.html"

# Start the OWASP ZAP container if not already running
if ! docker ps | grep -q owasp; then
  echo "Starting OWASP ZAP container..."
  docker run -dt --name owasp owasp/zap2docker-stable /bin/bash
fi

# Ensure the report directory exists
docker exec owasp mkdir -p $REPORT_DIR

# Execute the appropriate scan type
case "$SCAN_TYPE" in
  baseline)
    echo "Running Baseline Scan..."
    docker exec owasp zap-baseline.py -t $TARGET:$PORT -r $REPORT_DIR/$REPORT_FILE -I
    ;;
  apis)
    echo "Running API Scan..."
    docker exec owasp zap-api-scan.py -t $TARGET:$PORT -r $REPORT_DIR/$REPORT_FILE -I
    ;;
  full)
    echo "Running Full Scan..."
    docker exec owasp zap-full-scan.py -t $TARGET:$PORT -r $REPORT_DIR/$REPORT_FILE -I
    ;;
  *)
    echo "Invalid scan type: $SCAN_TYPE"
    exit 1
    ;;
esac

echo "Scan completed. Report generated at $REPORT_DIR/$REPORT_FILE"
