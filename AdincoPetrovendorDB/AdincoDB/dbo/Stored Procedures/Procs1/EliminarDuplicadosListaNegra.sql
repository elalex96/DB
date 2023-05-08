CREATE PROC EliminarDuplicadosListaNegra
AS
BEGIN
    CREATE TABLE #RFC_DUPLICADOS
    (
        RFC VARCHAR(100),
        Contribuyente varchar(500),
        Situacion varchar(100),
        PublicacionPaginaSATPresuntos datetime
    )

    INSERT INTO #RFC_DUPLICADOS
    (
        RFC,
        Contribuyente,
        Situacion,
        PublicacionPaginaSATPresuntos
    )
    SELECT t.RFC,
           Contribuyente,
           Situacion,
           PublicacionPaginaSATPresuntos
    FROM
    (
        SELECT RFC,
               Contribuyente,
               Situacion,
               PublicacionPaginaSATPresuntos,
               DupRank = ROW_NUMBER() OVER (PARTITION BY RFC ORDER BY PublicacionPaginaSATPresuntos DESC)
        FROM ListaNegra
    ) AS T
    WHERE DupRank > 1

    DELETE ListaNegra
    FROM ListaNegra
        INNER JOIN #RFC_DUPLICADOS
            ON ListaNegra.RFC = #RFC_DUPLICADOS.RFC
               AND ListaNegra.Situacion = #RFC_DUPLICADOS.Situacion
               AND ListaNegra.PublicacionPaginaSATPresuntos = #RFC_DUPLICADOS.PublicacionPaginaSATPresuntos


END



