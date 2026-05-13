create PROCEDURE [dbo].[Mobile_ConsultarTareasdeAprobacion]
    -- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @IdProveedor INT,
    @IdTipoOperacion INT
AS
BEGIN
    DECLARE @FlujoSerial TABLE
    (
        IdOperacion INT,
        NoSecuencia INT
    );
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);
    INSERT INTO @FlujoSerial
    (
        IdOperacion,
        NoSecuencia
    )
    SELECT O.IdOperacion,
           t.NoSecuencia
    FROM dbo.TA_Operacion O
        LEFT JOIN dbo.MM_Pedido p
            ON p.IdSolicitudPedido = O.IdDocumento
               AND p.Version = O.NoVersion
        INNER JOIN dbo.TA_Tarea t
            ON t.IdOperacion = O.IdOperacion
    WHERE O.IdTipoOperacion = 9
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
          AND t.IdAprobador = @IdUsuario
          AND t.NoSecuencia > 1;
    INSERT INTO @OperacionNoAprobadas
    (
        IdOperacion
    )
    SELECT O.IdOperacion
    FROM dbo.TA_Operacion O
        INNER JOIN @FlujoSerial f
            ON f.IdOperacion = O.IdOperacion
        INNER JOIN dbo.TA_Tarea T
            ON T.IdOperacion = O.IdOperacion
               AND T.NoSecuencia = (f.NoSecuencia - 1)
    WHERE O.IdTipoOperacion = 9
          AND T.IdEstatus <> 1;
    SELECT O.IdOperacion,
           O.IdDocumento,
		   t.IdTarea,
		   --CONCAT('Requisicion: ', O.IdDocumento, '- Pedido: ', P2.IdPedido, '- Descripción: ', O.Descripcion) AS Descripcion,
		   P2.IdPedido AS 'Pedido p2', 
           O.FechaRegistro,
           O.Descripcion AS Descripcion,
           E.Nombre,
           P.Version,
           sp.MotivoUrgencia,
		   p.IdContrato
    FROM TA_Operacion AS O
        LEFT JOIN MM_Pedido AS P ON P.IdSolicitudPedido = O.IdDocumento
        INNER   JOIN    dbo.MM_Pedidos P2 ON P.IdPedido = P2.IdIdentificador
        LEFT JOIN dbo.MM_SolicitudPedido SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
        LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN TA_Tarea AS T ON T.IdOperacion = O.IdOperacion
        LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = T.IdAprobador
        LEFT JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario
                                               AND SP.IdContrato = UP.IdContrato
                                               AND UP.IdProveedor = O.IdProveedor
        LEFT JOIN dbo.S_Proveedor prov ON prov.IdProveedor = P.IdSubcontratista
          WHERE T.IdAprobador = @IdUsuario
          AND O.IdTipoOperacion = @IdTipoOperacion
          AND P.Version = O.NoVersion
		  AND t.IdEstatus = 1
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
          AND ISNULL(p.IdEstatusEliminado, 0) <> 1 -->Pedido no eliminado
          AND O.IdOperacion NOT IN (
                                       SELECT IdOperacion FROM @OperacionNoAprobadas
                                   )
    GROUP BY O.IdOperacion,
             O.IdDocumento,
             O.FechaRegistro,
             O.Descripcion,
             E.Nombre,
             O.IdTipoOperacion,
             P.Version,
             prov.RazonSocial,
             P.IdSubcontratista,
             sp.MotivoUrgencia,
            P2.IdPedido
			,p.IdContrato
			,t.IdTarea
    ORDER BY O.FechaRegistro DESC;
END;