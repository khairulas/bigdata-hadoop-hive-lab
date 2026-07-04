-- init-hive-db.sql
-- Runs automatically when the postgres container first initialises (empty volume only).
-- Creates the hive role and both databases required by the lab stack.
-- All statements are idempotent (safe to re-run if the file is amended).

-- ── 1. Create the hive role (skip if it already exists) ──────────────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'hive') THEN
    CREATE USER hive WITH PASSWORD 'hive_lab_2024';
  END IF;
END
$$;

-- ── 2. Create the metastore database (Hive schematool populates the schema) ──
SELECT 'CREATE DATABASE metastore OWNER hive'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'metastore')\gexec

-- ── 3. Create the hue database (Hue migrate populates the schema) ────────────
SELECT 'CREATE DATABASE hue OWNER hive'
  WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'hue')\gexec

-- ── 4. Grant full privileges ──────────────────────────────────────────────────
GRANT ALL PRIVILEGES ON DATABASE metastore TO hive;
GRANT ALL PRIVILEGES ON DATABASE hue TO hive;