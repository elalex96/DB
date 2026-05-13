
CREATE PROCEDURE dbo.sp_BI_LlenaTabla_BI_Aprobaciones
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Aprobaciones TABLE
    (
        IdPedidoUnico INT,
        IdRequicion INT,
        Aprobador1 DATETIME,
        Aprobador2 DATETIME,
        Aprobador3 DATETIME,
        Aprobador4 DATETIME,
        Aprobador5 DATETIME,
        Aprobador6 DATETIME,
        TipoAprobacion VARCHAR(200),
        Estatus VARCHAR(200)
    );
    INSERT INTO @Aprobaciones
    (
        IdPedidoUnico,
        IdRequicion,
        Aprobador1,
        Aprobador2,
        Aprobador3,
        Aprobador4,
        Aprobador5,
        Aprobador6,
        TipoAprobacion,
        Estatus
    )
    SELECT PG.IdPedido AS 'Idunico Pedido',
           SP.IdSolicitudPedido AS 'Id de requisicion',
           T1.FechaCambioEstatus AS 'Aprobador1',
           T2.FechaCambioEstatus AS 'Aprobador2',
           T3.FechaCambioEstatus AS 'Aprobador3',
           T4.FechaCambioEstatus AS 'Aprobador4',
           T5.FechaCambioEstatus AS 'Aprobador5',
           T6.FechaCambioEstatus AS 'Aprobador6',
           'Pedido' AS 'Tipo de aprobación',
           E.Nombre AS 'Estatus'
    FROM dbo.MM_Pedido P (NOLOCK)
        INNER JOIN dbo.MM_SolicitudPedido SP (NOLOCK)
            ON P.IdSolicitudPedido = SP.IdSolicitudPedido
        INNER JOIN dbo.TA_Operacion O (NOLOCK)
            ON P.IdSolicitudPedido = O.IdDocumento
               AND O.IdTipoOperacion = 9 --> APROBACIONES DE PEDIDO
               AND O.NoVersion = P.Version
        INNER JOIN dbo.TA_Estatus E (NOLOCK)
            ON O.IdEstatusOperacion = E.IdEstatus
        INNER JOIN dbo.MM_Pedidos PG (NOLOCK)
            ON P.IdPedido = PG.IdIdentificador
               AND P.IdProveedorCompras = PG.IdProveedorCliente
        LEFT JOIN dbo.TA_Tarea T1 (NOLOCK)
            ON O.IdOperacion = T1.IdOperacion
               AND T1.NoSecuencia = 1
               AND T1.Activo = 1
        LEFT JOIN dbo.TA_Tarea T2 (NOLOCK)
            ON O.IdOperacion = T2.IdOperacion
               AND T2.NoSecuencia = 2
               AND T2.Activo = 1
        LEFT JOIN dbo.TA_Tarea T3 (NOLOCK)
            ON O.IdOperacion = T3.IdOperacion
               AND T3.NoSecuencia = 3
               AND T3.Activo = 1
        LEFT JOIN dbo.TA_Tarea T4 (NOLOCK)
            ON O.IdOperacion = T4.IdOperacion
               AND T4.NoSecuencia = 4
               AND T4.Activo = 1
        LEFT JOIN dbo.TA_Tarea T5 (NOLOCK)
            ON O.IdOperacion = T5.IdOperacion
               AND T5.NoSecuencia = 5
               AND T5.Activo = 1
        LEFT JOIN dbo.TA_Tarea T6 (NOLOCK)
            ON O.IdOperacion = T6.IdOperacion
               AND T6.NoSecuencia = 6
               AND T6.Activo = 1
    WHERE P.IdProveedorCompras IN ( 606, 676, 690, 1315, 1424 )
          AND ISNULL(P.IdEstatusEliminado, 0) <> 1; --> QUE NO ESTE ELIMINADO EL PEDIDO


    -- SE BORRA LA TABLA PARA VOLVER A INSERTA LA INFORMACION
    TRUNCATE TABLE BI_Aprobaciones;
    INSERT INTO BI_Aprobaciones
    (
        IdPedidoUnico,
        IdRequicion,
        Aprobador1,
        Aprobador2,
        Aprobador3,
        Aprobador4,
        Aprobador5,
        Aprobador6,
        TipoAprobacion
    )
    SELECT IdPedidoUnico AS 'Idunico Pedido',
           IdRequicion AS 'id de requisicion',
           Aprobador1 AS 'Aprobador1',
           Aprobador2 AS 'Aprobador2',
           Aprobador3 AS 'Aprobador3',
           Aprobador4 AS 'Aprobador4',
           Aprobador5 AS 'Aprobador5',
           Aprobador6 AS 'Aprobador6',
           TipoAprobacion AS 'Tipo de aprobación'
    FROM @Aprobaciones;

--ACTUALIZACIÓN 
--SE ACTUALIZARON RELACIONES DE TABLAS Y SE AGREGARON LAS APROBACIONES DE REQUISIONES Y FACTURA (se removieron estas aprobaciones)
--TAB APROBACIONES
--APROBACIONES QUE APROBACIONES NECESITAS LAS DE PEDIDO, SOLICITUD DE PEDIDO, O TODAS ? --> R TODAS --> EN LA JUNTA MENCIONO SOLO LA DE PEDIDOS 
-- LAS APROBACIONES DE CARTA DE CONTENIDO NACIONAL TAMBIEN? NO
END;

