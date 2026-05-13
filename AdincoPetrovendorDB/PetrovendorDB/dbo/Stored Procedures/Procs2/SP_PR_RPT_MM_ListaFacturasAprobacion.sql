

-- =============================================
-- Author:		Alexander Gomez
-- Create date: 02-04-18
-- Description:	CONSULTA TODAS LAS ACEPTACIONES PARA MODULO DE REPORTES
-- =============================================
-- Author:		DANIEL AC
-- Create date: 06-06-18
-- Description:	SE MODIFICARON COLUMNAS Y AGREGO COLUMNA DE ACTIVO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 22-10-2018
-- Description:	se agregan columnas solicitadas (Contrato, Pozo, AreaSolicitante y IdPresupuesto, Tipo de inversion)
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 20-05-2019
-- Description:	se modifica els tore ya que esta marcando timeout
-- =============================================

CREATE PROCEDURE [dbo].[SP_PR_RPT_MM_ListaFacturasAprobacion]
    -- Add the parameters for the stored procedure here
    @IdProveedor   INT,
    @IdContrato    INT      = NULL,
    @IdUsuario     INT      = NULL,
    @FechaRegistro DATETIME = NULL
AS
    BEGIN
        --DECLARE @IdProveedor INT = 420
        SET NOCOUNT ON


        DECLARE @TablaContrato TABLE ( IdContrato INT, NombreContrato NVARCHAR (MAX))


        DECLARE @TablaInstalacionesSolped TABLE ( IdSolicitudPedido INT, Instalaciones NVARCHAR (MAX))


        DECLARE @TablaPresupuestoActividad TABLE ( IdSolicitudPedido INT, PresupuestoActividad NVARCHAR (MAX))


        ;WITH
            CTE_Inst
        AS (   SELECT sp.IdSolicitudPedido
               FROM
                      dbo.MM_SolicitudPedido sp
               WHERE
                      sp.IdProveedor = @IdProveedor )
        INSERT INTO
            @TablaInstalacionesSolped ( IdSolicitudPedido, Instalaciones )
        SELECT
            CTE_Inst.IdSolicitudPedido,
            STUFF(
            (   SELECT
                        CAST(', ' AS VARCHAR (MAX))
                        + CONVERT(NVARCHAR (MAX), i.NombreInstalacion)
                FROM
                        dbo.MM_SolicitudPedido                        sp
                    INNER JOIN
                        dbo.MM_SolicitudPedidoDetalle                 spd
                            ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
                               AND sp.IdSolicitudPedido = CTE_Inst.IdSolicitudPedido
                    INNER JOIN
                        dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
                            ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
                    INNER JOIN
                        Adinco.dbo.CO_Instalacion                     i
                            ON i.IdInstalacion = spdl.IdInstalacion
                WHERE
                        sp.IdProveedor = @IdProveedor
                GROUP BY
                        i.NombreInstalacion
                FOR XML PATH('')), 1, 1, '')
        FROM
            CTE_Inst


        INSERT INTO
            @TablaContrato ( IdContrato, NombreContrato )
        SELECT
                c.IdContrato,
                c.NumeroContrato + N' - ' + area.NombreAreaContractual
        FROM
                Adinco.dbo.CO_Contrato        c
            INNER JOIN
                Adinco.dbo.CO_AreaContractual area
                    ON c.IdAreaContractual = area.IdAreaContractual


        ;WITH
            CTE_Presupuesto
        AS (   SELECT sp.IdSolicitudPedido
               FROM
                      dbo.MM_SolicitudPedido sp
               WHERE
                      sp.IdProveedor = @IdProveedor )
        INSERT INTO
            @TablaPresupuestoActividad ( IdSolicitudPedido, PresupuestoActividad )
        SELECT
            CTE_Presupuesto.IdSolicitudPedido,
            STUFF(
            (   SELECT
                        CAST(', ' AS VARCHAR (MAX))
                        + LTRIM(spdl.IdLineaPresupuesto) + ' - '
                        + CONVERT(
                              NVARCHAR (MAX),
                          activi.DescripcionActividadPetrolera)
                FROM
                        dbo.MM_SolicitudPedido                        sp
                    INNER JOIN
                        dbo.MM_SolicitudPedidoDetalle                 spd
                            ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
                               AND sp.IdSolicitudPedido = CTE_Presupuesto.IdSolicitudPedido
                    INNER JOIN
                        dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
                            ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
                    LEFT JOIN
                        dbo.CO_LineaPresupuestoMes                    lpm
                            ON spdl.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
                    LEFT JOIN
                        dbo.CO_ActividadPetroleraCNH                  activi
                            ON lpm.IdActividadPetrolera = activi.IdActividadPetrolera
                WHERE
                        sp.IdProveedor = @IdProveedor
                GROUP BY
                        spdl.IdLineaPresupuesto,
                        activi.DescripcionActividadPetrolera
                FOR XML PATH('')), 1, 1, '')
        FROM
            CTE_Presupuesto


        SELECT
                AP.IdAceptacionPedido,
                PE.IdPedido,
                AP.Comentario,
                AP.Creado                                            AS FechaRegistro,
                CONCAT(
                    DG.Calle, ', ', DG.NoExterior, ',',
                    ISNULL('Int.' + DG.NoExterior, ''), ', Col.', DG.Colonia,
                    ', ', DG.CodigoPostal, ', ', DG.Municipio, ', ', DG.Estado,
                    ', ', DG.Pais)                                   AS DomiclioEntrega,
                PR.RazonSocial + ' ' + ISNULL(PR.RegimenCapital, '') AS Proveedor,
                ''                                                   AS Estado,
                PG.IdPedido                                          AS IdPedidoGeneral,
                TP.TipoPedido,
                0                                                    AS TotalPedido, --SUM((APD.Cantidad + APD.Excedente) * PED.PrecioUnitario) AS TotalPedido,
                ''                                                   AS Moneda,
                PR.RFC,
                TDG.TipoDomicilio,
                ''                                                   AS Estatus,
                PE.IdSolicitudPedido,
                CASE
                    WHEN ISNULL(AP.IdEstatusEliminado, 0) <> 1
                        THEN
                        'Activo'
                    WHEN ISNULL(AP.IdEstatusEliminado, 0) = 1
                        THEN
                        'Eliminado'
                END                                                  AS Activo,
                APD.Cantidad,
                APD.IdAceptacionPedidoDetalle,
                POF.MaterialCotizadoTextoC,
                AP.NombreRecibidoPor,
                contrato.NombreContrato,
                inst.Instalaciones                                   AS Pozo,
                activ.PresupuestoActividad                           AS IdPresupuestoAreaSolicitante,
                tg.TipoGasto                                         AS TipoInversion
        FROM
                MM_AceptacionPedido            AS AP WITH ( NOLOCK )
            INNER JOIN
                dbo.MM_AceptacionPedidoDetalle AS APD WITH ( NOLOCK )
                    ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
            INNER JOIN
                MM_Pedido                      AS PE WITH ( NOLOCK )
                    ON PE.IdPedido = AP.IdPedido
            INNER JOIN
                MM_PedidoDetalle               AS PED WITH ( NOLOCK )
                    ON PED.IdPedido = PE.IdPedido
                       AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
                       AND PED.IdPedido = PE.IdPedido
            INNER JOIN
                dbo.MM_PeticionOfertaDetalle   POF WITH ( NOLOCK )
                    ON POF.IdPeticionOfertaDetalle = PED.IdPeticionOfertaDetalle
            LEFT JOIN
                MM_Pedidos                     AS PG WITH ( NOLOCK )
                    ON PE.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IdProveedor
            LEFT JOIN
                S_Proveedor                    AS PR WITH ( NOLOCK )
                    ON PR.IdProveedor = PE.IdSubcontratista
            LEFT JOIN
                dbo.PV_TipoMoneda              AS TM WITH ( NOLOCK )
                    ON TM.IdMoneda = PE.IdMoneda
            LEFT JOIN
                dbo.MM_TipoPedido              AS TP WITH ( NOLOCK )
                    ON TP.IdTipoPedido = PG.IdTipoPedido
            LEFT JOIN
                dbo.DG_Domicilio               AS DG WITH ( NOLOCK )
                    ON DG.IdDomicilio = AP.IdDomicilioEntrega
            LEFT JOIN
                dbo.DG_TipoDomicilio           AS TDG WITH ( NOLOCK )
                    ON TDG.IdTipoDomicilio = DG.IdTipoDomicilio
            LEFT JOIN
                PV_PaisRepublica               AS PAIS WITH ( NOLOCK )
                    ON PAIS.id = DG.IdPais
            INNER JOIN
                dbo.MM_SolicitudPedido         sp WITH ( NOLOCK )
                    ON sp.IdSolicitudPedido = PE.IdSolicitudPedido
            INNER JOIN
                @TablaContrato                 AS contrato
                    ON contrato.IdContrato = PE.IdContrato
            LEFT JOIN
                dbo.MM_TipoGastos              tg WITH ( NOLOCK )
                    ON tg.IdTipoGasto = sp.IdTipoGasto
            LEFT JOIN
                @TablaInstalacionesSolped      inst
                    ON inst.IdSolicitudPedido = sp.IdSolicitudPedido
            LEFT JOIN
                @TablaPresupuestoActividad     activ
                    ON activ.IdSolicitudPedido = sp.IdSolicitudPedido
        WHERE
                PE.IdProveedorCompras = @IdProveedor
                AND AP.IdProveedor = @IdProveedor
        GROUP BY
                AP.IdAceptacionPedido,
                PE.IdPedido,
                PR.RazonSocial,
                PR.RegimenCapital,
                PG.IdPedido,
                TP.TipoPedido,
                TM.TipoMonedaCorto,
                PR.RFC,
                DG.Calle,
                DG.NoExterior,
                DG.NoInterior,
                DG.Colonia,
                DG.Estado,
                DG.Municipio,
                DG.Pais,
                DG.CodigoPostal,
                TDG.TipoDomicilio,
                AP.Comentario,
                AP.Creado,
                AP.IdEstatusEliminado,
                PE.IdSolicitudPedido,
                APD.Cantidad,
                APD.IdAceptacionPedidoDetalle,
                POF.MaterialCotizadoTextoC,
                AP.NombreRecibidoPor,
                PE.IdContrato,
                tg.TipoGasto,
				contrato.NombreContrato,
				inst.Instalaciones ,
				activ.PresupuestoActividad 
        ORDER BY
                AP.IdAceptacionPedido DESC
    END
