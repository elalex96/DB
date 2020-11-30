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
        Cantidad DECIMAL(20, 2),
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
        Cantidad DECIMAL(20, 2),
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
            ON comp.IdSolicitudPedido = sp.IdSolicitudPedido
        INNER JOIN dbo.AX_Remision r
            ON UPPER(r.DataAreaId) = UPPER(comp.DataAreaId)
               AND UPPER(r.RECID) = UPPER(comp.IdPosicion)
        INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
            ON spd.IdDinamicsAx = comp.IdDinamicsAx
        INNER JOIN dbo.MM_PeticionOfertaDetalle pod -- apartir de aqui no se muestra ya que no hay peticion oferta aun    
            ON pod.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
               AND pd.IdPedido = r.IdPedido
        INNER JOIN dbo.TA_Operacion O --filtrar para que solo sean los que esa antes de crear    
            ON O.IdDocumento = sp.IdSolicitudPedido
               AND O.IdProveedor = sp.IdProveedor
               AND O.IdTipoOperacion = 9
        INNER JOIN dbo.MM_Pedido p
            ON p.IdSolicitudPedido = sp.IdSolicitudPedido
               AND p.Version = O.NoVersion
               AND p.IdPeticionOferta = pod.IdPeticionOferta
    WHERE UPPER(r.RECID) = UPPER(@RecId)
          AND r.IdPedido = @IdPedido
          AND UPPER(r.IdOC) = UPPER(@IdOC)
          AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
          AND UPPER(r.Asiento) = UPPER(@Asiento)

    IF NOT EXISTS
    (   SELECT 1
        FROM dbo.MM_SolicitudPedido sp
            INNER JOIN dbo.AX_Comparativa comp
                ON comp.IdSolicitudPedido = sp.IdSolicitudPedido
            INNER JOIN dbo.AX_Remision r
                ON UPPER(r.DataAreaId) = UPPER(comp.DataAreaId)
                   AND UPPER(r.RECID) = UPPER(comp.IdPosicion)
            INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
                ON spd.IdDinamicsAx = comp.IdDinamicsAx
            INNER JOIN dbo.MM_PeticionOfertaDetalle pod -- apartir de aqui no se muestra ya que no hay peticion oferta aun    
                ON pod.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
            INNER JOIN dbo.MM_PedidoDetalle pd
                ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
            INNER JOIN dbo.TA_Operacion O --filtrar para que solo sean los que esa antes de crear    
                ON O.IdDocumento = sp.IdSolicitudPedido
                   AND O.IdProveedor = sp.IdProveedor
                   AND O.IdTipoOperacion = 9
            INNER JOIN dbo.MM_Pedido p
                ON p.IdSolicitudPedido = sp.IdSolicitudPedido
                   AND p.Version = O.NoVersion
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
                ON am.IdMaterialAx = tr.Item

        -- se aprueba la operacion     
        UPDATE o
        SET o.IdEstatusOperacion = 2,
            o.IdEstadoFlujo = 3
        FROM @TablaRemision r
            INNER JOIN dbo.TA_Operacion o
                ON o.IdOperacion = r.IdOperacion
                   AND o.IdProveedor = r.IdProveedor


        -- si no contiene aceptacion de servicio    
        IF NOT EXISTS
        (   SELECT 1
            FROM dbo.MM_AceptacionPedido ap
                INNER JOIN @TablaRemisionSinOperacion r
                    ON r.IdOC = ap.IdOcCarso
                       AND r.IdProveedor = ap.IdProveedor
                       AND r.Asiento = ap.Asiento)
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
                    ON r.IdOC = ap.IdOcCarso
                       AND r.IdProveedor = ap.IdProveedor
                       AND r.Asiento = ap.Asiento
                INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
                       AND apd.RecId = r.RECID)
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
                    ON ap.IdOcCarso = r.IdOC
                       AND ap.IdPedido = r.IdPedido
                       AND ap.IdProveedor = r.IdProveedor
                       AND ap.Asiento = r.Asiento
                LEFT JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
                       AND apd.RecId = r.RECID
                INNER JOIN dbo.MM_Pedido p
                    ON p.IdPedido = ap.IdPedido
                INNER JOIN dbo.MM_PedidoDetalle pd
                    ON pd.IdPedido = p.IdPedido
                       AND r.IdPedido = p.IdPedido
                INNER JOIN dbo.MM_PeticionOferta po
                    ON po.IdSolicitudPedido = p.IdSolicitudPedido
                       AND po.IdPeticionOferta = p.IdPeticionOferta
                INNER JOIN dbo.MM_PeticionOfertaDetalle pod
                    ON pod.IdPeticionOferta = po.IdPeticionOferta
                       AND pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
                INNER JOIN dbo.AX_Comparativa comp
                    ON comp.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
                       AND comp.IdSolicitudPedido = p.IdSolicitudPedido
                       AND r.RECID = comp.IdPosicion
            WHERE UPPER(r.RECID) = UPPER(@RecId)
                  AND r.IdPedido = @IdPedido
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)
                  AND apd.RecId IS NULL
                  AND ISNULL(p.IdEstatusEliminado, 0) <> 1
                  AND ISNULL(pd.IdEstatusEliminado, 0) <> 1
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
                    ON ap.IdOcCarso = r.IdOC
                       AND ap.IdPedido = r.IdPedido
                       AND ap.IdProveedor = r.IdProveedor
                       AND ap.Asiento = r.Asiento
                LEFT JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
                       AND apd.RecId = r.RECID
                INNER JOIN dbo.MM_PedidoDetalle pd
                    ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
                INNER JOIN dbo.MM_PeticionOfertaDetalle pod
                    ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
                INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
                    ON spdl.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
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
            DECLARE @Cantidad DECIMAL(20, 2)

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
                    ON ap.IdOcCarso = r.IdOC
                       AND ap.IdPedido = r.IdPedido
                       AND ap.IdProveedor = r.IdProveedor
                INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
                       AND apd.RecId = r.RECID
            WHERE UPPER(apd.RecId) = UPPER(@RecId)
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)

            UPDATE apdi
            SET apdi.Cantidad = @Cantidad
            FROM @TablaRemisionSinOperacion r
                INNER JOIN dbo.MM_AceptacionPedido ap
                    ON ap.IdOcCarso = r.IdOC
                       AND ap.IdPedido = r.IdPedido
                       AND ap.IdProveedor = r.IdProveedor
                INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
                    ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
                       AND apd.RecId = r.RECID
                INNER JOIN dbo.MM_AceptacionPedidoDetalleInstalacion apdi
                    ON apdi.IdAceptacionPedido = ap.IdAceptacionPedido
                       AND apdi.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
            WHERE UPPER(apd.RecId) = UPPER(@RecId)
                  AND UPPER(r.IdOC) = UPPER(@IdOC)
                  AND UPPER(r.DataAreaId) = UPPER(@DataAreaId)
                  AND UPPER(r.Asiento) = UPPER(@Asiento)
        END

        -- se coloca la fecha de inicio de ejecucion    
        --Seccion de la confirmacion del proveedor    
        UPDATE p
        SET p.RecepcionServicio = 1,
            p.FechaRecepcionServicio = r.FechaRegistroRemision,
            p.FechaEnvioPedido = GETDATE()
        FROM @TablaRemisionSinOperacion r
            INNER JOIN dbo.MM_AceptacionPedido ap
                ON ap.IdOcCarso = r.IdOC
                   AND ap.IdPedido = r.IdPedido
                   AND ap.IdProveedor = r.IdProveedor
                   AND ap.Asiento = r.Asiento
            INNER JOIN dbo.MM_Pedido p
                ON p.IdPedido = ap.IdPedido


        UPDATE pd
        SET pd.RecepcionPedido = 1
        FROM @TablaRemisionSinOperacion r
            INNER JOIN dbo.MM_AceptacionPedido ap
                ON ap.IdOcCarso = r.IdOC
                   AND ap.IdPedido = r.IdPedido
                   AND ap.IdProveedor = r.IdProveedor
                   AND ap.Asiento = r.Asiento
            INNER JOIN dbo.MM_Pedido p
                ON p.IdPedido = ap.IdPedido
            INNER JOIN dbo.MM_PedidoDetalle pd
                ON pd.IdPedido = p.IdPedido
    END

END