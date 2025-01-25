package com.devsecops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
public class NumericController {

    private final Logger logger = LoggerFactory.getLogger(getClass());
    private static final String baseURL = "http://node-service:5000/plusone";

    private final RestTemplate restTemplate = new RestTemplate();

    @GetMapping("/")
    public String welcome() {
        return "Kubernetes DevSecOps";
    }

@GetMapping("/compare/{value}")
public String compareToFifty(@PathVariable int value) {
    return value > 50 ? "Greater than 50" : "Smaller than or equal to 50";
}

    @GetMapping("/increment/{value}")
    public int increment(@PathVariable int value) {
        ResponseEntity<String> responseEntity = restTemplate.getForEntity(baseURL + '/' + value, String.class);
        String response = responseEntity.getBody();
        logger.info("Value Received in Request - {}", value);
        logger.info("Node Service Response - {}", response);
        return Integer.parseInt(response);
    }
}
