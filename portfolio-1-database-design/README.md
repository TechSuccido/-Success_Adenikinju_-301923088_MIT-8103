# Portfolio 1: Database Design and Modelling

Case study: **ShopSphere** (see `case-study.md`).

| File | Purpose |
|---|---|
| `case-study.md` | Organisation statement |
| `er-diagram.mmd` | ER diagram (Mermaid; render at mermaid.live or in GitHub) |
| `normalisation.md` | UNF to 3NF explanation |
| `schema.sql` | DDL with keys and constraints |
| `seed_sample.sql` | Small sample data |
| `test_constraints.sql` | Statements that must fail, proving constraints work |

## How to run
```bash
docker compose up -d                       # from the repo root; loads schema + sample data
docker exec -it shopsphere-pg psql -U shop -d shopsphere
docker exec -i shopsphere-pg psql -U shop -d shopsphere < portfolio-1-database-design/test_constraints.sql
```

## Evidence to capture (screenshots into `evidence/`)
1. `\dt` and `\d orders` output
2. The rendered ER diagram
3. Output of `test_constraints.sql` showing the nine errors

## Testing note
Schema, seed data and constraint tests were run against PostgreSQL 16; all objects created and all nine constraint tests failed as expected.
