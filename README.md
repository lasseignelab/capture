# CAPTURE
> Build reproducible, FAIR computational workflows from the start.

Starting a computational science project means navigating countless decisions about structure, tooling, and reproducibility—and even experienced developers struggle to get it right.

CAPTURE (Custom Analysis Pipelines Tailored for Universal Reproducibility and Efficiency) is a framework and command line interface (CLI) that standardizes these decisions through strong conventions for project structure, execution, and validation, enabling teams to build scalable, reproducible, and FAIR workflows from the start.

## Why CAPTURE?

CAPTURE helps you build computational science projects that are consistent, reproducible, and scalable—without reinventing the wheel each time.

- **Standardized project structure**:
  Organize data, code, and results using consistent, predictable conventions.

- **Reproducible execution**:
  Run analyses in controlled, versioned environments across HPC systems.

- **Built-in validation and verification**:
  Ensure outputs are correct and reproducible with automated checks.

- **Seamless HPC integration**:
  Scale workflows across HPC clusters without rewriting pipelines.

- **Integrated version control workflows**:
  Leverage Git and GitHub best practices for collaboration and traceability.

- **Convention over configuration**:
  Reduce decision fatigue by adopting opinionated defaults that promote best practices.

- **FAIR-ready by design**:
  Produce outputs that are Findable, Accessible, Interoperable, and Reusable.

## Quick Start
Get up and running with CAPTURE in minutes by completing the following steps in an HPC terminal session.

### 1. Install CAPTURE
```
curl -sSL https://raw.githubusercontent.com/lasseignelab/capture/refs/heads/main/install.sh | bash
source ~/.bash_profile

```

### 2. Initialize a new project
```
cap new my-project
cd my-project

```
This creates a standardized project structure for data, code, results, and configuration.

### 3. Run an example workflow
```
cap run src/example.sh
head data/*

```
CAPTURE will execute the workflow using its built-in conventions for job execution, logging, and output organization.

### 4. Verify results
```
cap verify verifications/example.sh
git diff verfications/example.out

```
Outputs are checked for consistency and reproducibility. The example results reproduced if there is no difference in `verifications/example.out`.

Congratulations!! You now have a fully structured, reproducible computational project.

## Documentation
Full CAPTURE documentaion can be found [here](DOCUMENTATION.md).

## Contributions
### Tests
All pull requests must include BATS tests covering the changes.

The testing framework is installed by the following command.
```
tests/install
```
The entire test suite is executed by the following command.
```
tests/run
```
The tests can be filtered with the --filter option.  This saves time by
allowing subsets of the test suite to be ran while coding. The following
examples of using --filter are based on this hypothetical BATS test.
```
@test "cap md5: All files in a folder" {
  ...
}
```
#### Examples of using --filter
How to run just the `cap md5` tests:
```
tests/run --filter "cap md5"
```

How to run just the single hypothetical test:
```
tests/run --filter "cap md5: All files in a folder"
```
