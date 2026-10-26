# Projects API

**Status:** Approved

## Resources

`/api/v1/projects`

## Operations

-   list authorized projects;
-   create project;
-   get project;
-   update authorized mutable fields;
-   archive project;
-   manage assignments through governed endpoint;
-   retrieve project control summary.

## Related

`/projects/{projectId}/milestones` `/projects/{projectId}/deliverables`
`/projects/{projectId}/risks` `/projects/{projectId}/issues`
`/projects/{projectId}/actions` `/projects/{projectId}/decisions`

## Security

Project access is scope-aware. Portfolio visibility does not
automatically grant edit permission.
