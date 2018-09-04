### group vars / tasks
Automatically imports vault and variables files

### group tasks
Checks for and runs custom tasks for each group, by dynamically include a task list based on group names.

e.g. group_names == 'web,prod' will look for and run `web.yml` and `prod.yml` in the same directory as the playbook

