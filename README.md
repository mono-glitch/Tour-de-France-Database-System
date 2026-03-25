# **<ins>2025 Tour de France Database System</ins>**

# Summary

  - Constructed a normalized relational schema using PostgreSQL from raw CSV data, enforcing constraints to eliminate insertion anomalies and ensure data integrity across 3,500+ race records
  - Designed an Entity-Relationship diagram to visualize complex schema architecture and dependencies
  - Wrote stored procedures and triggers to enforce advanced constraints (e.g. post-withdrawal participation bans), automating data validation for future multi-statement transactions

# Project Details
## 0. Tour de France Requirements ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Database%20Requirements%20(Tour%20de%20France).pdf))

  - This document outlines the requirements for designing a database to analyze the 2025 Tour de France.
  - It details the entities involved—teams, riders, countries, stages, locations, and race results—along with their attributes and relationships, such as team composition, stage classifications, and individual rider performance.
  - The database must enforce specific business rules, including constraints for rider exits, rest days, and result rankings.
  - The goal is to transform raw CSV data into a structured, queryable system to evaluate team performance, starting with a minimum viable product (MVP) that demonstrates the advantages of a database over flat files, followed by full schema design and constraint enforcement via triggers & stored procedures.
  
## 1. Building Tables & Inserting Data

### Task ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Q1%20-%20Building%20Tables%20%26%20Inserting%20Data.pdf))

  - This task focuses on creating a MVP to demonstrate the advantages of a database over raw CSV files.
  - It involves designing initial tables, inserting data from the provided [tdF-2025.csv](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/tdF-2025.csv) and [tdF-exits.csv](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/tdF-exits.csv) files, and establishing a foundation for later enhancements.
  - The goal is to show how structured database storage improves data management and querying compared to flat-file formats.

### Answer

  a. **Database Schema** ([A1 - Building Tables.sql](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/A1%20-%20Building%20Tables.sql))
  
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

  b. **Data Processing** ([A1 - CSV Processor.py](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/A1%20-%20CSV%20Processor.py))
  
    A Python script processes the raw CSV data (tdf-2025.csv) and generates SQL insert statements. The script:
    
    - Extracts unique countries, teams, riders, and locations from Stage 1 data
    - Handles missing rider country data (inserts NULL where applicable)
    - Generates properly escaped SQL strings with PostgreSQL-compatible syntax

  c. **Data Insertion** ([A1 - Inserting Data.sql](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/A1%20-%20Inserting%20Data.sql))
  
    This SQL file contains INSERT statements for all data in the csv files generated using "A1 - CSV Processor.py".

  ### Summary
  
  - This MVP successfully demonstrates the transition from flat CSV files to a normalized, queryable relational database with proper constraints and referential integrity.
  - The structured approach enables efficient data retrieval, ensures data consistency, and provides a solid foundation for more complex analytical queries in subsequent phases.

## 2. Designing ERD & Enforcing Constraints

  ### Task ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Q2%20-%20Designing%20ERD%20%26%20Enforcing%20Constraints.pdf))
  
  - This phase requires constructing a detailed Entity-Relationship diagram based on the Tour de France specification, capturing all entities, relationships, cardinalities, and participation constraints.
  - The ER diagram is then mapped to a relational schema with proper use of primary keys, foreign keys, and check constraints.

  ### Answer
  
  a. **Entity-Relationship Diagram** ([A2 - Entity-Relationship Diagram.pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/87849db5e043f431405c4cd3ae311b8ea3b3b87a/A2%20-%20Entity-Relationship%20Diagram.pdf))

    The ER diagram captures the core entities and their relationships according to the specification:
    
    <ins>Entities and Attributes</ins>
    
    | Entity | Attributes |
    |--------|------------|
    | `Country` | code (PK), name, region |
    | `Team` | name (PK), country_code (FK) |
    | `Rider` | bib (PK), name, date_of_birth, team_name (FK), country_code (FK) |
    | `Location` | name (PK), country_code (FK) |
    | `Stage` | id (PK), day, origin (FK), destination (FK), length, type |
    | `Result` | stage (FK), rider (FK), rank, finish_time, time_bonus, time_penalty |
    | `Exit` | rider (PK), stage (FK), reason (FK) |
    | `Exit_Reason` | reason (PK) |
    
    <ins>Relationships and Cardinalities</ins>
    
    - **Country – Team**: One-to-many (a country can have many teams; a team belongs to exactly one country)
    - **Country – Rider**: One-to-many optional (a country can have many riders; a rider belongs to at most one country)
    - **Team – Rider**: One-to-many (a team has many riders; a rider belongs to exactly one team)
    - **Country – Location**: One-to-many (a country has many locations; a location belongs to exactly one country)
    - **Location – Stage**: One-to-many (a location can be origin/destination for many stages)
    - **Stage – Result**: One-to-many (a stage has many results; a result belongs to exactly one stage)
    - **Rider – Result**: One-to-many (a rider has many results; a result belongs to exactly one rider)
    - **Rider – Exit**: One-to-one optional (a rider may exit at most once)
    - **Exit – Exit_Reason**: Many-to-one (many exits can share a reason)
  
  b. **Relational Schema** ([A2 - Relational Schema.sql](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/87849db5e043f431405c4cd3ae311b8ea3b3b87a/A2%20-%20Relational%20Schema.sql))
  
    The ER diagram is mapped to a relational schema with the following enhancements over "A1 - Building Tables.sql":
    
    | Change | Description |
    |--------|-------------|
    | Table renaming | `stage_result` → `result`, `rider_exit` → `exit` |
    | Column renaming | `stage.stage_number` → `stage.id`, `stage.start_location` → `stage.origin`, `stage.finish_location` → `stage.destination` |
    | Data type updates | `VARCHAR(64)` for string fields, `INTEGER` for numeric fields |
    | Constraint additions | `CHECK (stage.id >= 1)`, `CHECK (finish_time > 0)` |

  ### Summary
  
  - Modelling through ER diagrams with proper cardinalities
  - Logical design through relational schema with constraints

