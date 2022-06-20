--Exercices

--Afficher le nom scientifique, le nom commun et la famille de toutes les espèces

SELECT scientific_name as "nom scientifique", 
    common_name as "nom commun", 
    family.name as "famille" 
FROM "species"
JOIN "family"
    ON "species".family_id = family.id;


-- afficher maintenant les espèces pour lesquelles il existe au moins une variété ayant une armertume de 5 (sur 5, autant dire que ça ne sert qu'à faire du vinaigre)
-- sans doublons (avec un DISTINCT)

SELECT DISTINCT common_name as "espèces amères"
FROM "species"
JOIN "variety"
    ON species.id = variety.species_id
WHERE variety.bitterness = 5;


-- afficher le nom de la plantation et le libellé des rangées concernées (une ligne par rangée)

SELECT "name" AS "plantation",
    "label" AS "libellé"
    FROM "field"
INNER JOIN "row"
    ON row.field_id = field.id;

--Ici juste une requête pour classer en fonction des rangées
SELECT "name" as "Plantation", "row".label
FROM "field"
JOIN "row"
ON field.id = row.field_id
GROUP BY "field".name, "row".label
ORDER BY LENGTH("label"), "label";



-- afficher le nom de la plantation et le libellé des rangées concernées par l'amertume de 5 (une ligne par rangée)

SELECT field.name, row.label FROM row
JOIN field ON field.id = row.field_id
JOIN variety ON variety.id = row.variety_id
WHERE variety.bitterness = 5;

-- la requête précédente retourne trop de ligne, utiliser la fonction ARRAY_AGG pour regrouper les valeurs dans un tableau
-- regrouper par plantation

    
SELECT 
    field.name AS "Domaines", 
    ARRAY_AGG(row.label ORDER BY LENGTH("label"), "label") AS "Rangées", 
    ARRAY_AGG(DISTINCT "variety".cultivar ) AS"Variétés amères"
FROM row
JOIN field
ON row.field_id = field.id
JOIN "variety"
    ON variety.id = row.variety_id
WHERE "bitterness" = 5
GROUP BY "Domaines"
ORDER BY "Domaines" DESC;


-- Les clients de l'orangeraie ont tendance à dire que leurs clémentines ne sont pas juteuses :angry: Mais qu'est-ce qu'ils en savent, hein, d'abord ? Bon, on devrait bien pouvoir écrire une requête pour déterminer une bonne fois pour toute quelles familles ne contiennent aucune espèce ayant une jutosité moyenne supérieure à la moyenne (2.5, vu qu'on les note de 0 à 5).


SELECT "name" AS "Familles d''agrumes juteuses", ARRAY_AGG(variety.juiciness ORDER BY juiciness)AS "Jutosité"
FROM "family"
JOIN "species"
    ON species.family_id = family.id
JOIN "variety"
    ON variety.species_id = species.id
WHERE "juiciness" > 2.5
GROUP BY "name"
ORDER BY "name";


-- Demande urgente d'un gestionnaire : il lui faudrait la liste des plantations qui produisent de la mandarine, peu importe l'espèce. Même si ce n'est que sur un rang dans une petite plantation isolée, il faut qu'elle y figure.

SELECT "field".name AS "Plantations" FROM "field"
WHERE "field".id IN (
    SELECT "row".field_id FROM row
    WHERE "row".variety_id IN (
        SELECT "variety".id FROM "variety"
        WHERE species_id IN (
            SELECT "species".id FROM "species"
            WHERE family_id IN (
                SELECT "family".id FROM "family"
                WHERE "family".name = 'mandarine'
))));

-- Requête demandée

-- En parlant de lisibilité, je vous propose de réécrire la requête des plantations de mandarine avec des jointures. 
SELECT DISTINCT
    field.name AS "Plantation", 
    ARRAY_AGG(DISTINCT S.common_name) AS "Espèce produisant de la mandarine"
FROM "field"
JOIN "row"
    ON row.field_id = field.id
JOIN "variety"
    ON row.variety_id = variety.id
JOIN "species" AS S
    ON S.id = variety.species_id
JOIN "family"
    ON family.id = S.family_id
WHERE family.name = 'mandarine'
GROUP BY field.name;

-- INFORMATION : Tentative de faire la première requête à sous-requêtes avec des JOIN => impossible
