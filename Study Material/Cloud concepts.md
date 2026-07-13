\# 30-Day Ansible \& Cloud Engineer Roadmap



\*Fundamentals → production Ansible → AWS automation → DevOps integration → portfolio-ready Junior Cloud Engineer\*



\*\*Time commitment:\*\* 3–5 hrs/day (avg \~4.3h/day across the plan) · \*\*Primary cloud:\*\* AWS, with Azure/GCP as pattern-transfer bonus content · \*\*Format:\*\* taught one day at a time, in order, after you finish the day before



\---



\## How this document works



This is the master plan — the table of contents for the next 30 days, not the lessons themselves. When you say "start Day 1," we run the full structure from your brief for that day: concept → why it exists → what problem it solves → internals → common mistakes → production best practices → interview questions → analogies → ASCII diagrams → hands-on lab → mini-project → troubleshooting → debugging → performance → security → revision notes → quiz. That's a lot per day — which is exactly why it happens one day at a time instead of all 30 at once here.



Each entry below is deliberately compressed: a few topics, a lab pointer, a couple of sample commands, one interview angle. Enough to plan your month and see the shape of the whole thing, not enough to front-run the actual teaching.



One more thing: the specific tool/module names and version numbers below are accurate as of mid-2026 verification, but this ecosystem ships updates every few weeks (Ansible alone releases a new minor every 4 weeks). I'll re-check specifics on the day we actually use them rather than trusting what's written here by the time you get to Week 4.



\## Where you're starting from



On paper this roadmap assumes zero prior knowledge, per your brief. In practice, you run WSAI-CLUSTER — SLURM across multiple nodes, NFS from a Synology NAS, systemd drop-in overrides, SSH hardening, Prometheus/Grafana, and your own bash-based user-provisioning tooling. That changes the shape of Week 1:



\- \*\*Linux, SSH, bash, systemd, storage\*\* — you already operate past what Days 1–4 teach from scratch. Treat those days as "here's how Ansible expresses what you already do by hand," not new material.

\- \*\*YAML\*\* — the only genuinely new part is Ansible's specific conventions (quoting rules, list-of-dicts task syntax, block scalars in templates).

\- \*\*What's actually new for you:\*\* Ansible's declarative/idempotent execution model, the module abstraction layer replacing raw shell commands, and AWS-specific services and APIs.

\- \*\*A bridge worth keeping in your pocket:\*\* SLURM's controller/worker split in configless mode maps surprisingly well onto Ansible's control-node/managed-node model — one pushes job specs over the network, the other pushes task specs over SSH.



The full 30-day structure stays below rather than getting compressed, because it doubles as your interview-prep trail and portfolio narrative — but say the word on any day that's pure review and we'll move faster or merge days.



\## Scoping calls I'm making up front



A senior mentor's job includes pushing back on scope, not just agreeing to all of it. Three calls, stated plainly:



1\. \*\*AWS-first, not AWS/Azure/GCP equally.\*\* Your requested skills checklist (IAM, EC2, VPC, S3, load balancers, auto scaling, CloudWatch) is AWS-only; the three-cloud ask only shows up in the project list. Going deep on three clouds in 30 days means shallow on all three, and shallow doesn't survive an interview. AWS gets dedicated days; Azure and GCP get a pattern-transfer session on Day 17 — same Ansible cloud-module concepts, different SDK underneath, once you've internalized the pattern with AWS.

2\. \*\*Interview questions accumulate daily, not all on day one.\*\* A 250-question dump today would be disconnected from anything you've built yet, and you wouldn't retain it. Each day adds a handful tied to what you just did; by Day 30 you'll have the full bank, organized by topic — more useful for review than a wall of text with no context.

3\. \*\*Portfolio work starts Day 7, not Day 30.\*\* Push each build to GitHub as you finish it. Recruiters read commit history over time; one 30-day-later mega-commit reads as copy-pasted, even when it isn't.



\## Your 20 requested projects, mapped to days



| # | Project (as you listed it) | Lands on |

|---|---|---|

| 1 | Linux Server Provisioning | Day 7 |

| 2 | Nginx Automation | Day 10 |

| 3 | Apache Automation | Day 11 |

| 4 | Docker Installation Automation | Day 14 |

| 5 | Kubernetes Cluster Automation | Day 23 |

| 6 | User Management Automation | Day 7 (bonus: port your real wsai-adduser logic) |

