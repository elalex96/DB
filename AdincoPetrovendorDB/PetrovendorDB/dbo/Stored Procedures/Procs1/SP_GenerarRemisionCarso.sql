USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS SP_GenerarRemisionCarso
GO
/****** Object:  StoredProcedure [dbo].[SP_GenerarRemisionCarso]    Script Date: 12/05/2022 07:45:12 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 14/03/2022
-- Description: Se agrega condicion para que no se tomen las aceptaciones de pedido eliminadas
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 12/05/2022
-- Description: CAMBIA COLUMNA CANTIDAD DE DECIMAL A FLOAT
-- =============================================
-- =============================================
-- Author:		Luis David
-- Create date: 26/02/2022
-- Description: Se agrega la validación para el pedido eliminado
-- =============================================
CREATE PROCEDURE [dbo].[SP_GenerarRemisionCarso]
@IdOC VARCHAR(8000),
@RecId VARCHAR(MAX),
@IdPedido INT,
@DataAreaId VARCHAR(MAX),
@Asiento VARCHAR(8000)
AS
BEGIN --EMPIEZA STORE    
    DECLARE @TablaRemision TABLE
    (
        IdIdentity INT IDENTITY,
        IdOC VARCHAR(8000),
        RECID VARCHAR(MAX),
        DataAreaId VARCHAR(MAX),
        IdPedido INT,
        Item VARCHAR(MAX),
        Cantidad FLOAT,
        Asiento VARCHAR(8000),
        IdSolicitudPedido INT,
        IdProveedor INT,
        IdDomicilioEntrega INT,
        IdPedidoDetalle INT,
        IdOperacion INT,
        FechaRegistroRemision DATETIME,
        IdMaterialPetrov INT
    )


    DECLARE @TablaRemisionSinOperacion TABLE
    (
        IdOC VARCHAR(8000),
        RECID VARCHAR(MAX),
        DataAreaId VARCHAR(MAX),
        IdPedido INT,
        Item VARCHAR(MAX),
        Cantidad FLOAT,
        Asiento VARCHAR(8000),
        IdSolicitudPedido INT,
        IdProveedor INT,
        IdDomicilioEntrega INT,
        IdPedidoDetalle INT,
        IdMaterialPetrov INT,
        FechaRegistroRemision DATETIME
    )

    DECLARE @Usuario NVARCHAR(100) = N'Registro Automático'

    INSERT INTO @TablaRemision
    (
        IdOC,
        RECID,
        DataAreaId,
        IdPedido,
        Item,
        Cantidad,
        Asiento,
        IdSolicitudPedido,
        IdProveedor,
        IdPedidoDetalle,
        IdDomicilioEntrega,
        IdOperacion,
        FechaRegistroRemision,
        IdMaterialPetrov
    )
    SELECT r.IdOC,
           r.RECID,
           r.DataAreaId,
           r.IdPedido,
           r.Item,
           r.Cantidad,
           r.Asiento,
           sp.IdSolicitudPedido,
           sp.IdProveedor,
           pd.IdPedidoDetalle,
           spd.IdDomicilioEntrega,
           O.IdOperacion,
           r.fecharegistro,
           pd.IdMaterial
    FROM dbo.MM_SolicitudPedido sp
        INNER JOIN dbo.AX_Comparativa comp
            ON  sp.IdSolicitudPedido = comp.IdSolicitudPedido 
        INNER JOIN dbo.AX_Remision r
            ON UPPER(comp.DataAreaId) = UPPER(r.DataAreaId) 
               AND UPPER(comp.IdPosicion) = UPPER(r.RECID)
        INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
            ON comp.IdDinamicsAx = spd.IdDinamicsAx 
        INNER JOIN dbo.MM_PeticionOfertaDetalle pod -- apartir de aqui no se muestra ya que no hay peticion oferta aun    
            ON spd.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle 
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle 
               AND r.IdPedido = pd.IdPedido
        INNER JOIN dbo.TA_Operacion O --filtrar para que solo sean los que esa antes de crear    
            ON sp.IdSolicitudPedido = O.IdDocumento 
               AND sp.IdProveedor = O.IdProveedor 
               AND O.IdTipoOperacion = 9 --> CTE PEDIDO
        INNER JOIN dbo.MM_Pedido p
            ON sp.IdSolicitudPedido = p.IdSolicitudPedido 
               AND  O.NoVersion = p.Version 
               AND  pod.IdPeticionOferta = p.IdPeticionOferta
    WHERE UPPER(r.RECID) = UPPER(@RecId)
          AND r.IdPedido = @IdPedido
          AND UPPER(r.IdOC) = UPPER(@IdOC)
          AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
          AND UPPER(r.Asiento) = UPPER(@Asiento)
          AND ISNULL(p.IdEstatusEliminado, 0) <> 1
    IF NOT EXISTS
    (   SELECT 1
        FROM dbo.MM_SolicitudPedido sp
            INNER JOIN dbo.AX_Comparativa comp
                ON sp.IdSolicitudPedido = comp.IdSolicitudPedido 
            INNER JOIN dbo.AX_Remision r
                ON UPPER(comp.DataAreaId) = UPPER(r.DataAreaId) 
                   AND UPPER(comp.IdPosicion) = UPPER(r.RECID) 
            INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
                ON comp.IdDinamicsAx = spd.IdDinamicsAx 
            INNER JOIN dbo.MM_PeticionOfertaDetalle pod -- apartir de aqui no se muestra ya que no hay peticion oferta aun    
                ON  spd.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
            INNER JOIN dbo.MM_PedidoDetalle pd
                ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle 
            INNER JOIN dbo.TA_Operacion O --filtrar para que solo sean los que esa antes de crear    
                ON sp.IdSolicitudPedido = O.IdDocumento 
                   AND sp.IdProveedor = O.IdProveedor 
                   AND O.IdTipoOperacion = 9 --> CTE Aprobacion de pedido
            INNER JOIN dbo.MM_Pedido p
                ON sp.IdSolicitudPedido = p.IdSolicitudPedido 
                   AND O.NoVersion = p.Version 
        WHERE UPPER(r.RECID) = UPPER(@RecId)
              AND r.IdPedido = @IdPedido
              AND UPPER(r.IdOC) = UPPER(@IdOC)
              AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
              AND UPPER(r.Asiento) = UPPER(@Asiento))
    BEGIN
        DECLARE @Retorno NVARCHAR(MAX)
        SELECT @Retorno
            = CONCAT(
              ' La consulta no encontro datos con la siguiente información: ',
              'RecId: ',
              UPPER(@RecId),
              ', IdPedido: ',
              @IdPedido,
              ', IdOc: ',
              @IdOC,
              ', DataAreaId: ',
              @DataAreaId,
              ', Asiento: ',
              @Asiento)

        INSERT INTO dbo.Ax_BitacoraCarso
        (
            ErrorMotivo,
            Lugar,
            DataAreaId,
            RecId,
            FechaRegistro,
            IdPedido,
            IdOc,
            IdAsientoPago
        )
        SELECT @Retorno,
               'SP_GenerarRemisionCarso',
               @DataAreaId,
               @RecId,
               GETDATE(),
               @IdPedido,
               @IdOC,
               @Asiento

        RAISERROR(@Retorno, 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO @TablaRemisionSinOperacion
        (
            IdOC,
            RECID,
            DataAreaId,
            IdPedido,
            Item,
            Cantidad,
            Asiento,
            IdSolicitudPedido,
            IdProveedor,
            IdDomicilioEntrega,
            IdPedidoDetalle,
            FechaRegistroRemision,
            IdMaterialPetrov
        )
        SELECT IdOC,
               RECID,
               DataAreaId,
               IdPedido,
               Item,
               Cantidad,
               Asiento,
               IdSolicitudPedido,
               IdProveedor,
               IdDomicilioEntrega,
               IdPedidoDetalle,
               FechaRegistroRemision,
               IdMaterialPetrov
        FROM @TablaRemision
        GROUP BY IdOC,
                 RECID,
                 DataAreaId,
                 IdPedido,
                 Item,
                 Cantidad,
                 Asiento,
                 IdSolicitudPedido,
                 IdProveedor,
                 IdDomicilioEntrega,
                 IdPedidoDetalle,
                 FechaRegistroRemision,
                 IdMaterialPetrov

        UPDATE tr
        SET tr.IdMaterialPetrov = am.IdMaterialPetrov
        FROM @TablaRemisionSinOperacion tr
            INNER JOIN dbo.AX_MATERIAL am
                ON tr.Item = am.IdMaterialAx 

        -- se aprueba la operacion     
        UPDATE o
        SET o.IdEstatusOperacion = 2,
            o.IdEstadoFlujo = 3
        FROM @TablaRemision r
            INNER JOIN dbo.TA_Operacion o
                ON r.IdOperacion = o.IdOperacion 
                   AND r.IdProveedor = o.IdProveedor 


        -- si no contiene aceptacion de servicio    
        IF NOT EXISTS
        (   SELECT 1
            FROM dbo.MM_AceptacionPedido ap
                INNER JOIN @TablaRemisionSinOperacion r
                    ON ap.IdOcCarso = r.IdOC 
                       AND ap.IdProveedor = r.IdProveedor 
                       AND ap.Asiento = r.Asiento 
					   AND ISNULL(ap.IdEstatusEliminado,0)=0		
					   )
        BEGIN
            DECLARE @IdAceptacionPedidoAux INT,
                    @IdUsuario INT

            SELECT @IdUsuario = CreadoPor
            FROM dbo.MM_Pedido
            WHERE IdPedido = @IdPedido

            -- se agrega la aceptacion    
            INSERT INTO dbo.MM_AceptacionPedido
            (
                IdProveedor,
                IdPedido,
                Comentario,
                NombreUsuarioEntrega,
                Activo,
                Creado,
                IdDomicilioEntrega,
                NombreRecibidoPor,
                IdOcCarso,
                Asiento
            )
            SELECT IdProveedor,
                   IdPedido,
                   CONCAT('(', LTRIM(IdOC), ' - ', LTRIM(Asiento), ') ', LTRIM(@Usuario)),
                   CONCAT('(', LTRIM(IdOC), ' - ', LTRIM(Asiento), ') ', LTRIM(@Usuario)),
                   1,
                   GETDATE(),
                   IdDomicilioEntrega,
                   LTRIM(@Usuario),
                   IdOC,
                   Asiento
            FROM @TablaRemisionSinOperacion
            GROUP BY IdProveedor,
                     IdPedido,
                     RECID,
                     IdOC,
                     IdDomicilioEntrega,
                     Asiento

            SELECT @IdAceptacionPedidoAux = SCOPE_IDENTITY()

            INSERT INTO dbo.RelacionCartaCNPedido (IdPedido, IdAceptacionPedido, PedirCarta, CreadoPor, FechaCreacion)
            SELECT IdPedido,
                   IdAceptacionPedido,
                   1,
                   @IdUsuario,
                   GETDATE()
            FROM dbo.MM_AceptacionPedido ap
            WHERE IdAceptacionPedido = @IdAceptacionPedidoAux
        END


        IF NOT EXISTS
        (   SELECT 1
            FROM dbo.MM_AceptacionPedido ap
                INNER JOIN @TablaRemisionSinOperacion r
                    ON ap.IdOcCarso = r.IdOC  
                       AND ap.IdProveedor = r.IdProveedor  
                       AND ap.Asiento = r.Asiento 
                INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON ap.IdAceptacionPedido = apd.IdAceptacionPedido 
                       AND r.RECID = apd.RecId  
				WHERE	 ISNULL(ap.IdEstatusEliminado,0)=0	
				AND ISNULL(apd.IdEstatusEliminado,0)=0)
        BEGIN
            INSERT INTO dbo.MM_AceptacionPedidoDetalle
            (
                IdAceptacionPedido,
                IdPedidoDetalle,
                Cantidad,
                Detalle,
                Creado,
                Excedente,
                RecId,
                DataAreaId
            )
            SELECT ap.IdAceptacionPedido,
                   r.IdPedidoDetalle,
                   SUM(r.Cantidad),
                   @Usuario,
                   GETDATE(),
                   0,
                   r.RECID,
                   r.DataAreaId
            FROM @TablaRemisionSinOperacion r
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON  r.IdOC = ap.IdOcCarso 
                       AND  r.IdPedido = ap.IdPedido 
                       AND  r.IdProveedor = ap.IdProveedor 
                       AND r.Asiento =  ap.Asiento 
                LEFT JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON ap.IdAceptacionPedido = apd.IdAceptacionPedido 
                       AND r.RECID =  apd.RecId 
                INNER JOIN dbo.MM_Pedido p
                    ON ap.IdPedido = p.IdPedido  
                INNER JOIN dbo.MM_PedidoDetalle pd
                    ON p.IdPedido = pd.IdPedido  
                       AND r.IdPedido = p.IdPedido
                INNER JOIN dbo.MM_PeticionOferta po
                    ON p.IdSolicitudPedido = po.IdSolicitudPedido 
                       AND p.IdPeticionOferta = po.IdPeticionOferta 
                INNER JOIN dbo.MM_PeticionOfertaDetalle pod
                    ON po.IdPeticionOferta = pod.IdPeticionOferta 
                       AND  pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle 
                INNER JOIN dbo.AX_Comparativa comp
                    ON pod.IdSolicitudPedidoDetalle = comp.IdSolicitudPedidoDetalle 
                       AND p.IdSolicitudPedido = comp.IdSolicitudPedido 
                       AND r.RECID = comp.IdPosicion
            WHERE UPPER(r.RECID) = UPPER(@RecId)
                  AND r.IdPedido = @IdPedido
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)
                  AND apd.RecId IS NULL
                  AND ISNULL(p.IdEstatusEliminado, 0) <> 1
                  AND ISNULL(pd.IdEstatusEliminado, 0) <> 1
				  AND ISNULL(ap.IdEstatusEliminado, 0) = 0
				  AND ISNULL(apd.IdEstatusEliminado,0)=0
            GROUP BY ap.IdAceptacionPedido,
                     r.IdPedidoDetalle,
                     r.RECID,
                     r.DataAreaId


            INSERT INTO dbo.MM_AceptacionPedidoDetalleInstalacion
            (
                IdAceptacionPedido,
                IdAceptacionPedidoDetalle,
                IdPedidoDetalle,
                IdProveedor,
                IdMaterial,
                Cantidad,
                IdInstalacion,
                IdLineaPresupuesto
            )
            SELECT ap.IdAceptacionPedido,
                   apd.IdAceptacionPedidoDetalle,
                   apd.IdPedidoDetalle,
                   ap.IdProveedor,
                   r.IdMaterialPetrov,
                   SUM(r.Cantidad),
                   spdl.IdInstalacion,
                   spdl.IdLineaPresupuesto
            FROM @TablaRemisionSinOperacion r
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON r.IdOC = ap.IdOcCarso 
                       AND  r.IdPedido = ap.IdPedido 
                       AND  r.IdProveedor = ap.IdProveedor 
                       AND  r.Asiento = ap.Asiento 
					   AND ISNULL(ap.IdEstatusEliminado, 0) = 0
                JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON ap.IdAceptacionPedido = apd.IdAceptacionPedido 
                       AND r.RECID = apd.RecId 
					   AND ISNULL(apd.IdEstatusEliminado,0) = 0
                INNER JOIN dbo.MM_PedidoDetalle pd
                    ON apd.IdPedidoDetalle = pd.IdPedidoDetalle 
                INNER JOIN dbo.MM_PeticionOfertaDetalle pod
                    ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle 
                INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
                    ON pod.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle 
            WHERE UPPER(r.RECID) = UPPER(@RecId)
                  AND r.IdPedido = @IdPedido
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)
                  AND ISNULL(pd.IdEstatusEliminado, 0) <> 1					
            GROUP BY ap.IdAceptacionPedido,
                     apd.IdAceptacionPedidoDetalle,
                     apd.IdPedidoDetalle,
                     ap.IdProveedor,
                     r.IdMaterialPetrov,
                     spdl.IdInstalacion,
                     spdl.IdLineaPresupuesto
        END
        ELSE
        BEGIN
            DECLARE @Cantidad FLOAT

            SELECT @Cantidad = SUM(r.Cantidad)
            FROM dbo.AX_Remision r
            WHERE UPPER(r.RECID) = UPPER(@RecId)
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)

            UPDATE apd
            SET apd.Cantidad = @Cantidad
            FROM @TablaRemisionSinOperacion r
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON r.IdOC =  ap.IdOcCarso 
                       AND r.IdPedido = ap.IdPedido 
                       AND r.IdProveedor = ap.IdProveedor
                INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON ap.IdAceptacionPedido = apd.IdAceptacionPedido 
                       AND  r.RECID = apd.RecId 
            WHERE UPPER(apd.RecId) = UPPER(@RecId)
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)
				  AND ISNULL(ap.IdEstatusEliminado, 0) = 0
				   AND ISNULL(apd.IdEstatusEliminado,0)= 0

            UPDATE apdi
            SET apdi.Cantidad = @Cantidad
            FROM @TablaRemisionSinOperacion r
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON r.IdOC =  ap.IdOcCarso 
                       AND r.IdPedido = ap.IdPedido 
                       AND r.IdProveedor = ap.IdProveedor 
                INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON ap.IdAceptacionPedido = apd.IdAceptacionPedido 
                       AND  r.RECID = apd.RecId 
                INNER JOIN dbo.MM_AceptacionPedidoDetalleInstalacion apdi
                    ON ap.IdAceptacionPedido = apdi.IdAceptacionPedido 
                       AND apd.IdAceptacionPedidoDetalle = apdi.IdAceptacionPedidoDetalle 
            WHERE UPPER(apd.RecId) = UPPER(@RecId)
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)
				  AND ISNULL(ap.IdEstatusEliminado, 0)=0
				  AND ISNULL(apd.IdEstatusEliminado,0)=0
        END

        -- se coloca la fecha de inicio de ejecucion    
        --Seccion de la confirmacion del proveedor    
        UPDATE p
        SET p.RecepcionServicio = 1,
            p.FechaRecepcionServicio = r.FechaRegistroRemision,
            p.FechaEnvioPedido = GETDATE()
        FROM @TablaRemisionSinOperacion r
            INNER JOIN dbo.MM_AceptacionPedido ap
                ON  r.IdOC = ap.IdOcCarso 
                   AND r.IdPedido = ap.IdPedido 
                   AND r.IdProveedor = ap.IdProveedor 
                   AND r.Asiento = ap.Asiento 
            INNER JOIN dbo.MM_Pedido p
                ON ap.IdPedido = p.IdPedido 
			WHERE   ISNULL(ap.IdEstatusEliminado, 0)= 0


        UPDATE pd
        SET pd.RecepcionPedido = 1
        FROM @TablaRemisionSinOperacion r
            INNER JOIN dbo.MM_AceptacionPedido ap
                ON r.IdOC =  ap.IdOcCarso 
                   AND r.IdPedido = ap.IdPedido
                   AND r.IdProveedor = ap.IdProveedor 
                   AND r.Asiento = ap.Asiento 
            INNER JOIN dbo.MM_Pedido p
                ON  ap.IdPedido = p.IdPedido 
            INNER JOIN dbo.MM_PedidoDetalle pd
                ON p.IdPedido = pd.IdPedido 
			WHERE   ISNULL(ap.IdEstatusEliminado, 0)= 0

    END

END

 
