# 2025 Tour de France Database System

## Summary
- Constructed a normalized relational schema using PostgreSQL from raw CSV data, enforcing constraints to eliminate insertion anomalies and ensure data integrity across 3,500+ race records
- Designed an Entity-Relationship diagram to visualize complex schema architecture and dependencies
- Wrote stored procedures and triggers to enforce advanced constraints (e.g. post-withdrawal participation bans), automating data validation for future multi-statement transactions

## Project Details
0. Tour de France Requirements ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Database%20Requirements%20(Tour%20de%20France).pdf))
  - This document outlines the requirements for designing a database to analyze the 2025 Tour de France.
  - It details the entities involved—teams, riders, countries, stages, locations, and race results—along with their attributes and relationships, such as team composition, stage classifications, and individual rider performance.
  - The database must enforce specific business rules, including constraints for rider exits, rest days, and result rankings.
  - The goal is to transform raw CSV data into a structured, queryable system to evaluate team performance, starting with a minimum viable product (MVP) that demonstrates the advantages of a database over flat files, followed by full schema design and constraint enforcement via triggers & stored procedures.
  
1. Building Tables & Inserting Data
Task ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Q1%20-%20Building%20Tables%20%26%20Inserting%20Data.pdf)):
    - This task focuses on creating a MVP to demonstrate the advantages of a database over raw CSV files.
    - It involves designing initial tables, inserting data from the provided [tdF-2025.csv](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/tdF-2025.csv) and [tdF-exits.csv](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/tdF-exits.csv) files, and establishing a foundation for later enhancements.
    - The goal is to show how structured database storage improves data management and querying compared to flat-file formats.

Answer:
  a. Database Schema ([A1 - Building Tables.sql](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/A1%20-%20Building%20Tables.sql))
  The schema consists of eight tables that capture all core entities:
  | Table | Purpose |
  |-------|---------|
  | `country` | Stores countries with IOC code as primary key, name, and region |
  | `team` | Stores cycling teams with name and reference to country |
  | `rider` | Stores riders with bib number as primary key, name, DOB, team affiliation, and optional country |
  | `location` | Stores stage start/finish locations with country reference |
  | `stage` | Stores race stages with date, locations, length (km), and type (flat/hilly/mountain/individual time-trial/team time-trial) |
  | `stage_result` | Stores per-rider stage results: rank, time, bonuses, penalties |
  | `exit_reason` | Lookup table for valid exit reasons |
  | `rider_exit` | Records riders who exited the race, including stage and reason |
  
  Key Constraints Implemented:  
    - Primary and foreign keys for referential integrity
    - `UNIQUE (stage, rank)` ensures no duplicate ranks per stage
    - `CHECK` constraints for stage types, positive lengths, non-negative times/bonuses/penalties
    - Cascading updates for referential integrity

  b. Data Processing ([A1 - CSV Processor.py](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/A1%20-%20CSV%20Processor.py))
  A Python script processes the raw CSV data (tdf-2025.csv) and generates SQL insert statements. The script:
    - Extracts unique countries, teams, riders, and locations from Stage 1 data
    - Handles missing rider country data (inserts NULL where applicable)
    - Generates properly escaped SQL strings with PostgreSQL-compatible syntax

  c. Data Insertion ([A1 - Inserting Data.sql](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/A1%20-%20Inserting%20Data.sql))
  This SQL file contains INSERT statements for all data in the csv files generated using "A1 - CSV Processor.py".


2. Designing ERD & Enforcing Constraints
  a. Question ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Q2%20-%20Designing%20ERD%20%26%20Enforcing%20Constraints.pdf))
    - This phase requires constructing a detailed Entity-Relationship diagram based on the Tour de France specification, capturing all entities, relationships, cardinalities, and participation constraints.
    - The ER diagram is then mapped to a relational schema with proper use of primary keys, foreign keys, and check constraints.

3. Triggers & Stored Procedures
   a. Question ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Q3%20-%20Triggers%20%26%20Stored%20Procedures.pdf))
    - This task enforces complex rules that cannot be handled by standard integrity constraints alone.
    - Five triggers are implemented to ensure: consecutive rank numbering, rank consistency with race times, elimination of riders after exit, no consecutive rest days, and a maximum of two rest days per competition.
    - Triggers must maintain consistency across transactions, and test cases are also required to verify both acceptance and rejection of operations.