| 7 | Database Deployment | Day 21 |

| 8 | Multi-tier Application Deployment | Day 21 |

| 9 | AWS EC2 Provisioning | Day 18 |

| 10 | AWS VPC Automation | Day 19 |

| 11 | AWS IAM Automation | Day 19 |

| 12 | AWS S3 Automation | Day 20 |

| 13 | Azure VM Deployment | Day 17 (bonus/pattern-transfer) |

| 14 | GCP Compute Engine Deployment | Day 17 (bonus/pattern-transfer) |

| 15 | Full Infrastructure Automation Project | Days 28–30 (capstone) |

| 16 | CI/CD Pipeline with Jenkins + Ansible | Day 25 |

| 17 | Terraform + Ansible Integration | Day 24 |

| 18 | Docker + Ansible Deployment | Day 22 |

| 19 | Kubernetes Application Deployment | Day 23 |

| 20 | Final Enterprise-Level Infrastructure Automation Project | Days 28–30 (capstone) |



\## The five phases



```

Day:     1          7 8         14 15          21 22         26 27         30

&#x20;       |--- PHASE 1 ---|--- PHASE 2 ---|---  PHASE 3   ---|--- PHASE 4 ---|--- PHASE 5 ---|

&#x20;       Foundations      Core Ansible      Advanced + AWS     DevOps Integ.   Enterprise +

&#x20;                                                                              Capstone + Job



&#x20;       IaC, SSH, YAML   Roles, Vault,     Dynamic Inv.,      Docker, K8s,    AWX/AAP,

&#x20;       Inventory,       Galaxy, Blocks,   EC2/VPC/IAM/S3,    Terraform,      Capstone build,

&#x20;       Playbooks, Vars, Includes/         Delegation/Async,  Jenkins CI/CD,  Portfolio, Resume,

&#x20;       Facts, Loops     Imports           Testing            GitOps, Monitor Mock interview

```



\## Phase overview



| Phase | Days | Focus | Hours (approx) |

|---|---|---|---|

| 1 — Foundations | 1–7 | IaC concepts, SSH/YAML review, inventory, ad-hoc, playbooks, vars, facts, templates, conditionals, loops | \~28h |

| 2 — Core Ansible Mechanics | 8–14 | Handlers, tags, blocks, idempotency, roles, Galaxy, Vault, includes/imports | \~30h |

| 3 — Advanced + Cloud (AWS) | 15–21 | Dynamic inventory, delegation/async/strategies, AWS fundamentals, EC2/VPC/IAM/S3, custom modules, performance, testing | \~32.5h |

| 4 — DevOps Integration | 22–26 | Docker, Kubernetes, Terraform, Jenkins/CI-CD, GitOps, monitoring, security, DR | \~21.5h |

| 5 — Enterprise + Capstone + Job-Ready | 27–30 | AWX/AAP, enterprise structure, capstone project, portfolio, resume, mock interview | \~17h |



\---



\## Detailed day-by-day plan



\### Phase 1 — Foundations (Days 1–7)



\#### Day 1 — Infrastructure as Code, Agentless Config Management, Why Ansible

\- Topics: IaC vs manual ops, configuration management, agent vs agentless architecture, why SSH+Python over a persistent agent, install Ansible

\- Hours: \~3h (mostly conceptual + install — fast day)

\- Lab: Install Ansible (ansible-core is in the 2.21.x line as of mid-2026, community package \~13.x — confirm with `ansible --version`, it ships a new minor every 4 weeks), run your first ad-hoc ping

\- Practice: `ansible --version`, `ansible localhost -m ping`, `ansible all -m setup`

\- Scenario: You're handed a fleet of 40 EC2 instances with no config management — why agentless wins for a team without a dedicated automation platform yet

\- Interview angle: "Why did Ansible choose SSH over a persistent agent, and what does that cost you?"

\- Checklist: \[ ] can explain IaC in one sentence \[ ] can explain push vs pull config management \[ ] Ansible installed, `ping` returns pong



\#### Day 2 — SSH Under the Hood + Ansible Connection Config

\- Topics: SSH key auth, control connection reuse (ControlPersist), `ansible.cfg`, connection variables

\- Hours: \~3.5h (review pace for you)

\- Lab: Write your first `ansible.cfg` and a 3-host inventory against real or VM test boxes

