\echo 'Creating schema'
\i schema.sql

\echo 'Creating indexes'
\i indexes.sql

\echo 'Creating views'
\i views.sql

\echo 'Seeding data'
\i seed.sql
