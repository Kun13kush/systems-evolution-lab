# End-to-End DevOps Pipeline Evolution (Manual → Automated)

## Overview

This project is a hands-on exploration of how application deployment systems evolve—from manual processes to structured, automated DevOps pipelines.

Instead of starting with tools, I began by manually provisioning infrastructure and deploying an application, then progressively optimized each layer after experiencing real limitations and failures.

---

## What This Project Covers

This project is built in stages:

### 1. Manual Setup

* Manual infrastructure provisioning
* Manual server configuration
* Manual application deployment
* Encountered issues like inconsistency and missed steps

---

### 2. Bash Automation

* Automated the full workflow using Bash scripts
* Improved repeatability
* Faced challenges with:

  * Script complexity
  * Maintainability
  * Idempotency

---

### 3. Infrastructure as Code (Terraform)

* Replaced manual provisioning with Terraform
* Introduced structured, repeatable infrastructure

---

### 4. Configuration Management (Ansible)

* Automated server configuration
* Improved consistency across environments

---

### 5. Runtime & Containerization (In Progress)

* Moving toward Docker for environment consistency

---

### 6. CI/CD Pipeline (Planned)

* Automating deployment using GitHub Actions

---

## Key Focus Areas

* Understanding failure points in manual and scripted systems
* Designing for reliability and repeatability
* Exploring how DevOps tools abstract complexity
* Building systems that can work under real-world constraints

---

## Tech Stack

* Terraform
* Ansible
* Bash
* Docker (in progress)
* GitHub Actions (planned)

---

## Why This Project Exists

Most DevOps learning focuses on tools.

This project focuses on:

> **Why those tools exist in the first place.**

By experiencing failures directly, I aim to build a deeper understanding of system design, reliability, and automation.

---

## Repository Structure

.
├── ansible/              # Configuration management (server setup)
│   ├── inventory/
│   ├── playbooks/
│   └── ansible.cfg
│
├── terraform/            # Infrastructure provisioning (AWS resources)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│
├── scripts/              # Bash automation (pre-tooling stage)
│   ├── provision.sh
│   ├── configure-server.sh
│   ├── deploy.sh
│   ├── cleanup.sh
│   └── ...
│
├── systemd/              # Service management configuration
│
├── views/                # Application frontend (EJS templates)
│
├── docs/                 # Supporting documentation & guides
│
├── architecture/         # System design diagrams
│
├── server.js             # Application entry point
├── package.json
└── README.md

---

## Status

🚧 In Progress — currently working on runtime and CI/CD layers