## 3. Triggers & Stored Procedures

  ### Task ([pdf](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/adbc6b0eec0fa2ab7c97b8a875139c8ea75e4e05/Q3%20-%20Triggers%20%26%20Stored%20Procedures.pdf))
  
  - This task enforces complex rules that cannot be handled by standard integrity constraints alone.
  - Five triggers are implemented to ensure: consecutive rank numbering, rank consistency with race times, elimination of riders after exit, no consecutive rest days, and a maximum of two rest days per competition.
  - Triggers must maintain consistency across transactions, and test cases are also required to verify both acceptance and rejection of operations.

  ### Answer
  
  a. **Trigger & Stored Procedures** ([A3 - Triggers & Stored Procedures.sql](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/4b025692443fa22cbb79444a60b625aeacc663e9/A3%20-%20Triggers%20%26%20Stored%20Procedures.sql))

    <ins>Constraints & Implementation</ins>
    
    | Constraint | Rule | Implementation |
    |------------|------|----------------|
    | Rank Gaps | Ranks for each stage must be consecutive starting from 1, with no gaps | check_rank_gaps_func() validates that MIN(rank) = 1 and MAX(rank) = COUNT(*) per stage |
    | Rank-Time Consistency | A rider with a better rank must have a race time less than or equal to riders with worse ranks | check_rank_time_func() checks for any violation where a lower rank has a longer time |
    | Rider Exit Enforcement | A rider who exits at stage S cannot have results in stage S or any later stages | check_rider_exit_func() verifies no results exist at or after exit stage |
    | No Consecutive Rest Days | Gaps between stage days cannot exceed 2 days | check_rest_days_func() calculates max gap between consecutive stage days |
    | Maximum Two Rest Days | Total rest days in the competition cannot exceed 2 | check_rest_days_func() calculates rest days as (total days - stages + 1) |
    
    <ins>Trigger Characteristics</ins>
    
    | Feature | Implementation |
    |---------|----------------|
    | Deferrability | All triggers use DEFERRABLE INITIALLY DEFERRED to allow multi-statement transactions to reach a consistent final state |
    | Transaction Validity | Triggers validate the entire transaction; if inconsistency is detected, the entire transaction is rolled back |

  b. **Test Cases** ([A3 - Building Own Test Cases.sql](https://github.com/mono-glitch/Tour-de-France-Database-System/blob/4b025692443fa22cbb79444a60b625aeacc663e9/A3%20-%20Buidling%20Own%20Test%20Cases.sql))
  
    This test file validates each constraint with both successful and failing scenarios:
    
    | Constraint | Success Cases | Failure Cases |
    |------------|---------------|---------------|
    | Rank Gaps & Rank-Time | Valid ranks (1,2,3) with correct times | - Rank gap (1,3) <br> - Missing rank 1 <br> - Better rank with longer time |
    | Rider Exit | Exit recorded after results | - Result after exit stage <br> - Result at exit stage |
    | Rest Days | Single rest day gap | - Gap > 2 days (multiple rest days) <br> - More than 2 rest days total |
  
  ### Summary
  
  - Five advanced constraints enforced through triggers that maintain data integrity beyond standard SQL constraints
  - Deferrable triggers ensure transactional consistency across multi-statement operations
  - Test cases coverage validates both acceptance and rejection scenarios for each constraint