\- Practice: `ansible-config dump --only-changed`, `ansible all -m ping -vvv`

\- Scenario: Misconfigured SSH multiplexing means every task opens a fresh TCP handshake — same family of problem as the `/run/sshd` tmpfs issue you've already debugged in production

\- Interview angle: "How does Ansible avoid a new SSH handshake per task?"

\- Checklist: \[ ] `ansible.cfg` in place \[ ] ControlPersist explained \[ ] first inventory working



\#### Day 3 — YAML for Ansible + Static Inventory Deep Dive

\- Topics: YAML syntax gotchas (quoting, indentation, list-of-dicts), static inventory (INI vs YAML), groups, host\_vars, group\_vars

\- Hours: \~3.5h

\- Lab: Build a multi-group inventory (web/db/monitoring) with group\_vars and host\_vars files

\- Practice: `ansible-inventory --list`, `ansible-inventory --graph`

\- Scenario: Model your real WSAI-01/02/03 topology as an Ansible inventory instead of an ad-hoc SSH loop

\- Interview angle: "When would you use group\_vars over inline inventory variables?"

\- Checklist: \[ ] inventory graph matches intended topology \[ ] group\_vars/host\_vars precedence understood



\#### Day 4 — Ad-hoc Commands + Core Modules Tour

\- Topics: ad-hoc syntax, idempotent modules (`package`/`service`/`copy`/`file`/`user`) vs imperative (`command`/`shell`), `ansible-doc`

\- Hours: \~4h

\- Lab: Replace 5 of your everyday one-off SSH commands with ad-hoc Ansible equivalents

\- Practice: `ansible all -a "uptime"`, `ansible web -m package -a "name=nginx state=present" -b`, `ansible-doc -l`, `ansible-doc user`

\- Scenario: Emergency patch across all nodes — ad-hoc vs a full playbook, and when each is the right call

\- Interview angle: "Why avoid `shell`/`command` when a dedicated module exists?"

\- Checklist: \[ ] 5 ad-hoc commands run successfully \[ ] comfortable looking up any module with ansible-doc



\#### Day 5 — Playbooks + Variables

\- Topics: play structure (hosts/tasks/become), YAML task syntax, variable types, the real variable precedence chain, `vars`/`vars\_files`/`extra-vars`

\- Hours: \~4.5h

\- Lab: Convert Day 4's ad-hoc commands into your first playbook with variables

\- Practice: `ansible-playbook site.yml --check`, `ansible-playbook site.yml -e "env=staging"`, `ansible-playbook site.yml --list-tasks`

\- Scenario: Same playbook, different behavior per environment via `-e` vs `group\_vars/production.yml`

\- Interview angle: "extra-vars vs group\_vars vs role defaults — which wins, and why does that matter for security?"

\- Checklist: \[ ] first working playbook \[ ] can predict which variable wins in a precedence conflict



\#### Day 6 — Facts + Templates (Jinja2 basics)

\- Topics: fact gathering, `ansible\_facts` namespace, `gather\_facts: false` for speed, custom facts, Jinja2 templating, the `template` module

\- Hours: \~4.5h

\- Lab: Template an `nginx.conf` and a dynamic MOTD from host facts — you've already built a live-`sinfo` MOTD by hand; this is the Ansible-native version

\- Practice: `ansible all -m setup -a "filter=ansible\_distribution\*"`, `ansible-playbook template.yml --diff`

\- Scenario: One template, rendered differently per OS family using `ansible\_facts\['os\_family']`

\- Interview angle: "How would you speed up a playbook run against 200 hosts that doesn't need facts?"

\- Checklist: \[ ] custom fact created \[ ] one working Jinja2 template \[ ] `--diff` output understood



\#### Day 7 — Conditionals + Loops — 🎯 Build: Linux Server Provisioning

\- Topics: `when`, combining conditionals, `loop` (and why `with\_\*` is legacy now), looping over dicts/lists, `loop\_control`

\- Hours: \~5h (concept + first real project)

\- Lab + build: a provisioning playbook that creates users, installs a package set, and sets a firewall rule — conditional on OS family, looped over a user list

&#x20; - \*Your angle:\* you already run a professor/student/intern provisioning system in bash with sudo tiers and expiry logic. Reimplementing that logic's \*shape\* (not the literal script) as an idempotent, looped Ansible task is a genuinely good first project — you understand the requirements better than most people doing this exercise for the first time.

