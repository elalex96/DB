-- =============================================
-- Author:		Pedro Acuña
-- Create date: 16/07/2018
-- Description:	obtener las cotizaciones realizadas y pendientes de pedido. (Requisiciones por colocar)
-- Author Update:		Alexander Gomez
-- Create date: 18/02/2019
-- Description:	Modificacion en la consulta (se consulta directamente a la tabla con Left Join)
-- =============================================

CREATE PROCEDURE [dbo].[SP_ObtenerCotizacionRealizadaPedidoPendiente]
    @IdProveedor INT,
    @IdContrato INT
AS
BEGIN
    SET LANGUAGE español;

    DECLARE @IdPeriodo INT,
            @IdPresupuesto INT;

    DECLARE @tablaRetorno TABLE
    (
        Fila INT IDENTITY,
        IdSolicitudPedido INT,
        Descripcion NVARCHAR(MAX),
        IdPresupuesto INT,
        NomPresupuesto NVARCHAR(MAX),
        IdPeriodo INT,
        NomPeriodo NVARCHAR(MAX),
        FechaEntregaRequerida NVARCHAR(MAX),
        IdEstatusOperacion INT,
        TipoProceso NVARCHAR(MAX),
        NumCotizadores INT
    ); --cantidad de proveedores que cotizaron

	IF ISNULL(@IdContrato,0) = 0
	BEGIN
		SET @IdContrato = (SELECT TOP 1
								CO.IdContrato
							FROM Adinco.dbo.CO_Contrato AS CO
								LEFT JOIN Adinco.dbo.CO_Contratista AS CC ON CC.IdContratista = CO.IdContratista
								LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE Modern_Spanish_CI_AS = CC.RFC COLLATE Modern_Spanish_CI_AS
							WHERE PR.IdProveedor = @IdProveedor)
	END

    DECLARE @contador INT = 1,
            @NomPresupuestoAux NVARCHAR(MAX),
            @NomPeriodoAux NVARCHAR(MAX),
            @numRegistros INT,
            @Descripcion NVARCHAR(MAX),
            @IdSolPed INT;

    INSERT INTO @tablaRetorno
    (
        IdSolicitudPedido,
        IdPresupuesto,
        IdPeriodo,
        FechaEntregaRequerida,
        IdEstatusOperacion,
        Descripcion,
        NumCotizadores,
        TipoProceso
    )
    SELECT SP.IdSolicitudPedido,
           SP.IdPresupuesto,
           SP.IdPeriodo,
           CASE
               WHEN SP.EntregasParciales = 1 THEN
                   CONVERT(NVARCHAR(MAX), CONVERT(DATE, SP.FechaEntregaRequerida, 101)) + ' - '
                   + CONVERT(NVARCHAR(MAX), CONVERT(DATE, SP.FechaEntregaFinRequerida, 101))
               ELSE
                   CONVERT(NVARCHAR(MAX), CONVERT(DATE, SP.FechaEntregaRequerida, 101))
           END AS FechaEntrega,
           O.IdEstatusOperacion,
           O.Descripcion,
           SUM(   CASE
                      WHEN PO.NoCotizar = 1 THEN
                          1
                      ELSE
                          CASE
                              WHEN PO.Cotizado = 1 THEN
                                  1
                              ELSE
                                  0
                          END
                  END
              ) AS Cotizadores,
           CASE
               WHEN PO.IdTipoProceso = 2 THEN
                   'Mercadeo'
               ELSE
                   'Adjudicación Directa'
           END AS TipoProceso
    FROM MM_SolicitudPedido AS SP
        INNER JOIN MM_TipoSolicitudPedido AS TSP
            ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
        INNER JOIN TA_Operacion AS O
            ON O.IdDocumento = SP.IdSolicitudPedido
               AND O.IdTipoOperacion = 6
			   AND ISNULL(O.IdEstatusEliminado, 0) <> 1 --> DIFERENTE DE ESTATUS ELIMINADO
        --INNER JOIN TA_Vencimiento AS V
        --    ON V.IdVencimiento = O.IdVigencia
        --INNER JOIN TA_Estatus AS E
        --    ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN MM_PeticionOferta AS PO
            ON PO.IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(po.IdEstatusEliminado, 0) <> 1 --> DIFERENTE DE ESTATUS ELIMINADO
        LEFT JOIN dbo.MM_Pedido pedido
            ON pedido.IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(pedido.IdEstatusEliminado, 0) <> 1 --> DIFERENTE DE ESTATUS ELIMINADO
    WHERE SP.IdProveedor = @IdProveedor
          AND SP.IdContrato = @IdContrato
          AND O.FechaFinalizacion IS NOT NULL
          AND SP.IdTipoProceso IN ( 2, 4 ) -- Mercadeo, Adj Directa
          AND pedido.IdPedido IS NULL
    GROUP BY SP.IdSolicitudPedido,
             TSP.TipoSolicitudPedido,
             O.Descripcion,
             O.FechaRegistro,
             O.FechaFinalizacion,
             PO.IdTipoProceso,
             SP.IdPeriodo,
             SP.IdPresupuesto,
             SP.EntregasParciales,
             SP.FechaEntregaRequerida,
             SP.FechaEntregaFinRequerida,
             O.IdEstatusOperacion
    ORDER BY SP.IdSolicitudPedido DESC;

    SELECT @numRegistros = COUNT(*)
    FROM @tablaRetorno;

    WHILE (@numRegistros >= @contador)
    BEGIN
        SELECT @IdPresupuesto = IdPresupuesto,
               @IdPeriodo = IdPeriodo,
               @IdSolPed = IdSolicitudPedido
        FROM @tablaRetorno
        WHERE Fila = @contador;

        SELECT @NomPeriodoAux = NombrePeriodo
        FROM Adinco.dbo.CO_PeriodoContrato
        WHERE IdPeriodo = @IdPeriodo;

        SELECT @NomPresupuestoAux
            = CONCAT(
                        CO_Presupuesto.Nombre COLLATE Modern_Spanish_CI_AS,
                        ' [',
                        CO_Presupuesto.IdPresupuestoCNH COLLATE Modern_Spanish_CI_AS,
                        ']'
                    )
        FROM Adinco.dbo.CO_ProgramaActividad
            INNER JOIN Adinco.dbo.CO_PeriodoContrato
                ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
            INNER JOIN Adinco.dbo.CO_Presupuesto
                ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
        WHERE IdPresupuesto = @IdPresupuesto;

        UPDATE @tablaRetorno
        SET NomPeriodo = @NomPeriodoAux,
            NomPresupuesto = @NomPresupuestoAux
        WHERE Fila = @contador;

        SET @contador += 1;

        SELECT @IdPeriodo = 0,
               @IdPresupuesto = 0;
    END;

    SELECT Fila,
           IdSolicitudPedido,
           Descripcion,
           IdPresupuesto,
           NomPresupuesto,
           IdPeriodo,
           NomPeriodo,
           FechaEntregaRequerida,
           IdEstatusOperacion,
           TipoProceso,
           NumCotizadores
    FROM @tablaRetorno
    WHERE NumCotizadores > 0;

END;