-- =============================================
-- Author:		Reyna olvera
-- Create date: 20180816
-- Description:	extrae el historial de pagos de los propietarios
-- =============================================
CREATE PROCEDURE CO_HistorialPagosPropietarios --3,'2018-06-16',2
    @Contrato INT,
    @idUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdRelacionado INT;

    IF OBJECT_ID('tempdb..#Contratos') IS NOT NULL
        DROP TABLE #Contratos;
    CREATE TABLE #Contratos
    (
        IdContrato INT
    );

    SELECT @IdRelacionado = REL.IdRelacionado
    FROM dbo.CO_Contrato C
        JOIN CO_ContratistaRelacionado REL
            ON C.IdContratista = REL.IdContratista
    WHERE C.IdContrato = @Contrato;

    -- SI NO HAY CONTRATISTAS RELACIONADOS, SE INSERTAN TODOS LOS CONTRATOS DEL MISMO SUBCONTRATISTA    
    IF ISNULL(@IdRelacionado, 0) = 0
    BEGIN
        INSERT INTO #Contratos
        (
            IdContrato
        )
        SELECT C2.IdContrato
        FROM dbo.CO_Contrato C
            JOIN dbo.CO_Contrato C2
                ON C.IdContratista = C2.IdContratista
        WHERE C.IdContrato = @Contrato;
    END;
    ELSE
    BEGIN
        INSERT INTO #Contratos
        (
            IdContrato
        )
        SELECT C.IdContrato
        FROM dbo.CO_Contrato C
            JOIN CO_ContratistaRelacionado REL
                ON C.IdContratista = REL.IdContratista
        WHERE REL.IdRelacionado = @IdRelacionado;

    END;


    SELECT IdPagoPropietario,
           NombrePropietario,
           NombreAreaContractual,
           KM2,
           MesPago,
           MontoCalculado,
           MontoPagado,
           FechaPago,
           MetodoPago,
           Comentarios
    FROM CO_HistorialPagos_Propietarios
        JOIN dbo.CO_PropietariosAreaContractual
            ON CO_PropietariosAreaContractual.IdPropietario = CO_HistorialPagos_Propietarios.IdPropietario
        JOIN dbo.CO_AreaContractual
            ON CO_AreaContractual.IdAreaContractual = CO_PropietariosAreaContractual.IdAreaContractual
        JOIN dbo.CO_Contrato
            ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
    WHERE IdContrato IN (
							SELECT IdContrato FROM #Contratos
                        )
	GROUP BY IdPagoPropietario,
			NombrePropietario,
			NombreAreaContractual,
			KM2,
			MesPago,
			MontoCalculado,
			MontoPagado,
			FechaPago,
			MetodoPago,
			Comentarios
    ORDER BY MesPago DESC;
END;