\- Practice: `ansible-playbook provision.yml --limit web --check --diff`

\- Scenario: New intern joins — one playbook run provisions their account with the correct expiry and sudo tier

\- Interview angle: "Loop vs a wrapping shell for-loop calling ansible-playbook repeatedly — what's the real difference?"

\- Checklist: \[ ] pushed to GitHub with a README \[ ] idempotent on second run (zero changes reported)



\---



\### Phase 2 — Core Ansible Mechanics (Days 8–14)



\#### Day 8 — Handlers + Tags

\- Topics: handler notify/flush semantics, `meta: flush\_handlers`, handler ordering, tags (`--tags`, `--skip-tags`, the `always`/`never` special tags)

\- Hours: \~4h

\- Lab: Add a "restart nginx on config change" handler, tag your playbook's sections for selective runs

\- Practice: `ansible-playbook site.yml --tags config`, `ansible-playbook site.yml --skip-tags slow`, `ansible-playbook site.yml --list-tags`

\- Scenario: Config-only redeploy on 50 hosts without re-running the full provisioning play

\- Interview angle: "A handler didn't fire — what are the three most likely reasons?"

\- Checklist: \[ ] handler fires only on actual change \[ ] tags let you run a subset cleanly



\#### Day 9 — Blocks, Error Handling, Idempotency Deep Dive

\- Topics: `block`/`rescue`/`always`, `ignore\_errors`, `failed\_when`/`changed\_when`, what "idempotent" actually means at the module level (check-then-act)

\- Hours: \~4.5h

\- Lab: Wrap a risky task in block/rescue/always; deliberately break idempotency, then fix it

\- Practice: `ansible-playbook site.yml --check --diff`, `ansible-playbook site.yml -vv`

\- Scenario: A deploy step fails halfway across 30 hosts — a rescue block alerts and rolls back instead of leaving hosts half-configured

\- Interview angle: "Give an example of a task that looks idempotent but isn't."

\- Checklist: \[ ] block/rescue/always used correctly \[ ] can define idempotency without notes



\#### Day 10 — Roles — 🎯 Build: Nginx Automation (role)

\- Topics: role anatomy (`tasks/handlers/templates/files/vars/defaults/meta`), `ansible-galaxy role init`, role dependencies, defaults vs vars precedence

\- Hours: \~5h

\- Lab + build: Nginx as a reusable, parameterized role that works across your K80/GTX/CPU node types

\- Practice: `ansible-galaxy role init roles/nginx`, `ansible-playbook site.yml --syntax-check`

\- Scenario: Same role, different vhost config per environment via role defaults overridden in group\_vars

\- Interview angle: "defaults/main.yml vs vars/main.yml — precedence and when you'd use each"

\- Checklist: \[ ] pushed to GitHub \[ ] role reusable against a second host group without edits



\#### Day 11 — Galaxy + Collections — 🎯 Build: Apache Automation

\- Topics: Ansible Galaxy, installing community roles/collections, `requirements.yml`, Fully Qualified Collection Names (FQCN — required going forward, not optional style)

\- Hours: \~4.5h

\- Lab + build: Apache, deployed via a Galaxy community role pinned in `requirements.yml`

\- Practice: `ansible-galaxy install -r requirements.yml`, `ansible-galaxy collection list`

\- Scenario: Pinning exact role/collection versions so a rebuild six months from now behaves identically

\- Interview angle: "Why does Ansible require FQCN now, and what broke when it didn't?"

\- Checklist: \[ ] pushed to GitHub \[ ] requirements.yml pins versions



\#### Day 12 — Ansible Vault + Secrets Management

\- Topics: `ansible-vault` encrypt/decrypt/view/edit, vault IDs, `--ask-vault-pass` vs vault password files, encrypting single strings vs whole files, Vault in CI/CD

\- Hours: \~4h

\- Lab: Encrypt a secrets file, reference it from a playbook, rotate the vault password

\- Practice: `ansible-vault create secrets.yml`, `ansible-vault encrypt\_string`, `ansible-vault rekey secrets.yml`

\- Scenario: The same pattern you'd want for NAS export secrets or provisioning credentials — never plaintext in git

\- Interview angle: "Vault password file vs prompting — tradeoffs in a CI pipeline?"

\- Checklist: \[ ] one vault-encrypted file used in a playbook \[ ] can explain the vault-id use case



