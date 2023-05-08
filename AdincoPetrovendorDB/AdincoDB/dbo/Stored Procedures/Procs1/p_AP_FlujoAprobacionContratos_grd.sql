CREATE PROC p_AP_FlujoAprobacionContratos_grd
(@pIdContratista     INT, 
 @pFlujoAprobacionId INT
)
AS
    BEGIN
        SELECT FlujoAprobacionId = MAX(fa.FlujoAprobacionId), 
               c.IdContrato, 
               c.IdContratista, 
               c.NumeroContrato, 
               c.DescripcionContrato
        INTO #tmp
        FROM CO_Contrato c
             LEFT JOIN AP_FlujoAprobacionContratos fac ON c.IdContrato = fac.IdContrato
             LEFT JOIN AP_FlujoAprobacion fa ON fa.FlujoAprobacionId = fac.FlujoAprobacionId
                                                AND fa.IdContratista = c.IdContratista
                                                AND fa.Activo = 1
                                                AND fa.FlujoAprobacionId = @pFlujoAprobacionId
        WHERE c.Activo = 1
              AND c.IdContratista = @pIdContratista--10013
        --and		fa.FlujoAprobacionId		=	@pFlujoAprobacionId
        GROUP BY	--fa.FlujoAprobacionId,
        c.IdContrato, 
        c.IdContratista, 
        c.NumeroContrato, 
        c.DescripcionContrato;
        SELECT FlujoAprobacionId, 
               IdContrato, 
               IdContratista, 
               NumeroContrato, 
               DescripcionContrato, 
               Activo = CASE
                            WHEN FlujoAprobacionId IS NOT NULL
                            THEN CAST(1 AS BIT)
                            ELSE CAST(0 AS BIT)
                        END
        FROM #tmp;
    END;
