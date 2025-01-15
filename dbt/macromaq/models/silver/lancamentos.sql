WITH E640LCT_TREATED AS 
    (
        SELECT
            CAST(LCT."CODEMP" AS INTEGER) AS "CODEMP",
            LCT."CODFIL",
            LCT."NUMLCT",
            CAST(LCT."DATLCT" AS DATE) AS "DATLCT",
            CAST(LCT."DATENT" AS DATE) AS "DATENT",
            MAKE_TIME(CAST(LCT."HORENT" / 60 AS INTEGER), CAST(LCT."HORENT" % 60 AS INTEGER), 0) AS "HORENT",
            LCT."TIPLCT",
            LCT."ORILCT",
            UPPER(LOT."DESLOT") AS "DESLOT",
            LOT."SITLOT",
            LCT."CODHPD",
            UPPER(HPD."DESHPD") AS "DESHPD",
            UPPER(LCT."CPLLCT") AS "CPLLCT",
            LCT."NUMLOT",
            CASE 
                WHEN LCT."TEMRAT" = 0 THEN FALSE
                WHEN LCT."TEMRAT" = 1 THEN TRUE
            END AS "TEMRAT",
            CASE 
                WHEN LCT."TEMAUX" = 0 THEN FALSE
                WHEN LCT."TEMAUX" = 1 THEN TRUE
            END AS "TEMAUX",
            LCT."DOCLCT",
            LCT."CGCCPF",
            LCT."SITLCT",
            LCT."CODUSU",
            LCT."OBSCPL",
            LCT."NUMFTC",
            LCT."CGCCRE",
            LCT."INDLCT",
            LCT."ECDLCT",
            LCT."CTADEB",
            LCT."CTACRE",
            LCT."VLRLCT",
            CAST(LCT."DATEXT" AS DATE) AS "DATEXT",
            LCT."IDEGED"
        FROM {{ source('bronze', 'E640LCT') }} LCT
        LEFT JOIN {{ source('bronze', 'E640LOT') }} LOT
        ON LCT."CODEMP" = LOT."CODEMP"
        AND LCT."NUMLOT" = LOT."NUMLOT"
        LEFT JOIN {{ source('bronze', 'E046HPD') }} HPD
        ON LCT."CODHPD" = HPD."CODHPD"
    ),

E640RAT_TREATED AS 
    (
        SELECT
            CAST(RAT."CODEMP" AS INTEGER) AS "CODEMP",
            RAT."NUMLCT",
            -- CENTRO DE CUSTO
            CAST(RAT."CODCCU" AS INTEGER) AS "CODCCU",
            UPPER(CCU."DESCCU") AS "DESCCU",
            UPPER(CCU."ABRCCU") AS "ABRCCU",
            CCU."TIPCCU",
            CCU."MSKCCU",
            CCU."CCUPAI",
            CCU."GRUCCU",
            CCU."NIVCCU",
            CCU."POSCCU",
            CCU."ANASIN",
            -- CONTA DE REDUCAO
            CAST(RAT."CTARED" AS NUMERIC) AS "CTARED",
            UPPER(PLA."DESCTA") AS "DESCTA",
            UPPER(PLA."ABRCTA") AS "ABRCTA",
            PLA."CLACTA",
            -- DATAS E VALORES DOS LANCAMENTOS
            CAST(RAT."DATLCT" AS DATE) AS "DATLCT",
            RAT."FILRAT",
            RAT."PERRAT",
            CASE 
                WHEN RAT."DEBCRE" = 'C' THEN RAT."VLRRAT"
                WHEN RAT."DEBCRE" = 'D' THEN -RAT."VLRRAT"
            END AS "VLRRAT",
            RAT."SITRAT",
            CASE 
                WHEN RAT."DEBCRE" = 'D' THEN 'DÉBITO'
                WHEN RAT."DEBCRE" = 'C' THEN 'CRÉDITO'
            END AS "DEBCRE",
            RAT."CTAFIN",
            RAT."NUMFTC"
        FROM {{ source('bronze', 'E640RAT') }} RAT
        LEFT JOIN {{ source('bronze', 'E044CCU') }} CCU
            ON RAT."CODEMP" = CCU."CODEMP"
            AND RAT."CODCCU" = CCU."CODCCU"
        LEFT JOIN {{ source('bronze', 'E045PLA') }} PLA
            ON CAST(RAT."CODEMP" AS INTEGER) = CAST(PLA."CODEMP" AS INTEGER)
            AND CAST(RAT."CTARED" AS NUMERIC) = CAST(PLA."CTARED" AS NUMERIC)
    )

SELECT 
    DENSE_RANK() OVER (
                        ORDER BY E640LCT."CODEMP", 
                                 E640LCT."CODFIL",
                                 E640LCT."NUMLCT", 
                                 E640LCT."DATLCT"
    ) AS "SK_LCT",
    DENSE_RANK() OVER (
                        ORDER BY E640LCT."CODEMP",
                                 E640RAT."CODCCU"
    ) AS "SK_CCU",
    DENSE_RANK() OVER (
                        ORDER BY E640LCT."CODEMP",
                                 E640RAT."CTARED"
    ) AS "SK_CTA",
    DENSE_RANK() OVER (
                        ORDER BY E640RAT."FILRAT",
                                 E640RAT."SITRAT",
                                 E640LCT."TEMRAT"
    ) AS "SK_RAT",
    DENSE_RANK() OVER (
                        ORDER BY E640LCT."CODEMP",
                                 E640LCT."CODFIL"
    ) AS "SK_FIL",
    DENSE_RANK() OVER (
                        ORDER BY E640LCT."NUMLOT",
                                 E640LCT."DESLOT",
                                 E640LCT."SITLOT"
    ) AS "SK_LOT",
    E640LCT.*,
    E640RAT."CODCCU",
    E640RAT."DESCCU",
    E640RAT."ABRCCU",
    E640RAT."TIPCCU",
    E640RAT."MSKCCU",
    E640RAT."CCUPAI",
    E640RAT."GRUCCU",
    E640RAT."NIVCCU",
    E640RAT."POSCCU",
    E640RAT."ANASIN",
    E640RAT."CTARED",
    E640RAT."DESCTA",
    E640RAT."ABRCTA",
    E640RAT."CLACTA",
    E640RAT."FILRAT",
    E640RAT."PERRAT",
    E640RAT."VLRRAT",
    E640RAT."SITRAT",
    E640RAT."DEBCRE",
    E640RAT."CTAFIN",
    CASE 
        WHEN E640LCT."CODFIL" = E640RAT."FILRAT" THEN TRUE
        ELSE FALSE
    END AS "SMEFIL"
FROM E640LCT_TREATED E640LCT
LEFT JOIN E640RAT_TREATED E640RAT
ON E640LCT."CODEMP" = E640RAT."CODEMP"
AND E640LCT."NUMLCT" = E640RAT."NUMLCT"