\#### Day 13 — Includes vs Imports + Reusability Patterns

\- Topics: static (`import\_tasks`/`import\_playbook`) vs dynamic (`include\_tasks`/`include\_role`) — parse-time vs run-time, when each is correct

\- Hours: \~3.5h

\- Lab: Refactor a growing playbook into includes, then break it deliberately to see the parse-time vs run-time difference

\- Practice: `ansible-playbook site.yml --list-tasks` (compare output for import vs include)

\- Scenario: Conditionally including an entire task file only for GPU nodes vs CPU nodes

\- Interview angle: "You need to loop over a set of tasks — import or include, and why?"

\- Checklist: \[ ] can state the parse-time/run-time distinction without hedging



\#### Day 14 — Review + 🎯 Build: Docker Installation Automation

\- Topics: Week 1–2 review, consolidated quiz, catch-up buffer

\- Hours: \~4.5h

\- Lab + build: a role that installs Docker across Ubuntu/RHEL-family hosts, handling the repo/GPG-key differences per OS family, idempotent

\- Practice: full `ansible-lint` run against everything built so far

\- Scenario: Same role, mixed fleet — your cluster already spans different node types, so this maps directly onto real work

\- Interview angle: rapid-fire review of Days 1–13 (10 questions, mixed topics)

\- Checklist: \[ ] pushed to GitHub \[ ] `ansible-lint` passes clean on all roles so far



\---



\### Phase 3 — Advanced Ansible + Cloud (AWS) (Days 15–21)



\#### Day 15 — Dynamic Inventory + Filters/Lookups

\- Topics: inventory plugins, the `aws\_ec2` dynamic inventory plugin, Jinja2 filters deep dive (`default`, `map`, `selectattr`, `regex\_replace`), lookups (`file`, `env`, `pipe`)

\- Hours: \~4.5h

