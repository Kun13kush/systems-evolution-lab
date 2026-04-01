# End-to-End DevOps Pipeline Evolution (Manual → Automated)

## Overview

This project is a hands-on exploration of how application deployment systems evolve—from manual processes to structured, automated DevOps pipelines.

Instead of starting with tools, I began by manually provisioning infrastructure and deploying an application, then progressively optimized each layer after experiencing real limitations and failures.

The goal is not just to use DevOps tools—but to understand **why they exist**, and what problems they are designed to solve.

---

## What This Project Covers

This project is built in stages, each representing a step in the evolution of real-world systems:

### 1. Manual Setup

* Manual infrastructure provisioning
* Manual server configuration
* Manual application deployment
* Encountered issues such as:

  * Inconsistency across environments
  * Missed steps
  * Lack of repeatability

---

### 2. Bash Automation

* Automated the full workflow using Bash scripts
* Improved repeatability and speed
* Faced challenges with:

  * Script complexity
  * Maintainability
  * Idempotency
  * Error handling at scale

---

### 3. Infrastructure as Code (Terraform)

* Replaced manual provisioning with Terraform
* Introduced declarative infrastructure
* Improved reproducibility and consistency

---

### 4. Configuration Management (Ansible)

* Automated server configuration
* Eliminated manual drift between environments
* Improved maintainability and scalability

---

### 5. Runtime & Containerization (In Progress)

* Transitioning to Docker for consistent runtime environments
* Reducing dependency on host-specific configurations

---

### 6. CI/CD Pipeline (Planned)

* Automating build and deployment workflows using GitHub Actions
* Moving toward continuous integration and delivery

---

## Key Focus Areas

* Understanding failure points in manual and scripted systems
* Designing for reliability and repeatability
* Exploring how DevOps tools abstract complexity
* Building systems that can operate under real-world constraints
* Learning how system design evolves through iteration and failure

---

## ⚙️ Automation (Pre-Tooling Stage)

Before introducing tools like Terraform and Ansible, the system was fully automated using Bash scripts.

These scripts handle:

* Infrastructure provisioning
* Server configuration
* Application deployment
* Environment reset (cleanup)

### Key Insight

As the system grew, these scripts became:

* Hard to maintain
* Difficult to scale
* Challenging to make idempotent

This led to the transition toward structured DevOps tools.

---

## 🔁 Environment Reset

The project includes a `cleanup` script that resets the entire environment.

This enables:

* Repeated testing of failure scenarios
* Fast iteration across different system states
* Controlled experimentation when validating system behavior

---

## 🏗️ System Architecture

The project includes architecture diagrams that illustrate how the system is structured across multiple layers:

* Infrastructure layer
* Configuration layer
* Application runtime
* Deployment workflow

These diagrams help visualize how each component interacts within the system.

*(Add your architecture image here)*

---

## 📚 Documentation

The `/docs` directory contains:

* Step-by-step guides for manual infrastructure provisioning
* Manual application deployment processes
* Supporting notes for understanding system evolution

These documents represent the **manual stage of the system**, before automation and tooling were introduced.

---

## 🤝 Learning & Collaboration

This project also serves as a guided learning environment for others exploring DevOps concepts.

It includes:

* Structured playbooks
* Guided workflows for building each stage
* Emphasis on understanding *why systems are designed the way they are*

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

By intentionally experiencing failures and rebuilding systems, this project aims to develop a deeper understanding of system design, reliability, and automation.

---

## 📁 Repository Structure

```bash
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
├── docs/                 # Manual processes & learning documentation
│
├── architecture/         # System design diagrams
│
├── server.js             # Application entry point
├── package.json
└── README.md
```

---

## Status

🚧 In Progress — currently working on runtime and CI/CD layers