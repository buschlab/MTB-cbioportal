# Upgrade Guide

This guide explains how to upgrade MTB-cBioPortal from a previous release to a newer one.

---

## Before You Start

> **Upgrading requires purging all Docker volumes.** This is necessary because the database server and the cBioPortal seed database are typically updated between releases.
>
> **Any data not backed up will be permanently lost.**

Here is what you need to know before upgrading:

- **Study data** (loaded from disk) will survive, you can reimport it after the upgrade.
- **The HAPI FHIR database** must be backed up manually, it does not live on disk and will be lost if you skip the backup step.
- The rest of the volume data can be safely discarded, as it will be regenerated on first start.

---

## Upgrade Steps

### Step 1 — Back up the HAPI FHIR database

```bash
docker compose exec hapi-postgres pg_dumpall -U hapiserver > dump.sql
sed '/\connect hapi/,$!d' dump.sql > dump_hapi.sql
```

Open `dump_hapi.sql` and verify it looks correct (it should start with SQL statements for the `hapi` database) before continuing.

### Step 2 — Move your data to a safe location

Move the backup files, study data, and your configuration files out of the MTB-cBioPortal directory:

```bash
mv dump.sql dump_hapi.sql reports/ study/ .env config/ /path/to/safe/location/
```

> `config/` contains the Keycloak certificate (`keycloak.pem`) and other custom settings. `.env` holds all your environment variables including database passwords. Both will be lost with the directory if you skip this.

### Step 3 — Tear down the current installation

```bash
docker compose down -v
```

> This permanently deletes all Docker volumes. There is no undo, make sure your backup from Step 1 is intact before running this.

### Step 4 — Fresh clone of the repository

```bash
cd ..
rm -rf MTB-cbioportal/
git clone https://github.com/pm4onco/MTB-cbioportal.git
cd MTB-cbioportal
```

### Step 5 — Restore the HAPI FHIR database

Copy the backup files back into the new directory, then start the database and restore:

```bash
cp /path/to/safe/location/dump.sql .
cp /path/to/safe/location/dump_hapi.sql .

docker compose up -d hapi-postgres
docker compose exec -T hapi-postgres psql -U hapiserver -d hapi < dump_hapi.sql
```

### Step 6 — Complete the setup

Start by restoring your configuration and data:

```bash
cp /path/to/safe/location/.env .
cp -r /path/to/safe/location/config/ .
cp -r /path/to/safe/location/study/ .
cp -r /path/to/safe/location/reports/ .
```

Then continue from **Step 3 (Initialize configuration files)** in the [Installation Guide](./INSTALL.md) — your `.env` is already in place, so you can skip Step 2.

Reimport your studies once the stack is running, as described in the [Installation Guide](./INSTALL.md#import-test-data).

---

## What Gets Reset

| Data | Survives upgrade? | Notes |
|---|---|---|
| Study data (files on disk) | ✅ Yes | Reimport after upgrade |
| HAPI FHIR database | ⚠️ Only if backed up | Follow Step 1 carefully |
| cBioPortal session data | ❌ No | Regenerated on first login |
| cBioPortal database | ❌ No | Reseeded automatically on start |
| `.env` and `config/` | ⚠️ Only if backed up | Included in Step 2 backup |

---

## Troubleshooting

If something goes wrong after the upgrade, check the container logs:

```bash
docker compose logs cbioportal
docker compose logs hapi-postgres
```