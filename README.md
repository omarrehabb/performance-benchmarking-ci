# Automated Performance Benchmarking with JMeter and GitHub Actions

This repository demonstrates an automated approach to performance benchmarking for web applications using **Apache JMeter** and **GitHub Actions**. It integrates a full CI/CD-compatible pipeline to test, collect, transform, and visualize performance metrics over time.

---

## 📌 Project Overview

This project automates the performance benchmarking of the **TeaStore** microservices application using JMeter and GitHub Actions. The main goals are:

- Automate the execution of JMeter performance tests
- Integrate these tests into a CI/CD workflow using GitHub Actions
- Convert raw `.jtl` results into structured `.json`
- Push results to a `gh-pages` branch for visualization via GitHub Pages

---

## 🛠️ Tools and Technologies

- **Apache JMeter** – for load testing
- **GitHub Actions** – for CI/CD automation
- **Docker + Docker Compose** – for containerized TeaStore deployment
- **Python** – for converting `.jtl` to `.json`
- **GitHub Pages** – for storing and visualizing benchmark trends
- **benchmark-action/github-action-benchmark** – for tracking performance over time

---

## 🚀 How It Works

1. **CI Trigger** – The workflow runs on every `push` or `pull_request`.
2. **Setup Phase** – Installs Java, Maven, Docker, and sets up the TeaStore app.
3. **Benchmark Execution** – Runs JMeter in headless mode via a shell script.
4. **Data Transformation** – Converts `.jtl` results to a structured JSON format using a Python script.
5. **Artifact Upload** – Uploads the JSON output as a GitHub Actions artifact.
6. **Trend Visualization** – Uses `github-action-benchmark` to push results to the `gh-pages` branch and track performance history.

---

## 📄 Example Commands

**Run JMeter test manually (optional):**
```bash
jmeter -n -t .github/performance_tests/teastore_test_plan.jmx \
  -l .github/performance_tests/results/test.jtl
```
**Convert jtl to json manually (optional):**
```bash
python3 .github/scripts/jtl_to_json.py \
  ".github/performance_tests/results/*.jtl" \
  .github/performance_tests/results/benchmark-results.json
```
---
## 📊 Benchmark Visualization
The performance history is visualized using GitHub Pages and the results are available at:
https://omarrehabb.github.io/performance-benchmarking-ci/dev/bench/

