Hooks provide a mechanism for implementing cross-cutting concerns against multiple ansible repositories / playbooks / roles.

!!! tip
    Hooks are analogous to [JUnit's](https://junit.org/junit5/docs/current/user-guide/#writing-tests-classes-and-methods) `@Before`,`@After`..  and [Jasmine's](https://jasmine.github.io/api/3.2/global.html#afterAll) `beforeEach()`,`afterAll()`



### Hook Lifecycle

* before once hooks
* before each hooks
* group vaults
* ⇨ **execute** ⇦
* after each hooks
* after once hooks

Assuming group_names: all, web

* before.all.once.yml (`run_once: true`)
* before.web.once.yml (`run_once: true`)
* before.all.yml
* before.web.yml
* vault/all
* vault/web
* ⇨ **execute** ⇦
* after.all.yml
* after.web.yml
* after.web.once.yml (`run_once: true`)
* after.all.once.yml (`run_once: true`)


#### Before
Before hooks are useful enhancing or transforming the inventory model, e.g inject new containers into `containers` or updating `docker_registry` with temporary credentials.

`before.all.once.yml` vs `before.all.yml`


#### After
After hooks run after everything else and allows for the full use of ansible.


### Hook Types

#### Tasks
Task hooks are imported using `include:` and just run the tasks listed in the yml file.

#### Vaults
Similar to vaulted files and variables included inside an inventory, Hook vaults are only imported on-demand, i.e. if you exclude tasks via `--tags`  or hosts via `--limit` then a vault password is required. This allows running a subset of a playbook without access to the vault.

### Hook Location

Hook files can placed inside the working directory and/or from any location specified by the `hooks` list.
