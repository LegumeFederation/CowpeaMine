--
-- swap gene identifiers and clean up primary identifiers
--
-- RUN ONCE!!!
-- ENABLE TRIGGERS FIRST!!!
--

-- chado uniquename | name
--------------------------------
-- vigun.IT97K-499-35.gnm1.ann1.VigunL000100 | vigun.VigunL000100
-- Phvul.004G153400.v1.0       |
-- Glyma.20G120900.Wm82.a2.v1  |
-- Medtr7g117900.JCVIMt4.0v1   |
-- cicar.ICC4958.v2.0.Ca_12187 |
-- Ca_13038_gene               |
-- Aradu.Y681G                 |
-- Araip.SUM3W                 |

-- cowpea

UPDATE gene SET secondaryidentifier=primaryidentifier, primaryidentifier=substring(secondaryidentifier,7) WHERE primaryidentifier LIKE 'vigun.%';

UPDATE chromosome SET secondaryidentifier=primaryidentifier, primaryidentifier=substring(secondaryidentifier,7) WHERE primaryidentifier LIKE 'vigun.%';
UPDATE supercontig SET secondaryidentifier=primaryidentifier, primaryidentifier=substring(secondaryidentifier,7) WHERE primaryidentifier LIKE 'vigun.%';

UPDATE exon SET primaryidentifier=substring(primaryidentifier,30) WHERE primaryidentifier LIKE 'vigun.%';
UPDATE mrna SET primaryidentifier=substring(primaryidentifier,30) WHERE primaryidentifier LIKE 'vigun.%';
UPDATE transcript SET primaryidentifier=substring(primaryidentifier,30) WHERE primaryidentifier LIKE 'vigun.%';

-- common bean
UPDATE gene SET secondaryidentifier=primaryidentifier, primaryidentifier=replace(primaryidentifier, '.v1.0','') WHERE primaryidentifier LIKE 'Phvul.%';

-- soybean
UPDATE gene SET secondaryidentifier=primaryidentifier, primaryidentifier=replace(primaryidentifier, '.Wm82.a2.v1','') WHERE primaryidentifier LIKE 'Glyma.%';

-- medicago
UPDATE gene SET secondaryidentifier=primaryidentifier, primaryidentifier=replace(primaryidentifier, '.JCVIMt4.0v1','') WHERE primaryidentifier LIKE 'Medtr%';

-- chickpea desi
UPDATE gene SET secondaryidentifier=primaryidentifier, primaryidentifier=replace(primaryidentifier, 'cicar.ICC4958.v2.0.','') WHERE primaryidentifier LIKE 'cicar.%';

-- chickpea kabuli
-- NO CHANGE

-- A. duranensis
-- NO CHANGE

-- A. ipaensis
-- NO CHANGE

