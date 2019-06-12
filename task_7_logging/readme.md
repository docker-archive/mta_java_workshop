# Container log collection

This task offers two examples to configure centralized logging for Docker container platform.
Use either [ELK stack and Journalbeat](./elk/readme.md) or [Splunk](./splunk/readme.md) logging option.

>As you go through this exercise think about what different types of logs (platform, app, etc.) and level of log entries you need to collect by default. It's important to understand what log entries you want to have during normal operation vs. emergency situations vs. testing and debugging etc.

The approach provided in these exercises to configure log driver on daemon level to send all logs to Splunk or ELK (or other centralized logging solution) may or may **not** work for every organization. When you set daemon level log driver, it applies logging configuration by default to each new container. When you have 100's, 1000's, 10000's and more containers running on the platform, you may see log consumers (e.g. Splunk, Sysdig, ELK, etc.) to be chocking on the aggregate amount of logs produced by running containers. It is important to understand what level of logging you want to have by default and what specific stacks/deployments should have.
