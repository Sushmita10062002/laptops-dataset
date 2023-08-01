-- Code for cleaning the laptops dataset.
USE laptops;
CREATE TABLE laptops LIKE laptopdata;

INSERT INTO laptops
SELECT * FROM laptopdata;

SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'laptops'
AND TABLE_NAME = 'laptops';

ALTER TABLE laptops DROP COLUMN `Unnamed: 0`;

ALTER TABLE laptops ADD COLUMN `index` INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- SELECT ROW_NUMBER() OVER () 
-- FROM laptops;

-- UPDATE laptops
-- SET `index` =(
--     SELECT ROW_NUMBER() OVER ()
--     FROM laptops
-- ) ;


SELECT * FROM laptops;

DELETE FROM laptops 
WHERE `index` IN (
SELECT `index` FROM laptops
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL 
AND ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL AND 
Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND WEIGHT IS NULL AND 
Price IS NULL
);


SELECT * FROM laptops; 
SELECT DISTINCT Company FROM laptops;
SELECT DISTINCT TypeName FROM laptops;

ALTER TABLE laptops MODIFY COLUMN Inches DECIMAL(10, 1);

UPDATE laptops l1
SET Ram = (SELECT REPLACE(Ram,'GB','') FROM laptops l2 WHERE l2.index = l1.index);


ALTER TABLE laptops MODIFY COLUMN Ram INTEGER;

UPDATE laptops l1
SET Weight = (SELECT REPLACE(Weight, 'kg', '') FROM laptops l2 WHERE l2.index = l1.index);

ALTER TABLE laptops MODIFY COLUMN Weight DECIMAL(10, 1);

-- changing the price column
UPDATE laptops l1
SET Price = (SELECT ROUND(Price,2) FROM laptops l2 WHERE l2.index = l1.index);

ALTER TABLE laptops MODIFY COLUMN Price INTEGER;

-- handling operating system
SELECT DISTINCT OpSys FROM laptops;

-- mac
-- windows
-- linux
-- no os
-- android chrome(others)

UPDATE laptops
SET OpSys = CASE 
    WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE '%windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

ALTER TABLE laptops
ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;

UPDATE laptops l1
SET gpu_brand = (SELECT SUBSTRING_INDEX(Gpu, ' ',1) FROM laptops l2 WHERE l2.index = l1.index);

UPDATE laptops l1
SET gpu_name = (SELECT REPLACE(Gpu,CONCAT(gpu_brand,' '),'') FROM laptops l2 WHERE l2.index = l1.index);

ALTER TABLE laptops DROP COLUMN Gpu;

-- handling cpu
ALTER TABLE laptops 
ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu, 
ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

UPDATE laptops l1
SET cpu_brand = (SELECT MAX(SUBSTRING_INDEX(Cpu, ' ',1))
                 FROM laptops l2 
                 WHERE l1.index = l2.index);

UPDATE laptops l1
SET cpu_speed = (SELECT MAX(CAST(REPLACE(SUBSTRING_INDEX(Cpu, ' ', -1), 'GHz','') AS DECIMAL(10,2)))
                 FROM laptops l2 
                 WHERE l1.index = l2.index);
                 
UPDATE laptops l1
SET cpu_name = (SELECT
				REPLACE(REPLACE(Cpu, cpu_brand, ''), 
                SUBSTRING_INDEX(REPLACE(Cpu, cpu_brand,''), ' ', -1),'') 
                FROM laptops l2
                WHERE l1.index = l2.index
                );
                
ALTER TABLE laptops DROP COLUMN Cpu;

SELECT * FROM laptops;

SELECT ScreenResolution, 
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', -1),'x',1),
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', -1),'x',-1)
FROM laptops;

ALTER TABLE laptops 
ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
ADD COLUMN resolution_height INTEGER AFTER resolution_width;

UPDATE laptops
SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', -1),'x',1),
resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution, ' ', -1),'x',-1);

ALTER TABLE laptops 
ADD COLUMN touchscreen INTEGER AFTER resolution_height;

UPDATE laptops 
SET touchscreen = ScreenResolution LIKE '%Touch%';

ALTER TABLE laptops
DROP COLUMN ScreenResolution;

SELECT * FROM laptops;

UPDATE laptops 
SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);

ALTER TABLE laptops
ADD COLUMN memory_type VARCHAR(255) AFTER memory, 
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;

UPDATE laptops 
SET memory_type = CASE 
    WHEN Memory LIKE '%SSD%' AND '%HDD%' THEN 'Hybrid'
    WHEN Memory LIKE '%SSD%' THEN 'SSD'
    WHEN Memory LIKE '%HDD%' THEN 'HDD'
    WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage' 
    WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
    WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
    ELSE NULL
END;

SELECT * FROM laptops;

UPDATE laptops 
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory, '+',1), '[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(Memory, '+',1), '[0-9]+') ELSE 0 END;

SELECT * FROM laptops;

UPDATE laptops
SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE primary_storage END,
secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024 ELSE secondary_storage END;

ALTER TABLE laptops DROP COLUMN Memory;

ALTER TABLE laptops DROP COLUMN gpu_name;

SELECT * FROM laptops;