\- Lab: Configure `aws\_ec2.yml` dynamic inventory against a test AWS account (or a mocked/static stand-in if you don't have AWS access set up yet)

\- Practice: `ansible-inventory -i aws\_ec2.yml --graph`, `ansible-doc -t filter -l`

\- Scenario: Auto-target every EC2 instance tagged `role=web` without maintaining a static list

\- Interview angle: "Static vs dynamic inventory — where does each break down at scale?"

\- Checklist: \[ ] dynamic inventory returns real/mocked hosts grouped by tag



\#### Day 16 — Delegation, Async, Serial, Strategies

\- Topics: `delegate\_to`, `local\_action`, `run\_once`, async tasks + polling, `serial` (rolling batches), strategies (`linear`/`free`/`host\_pinned`)

\- Hours: \~4.5h

\- Lab: Rolling-restart a 3-node service group with `serial: 1` and a health-check gate between batches

\- Practice: `ansible-playbook rolling.yml -e "@vars.yml"`, the `async: 300` + `poll: 0` pattern

\- Scenario: Zero-downtime rolling update across your compute nodes, one at a time, aborting if a health check fails

\- Interview angle: "Why would `strategy: free` break an otherwise-correct rolling deploy?"

\- Checklist: \[ ] serial rolling update tested with an intentional failure mid-batch



\#### Day 17 — Cloud \& Networking Foundations (AWS-first, Azure/GCP bonus)

\- Topics: AWS global infra (regions/AZs), IAM (users/roles/policies), VPC (subnets/route tables/security groups), EC2, S3, shared responsibility model; DNS/HTTP/HTTPS/load-balancing refresher; Azure (`azure.azcollection`) and GCP (`google.cloud`) equivalents as a mapping table

\- Hours: \~4.5h (genuinely new material — this is the real Day 1 of "cloud" for you)

\- Lab: Set up (or confirm) an AWS account, enable MFA on root, create an IAM user for Ansible with a least-privilege policy, and set an AWS Budget alert

&#x20; - \*\*Note:\*\* if this is a new account, you're on AWS's current credit-based Free Plan ($100 on sign-up, up to $100 more for completing onboarding activities — including setting a budget, which is one of the five) with a 6-month window, not the older 12-month always-free EC2/RDS/S3 allowance. Accounts created before July 2025 keep the old model. Set the budget alert regardless — it's one of the credit-earning activities anyway.

\- Practice: `aws sts get-caller-identity`, `aws configure list`

\- Scenario: The multi-tenant shared-compute mental model transfers directly from SLURM partitions/QOS caps to AWS accounts/IAM boundaries — different tooling, same "who's allowed to touch what" problem you already solve daily

\- Interview angle: "Explain the AWS shared responsibility model in two sentences."

\- Checklist: \[ ] AWS account confirmed + budget alert set \[ ] IAM user created for Ansible with an access key, not root credentials



\#### Day 18 — 🎯 Build: AWS EC2 Provisioning with Ansible

\- Topics: `amazon.aws` collection, `boto3`/`botocore` install, `ec2\_instance` module, key pairs, security groups from Ansible

\- Hours: \~4.5h

\- Lab + build: a playbook that provisions an EC2 instance, waits for SSH, then hands off to a configuration role

\- Practice: `pip install boto3 botocore`, `ansible-galaxy collection install amazon.aws`

\- Scenario: Spin-up → configure → tear-down cycle for a disposable dev box, fully from one playbook

\- Interview angle: "How does Ansible authenticate to AWS, and where do the credentials live so they're not in git?"

\- Checklist: \[ ] pushed to GitHub \[ ] instance terminated after testing (protect your credits)



\#### Day 19 — 🎯 Build: AWS VPC + IAM Automation

\- Topics: `ec2\_vpc\_net`, `ec2\_vpc\_subnet`, `ec2\_vpc\_route\_table`, `ec2\_security\_group`, `iam\_user`/`iam\_role`/`iam\_policy` modules

\- Hours: \~5h

\- Lab + build: a playbook that builds a small VPC (2 subnets, IGW, route table) and a scoped IAM role for an app

\- Practice: `aws ec2 describe-vpcs`, `ansible-playbook vpc.yml --check`

\- Scenario: Recreate an entire network stack from a destroyed account in minutes, not a support ticket

\- Interview angle: "Walk me through scoping a least-privilege IAM policy for access to a single S3 bucket."

\- Checklist: \[ ] pushed to GitHub \[ ] VPC destroyed after testing



\#### Day 20 — 🎯 Build: AWS S3 Automation + Custom Modules Intro

\- Topics: `s3\_bucket`/`s3\_object` modules, bucket policies from Ansible; when to write a custom module (module boundaries, the `AnsibleModule` class, the idempotency contract)

\- Hours: \~4.5h

\- Lab + build: a playbook that creates a versioned, encrypted S3 bucket with a lifecycle policy; stub out one trivial custom module

\- Practice: `aws s3 ls`, `ansible-doc -M library/ my\_module`

\- Scenario: Automated backup-bucket provisioning with lifecycle rules instead of a manual console click-through

\- Interview angle: "When does a task list stop being 'good enough' and become a case for a custom module?"

\- Checklist: \[ ] pushed to GitHub \[ ] bucket has versioning + lifecycle policy applied



\#### Day 21 — Performance, Testing, Git Workflow — 🎯 Build: Multi-tier Application Deployment

\- Topics: forks, pipelining, fact caching, Molecule (still the standard testing tool in 2026 — Docker/Podman drivers; note `molecule lint` was removed a few versions back, run `ansible-lint` separately), Git branching for playbook repos

\- Hours: \~5h

\- Lab + build: app + database + load-balancer roles orchestrated together, with a Molecule test scenario on the app role — this also covers your "Database Deployment" project from the original list

\- Practice: `molecule init role app --driver-name docker`, `molecule test`, `ansible-lint roles/`

\- Scenario: A role that passes on your laptop but fails in CI — Molecule catches the environment assumption before it reaches production

\- Interview angle: "What does `molecule test` actually verify that a manual `ansible-playbook` run wouldn't catch?"

\- Checklist: \[ ] pushed to GitHub \[ ] Molecule scenario passes the idempotence check



\---



\### Phase 4 — DevOps Integration (Days 22–26)



\#### Day 22 — 🎯 Build: Docker + Ansible Deployment

\- Topics: `community.docker` collection, `docker\_container`/`docker\_image`/`docker\_compose\_v2` modules, templating a `docker-compose.yml` from Ansible vars

\- Hours: \~4h

\- Lab + build: a playbook that builds an image and deploys a containerized app via Ansible-managed Compose

\- Practice: `ansible-galaxy collection install community.docker`, `docker ps` as a post-deploy check

\- Scenario: Same deployment playbook, different image tag per environment

\- Interview angle: "Ansible + Docker vs Ansible replaced by Kubernetes — where's the line?"

\- Checklist: \[ ] pushed to GitHub \[ ] container survives a host reboot (restart policy set)



\#### Day 23 — 🎯 Build: Kubernetes Basics + Ansible Integration

\- Topics: K8s core objects (pod/deployment/service) — just enough to be dangerous, `kubernetes.core` collection, the `k8s` module, kubeconfig management from Ansible

\- Hours: \~4.5h (genuinely new material)

\- Lab + build: a playbook that applies a Deployment + Service manifest to a local cluster (minikube/k3s/kind) — covers both your Kubernetes Cluster and Kubernetes Application projects

\- Practice: `kubectl get pods`, `ansible-galaxy collection install kubernetes.core`

\- Scenario: Ansible as the glue that templates and applies K8s manifests per environment, rather than hand-editing YAML

\- Interview angle: "Where does Ansible's role end and Kubernetes' own reconciliation loop take over?"

\- Checklist: \[ ] pushed to GitHub \[ ] deployment reachable via port-forward or NodePort



\#### Day 24 — 🎯 Build: Terraform + Ansible Integration

\- Topics: division of labor (Terraform provisions, Ansible configures), Terraform's built-in Ansible provisioner vs the cleaner handoff pattern (Terraform outputs → generated inventory), Terraform state basics

\- Hours: \~4.5h

\- Lab + build: Terraform provisions an EC2 instance and outputs its IP; a small script feeds that straight into an Ansible run

\- Practice: `terraform apply -auto-approve`, `terraform output -json`, `ansible-playbook -i generated\_inventory.yml site.yml`

\- Scenario: Why teams keep these tools separate instead of using Terraform's built-in Ansible provisioner

\- Interview angle: "Terraform vs Ansible — where's the actual boundary, and why do most shops run both?"

\- Checklist: \[ ] pushed to GitHub \[ ] `terraform destroy` run cleanly after testing



\#### Day 25 — 🎯 Build: CI/CD — Jenkins + Ansible, GitOps

\- Topics: Jenkins pipeline basics (`Jenkinsfile`), triggering `ansible-playbook` from a pipeline stage, Vault password injection in CI, GitOps principles (git as source of truth, pull vs push)

\- Hours: \~4.5h

\- Lab + build: a `Jenkinsfile` that lints, then runs a playbook against a staging target on every push to `main`

\- Practice: `ansible-playbook site.yml --vault-password-file=$VAULT\_PW`, basic Jenkins pipeline syntax

\- Scenario: A bad playbook gets caught by CI lint before it ever touches a real host

\- Interview angle: "How do you keep the Vault password out of Jenkins job logs?"

\- Checklist: \[ ] pushed to GitHub \[ ] pipeline correctly fails on a deliberately broken playbook



\#### Day 26 — Monitoring, Logging, Security, Disaster Recovery

\- Topics: CloudWatch basics (metrics/alarms/logs) mapped conceptually against the Prometheus/Grafana stack you've already deployed; Ansible security practices (Vault, least-privilege `become`, `no\_log`); DR patterns (backup automation, playbook-driven rebuild)

\- Hours: \~4h

\- Lab: Add a CloudWatch alarm via Ansible for an EC2 instance; write a `no\_log: true` example for a task handling a secret

\- Practice: the CloudWatch alarm module, then grep your own playbooks for accidental secret leakage in output

\- Scenario: Your existing `SSHServiceDown`/`SSHPortUnreachable` blackbox\_exporter rules — same alerting philosophy, different platform

\- Interview angle: "A playbook task logs a password in plaintext to the console — what's wrong and how do you fix it?"

\- Checklist: \[ ] one CloudWatch alarm created via Ansible \[ ] `no\_log` applied correctly to a sensitive task



\---



\### Phase 5 — Enterprise, Capstone, Job-Ready (Days 27–30)



\#### Day 27 — AWX/AAP, Enterprise Folder Structure, Deployment Strategies

\- Topics: AWX vs Red Hat Ansible Automation Platform (AAP). \*\*Current state worth knowing for an interview:\*\* AWX (the open-source upstream) has had its development paused since mid-2024 for a large architectural refactor, so hands-on AWX tutorials are less reliable right now than most guides assume. Red Hat's actively maintained, supported path is AAP, with "Automation Controller" (renamed from "Tower" a while back) as its core component. Also: production folder structure (`group\_vars/`, `host\_vars/`, `roles/`, `inventories/<env>/`), blue-green and canary deployment strategies with Ansible

\- Hours: \~4h

\- Lab: Restructure everything you've built into a proper multi-environment layout (`inventories/staging`, `inventories/production`)

\- Practice: `ansible-playbook -i inventories/production site.yml --check`

\- Scenario: Why "one inventory file with a staging group" stops scaling past a certain team size

\- Interview angle: "AWX vs AAP vs plain ansible-playbook from CI — when does each make sense?"

\- Checklist: \[ ] repo reorganized into environment-based inventories \[ ] can explain AWX's current maintenance state if it comes up in an interview



\#### Day 28 — 🎯 Capstone, Day 1: Design

\- Topics: capstone kickoff — \*\*Full Enterprise Infrastructure Automation\*\*: VPC + EC2 + load balancer + Auto Scaling Group + multi-tier app (web/app/db) + monitoring, all Ansible-driven, Vault-protected secrets, role-based, environment-separated. This is your "Full Infrastructure Automation" and "Final Enterprise-Level" projects from the original list, combined.

\- Hours: \~4h — design + role/inventory skeleton, no application code yet

\- Lab: Architecture diagram (ASCII or draw.io), folder skeleton, inventory for the capstone environment

\- Practice: `ansible-galaxy role init` for each planned role, `tree` to sanity-check structure

\- Scenario: This is the project a recruiter or interviewer actually clicks into — treat the README like a design doc, not an afterthought

\- Interview angle: "Walk me through this architecture" — rehearse your own answer today, not on interview day

\- Checklist: \[ ] architecture diagram drafted \[ ] role skeleton created for every planned component



\#### Day 29 — 🎯 Capstone, Day 2: Build + Troubleshooting Deep Dive

\- Topics: implementation day — wire the roles together under a top-level playbook; dedicated troubleshooting/debugging session (`-vvv`, `ANSIBLE\_DEBUG`, `--step`, `--start-at-task`, common failure signatures)

\- Hours: \~4.5h

\- Lab: Full capstone run against real infrastructure, deliberately broken once mid-run to practice `--start-at-task` recovery

\- Practice: `ansible-playbook capstone.yml --step`, `ansible-playbook capstone.yml --start-at-task="Configure app"`, `ANSIBLE\_DEBUG=1 ansible-playbook capstone.yml`

\- Scenario: A task fails on host 14 of 20 — resume without re-running the first 13

\- Interview angle: "A playbook that worked yesterday fails today with no code changes — where do you look first?"

\- Checklist: \[ ] capstone runs end-to-end \[ ] recovered from an injected mid-run failure without a full restart



\#### Day 30 — 🎯 Capstone, Day 3: Wrap-Up + Portfolio + Resume + Mock Interview

\- Topics: capstone polish (README, architecture diagram, teardown script); GitHub portfolio structure across everything you've built; ATS-friendly resume bullet points drawn from what you actually built; LinkedIn headline/summary; interview-readiness checklist; job-application strategy

\- Hours: \~4.5h — no new coding, this is a writing and review day

\- Lab: Finalize the capstone README with the architecture diagram plus a "what I'd do differently at 10x scale" section — that line, more than the code itself, is what separates junior from mid-level in an interview

\- Scenario: A recruiter has 90 seconds on your GitHub profile — what has to be visible without a click

\- Interview angle: full mock interview, drawing from the accumulated question bank from Days 1–29, run live

\- Checklist: \[ ] every project has a README \[ ] resume draft complete \[ ] mock interview done



\---



\## What's next



Say \*\*"start Day 1"\*\* and we'll run the full lesson — concept, internals, common mistakes, production best practices, ASCII diagrams, hands-on lab, mini-project, troubleshooting, quiz, and interview questions, per your original structure. If you'd rather compress Days 1–4 into one fast-review session given your background, say that instead and I'll fold them together.



The running interview-question bank starts today — every day from here appends to it, organized by topic, so by Day 30 you have a complete, non-redundant set instead of 250 questions with no context behind them.



\*\*Optional certification target\*\*, once you're through this: AWS Certified Cloud Practitioner (broad, entry-level) or Red Hat's Ansible Automation specialist exam if you want the Ansible-specific credential on paper. Check the current exam guides before registering — formats get refreshed periodically.

