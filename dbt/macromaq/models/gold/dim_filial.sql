WITH LANCAMENTOS AS (
    SELECT DISTINCT
        "SK_FIL",
        "CODEMP",
        "CODFIL"
    FROM {{ ref('lancamentos') }}
    WHERE "CODFIL" IS NOT NULL
),
FILIAIS AS (
    SELECT DISTINCT
        FIL."CODEMP",
        EMP."NOMEMP",
        EMP."SIGEMP",
        FIL."CODFIL",
        FIL."NOMFIL",
        FIL."SIGFIL",
        FIL."INSEST",
        FIL."NUMCGC",
        FIL."ENDFIL",
        FIL."CPLEND",
        FIL."CEPFIL",
        FIL."BAIFIL",
        FIL."CIDFIL"
    FROM {{ source('bronze', 'E070FIL') }} FIL
    LEFT JOIN {{ source('bronze', 'E070EMP') }} EMP
        ON FIL."CODEMP" = EMP."CODEMP"
    WHERE "CODFIL" IS NOT NULL
)

SELECT DISTINCT
    LCT."SK_FIL",
    FIL."CODEMP",
    FIL."NOMEMP",
    FIL."SIGEMP",
    FIL."CODFIL",
    FIL."NOMFIL",
    FIL."SIGFIL",
    FIL."INSEST",
    FIL."NUMCGC",
    FIL."ENDFIL",
    FIL."CPLEND",
    FIL."CEPFIL",
    FIL."BAIFIL",
    FIL."CIDFIL"
FROM FILIAIS FIL
LEFT JOIN LANCAMENTOS LCT
    ON FIL."CODEMP" = LCT."CODEMP"
    AND FIL."CODFIL" = LCT."CODFIL"
WHERE LCT."SK_FIL" IS NOT NULL