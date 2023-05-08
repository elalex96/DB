CREATE PROCEDURE AprobadoresReenvio
@IdSolicitudPedido INT,
@IdProveedor INT
AS
BEGIN

    SELECT t.IdOperacion,
           f.IdTipoFlujo,
           ac.NombreAreaContractual,
           t.IdAprobador,
           u.Correo,
		   u.Nombre,
		   t.NoSecuencia,
		   tao.Descripcion,
		   'Solicitud de pedido editada'
    FROM dbo.MM_SolicitudPedido sp
        INNER JOIN dbo.TA_Operacion tao
            ON tao.IdDocumento = sp.IdSolicitudPedido
			AND tao.IdTipoOperacion = 2
        INNER JOIN dbo.TA_Tarea t
            ON t.IdOperacion = tao.IdOperacion
        INNER JOIN dbo.TA_FlujoTarea f
            ON f.IdFlujoTarea = tao.IdFlujoTarea
        INNER JOIN Adinco.dbo.CO_Contrato c
            ON c.IdContrato = sp.IdContrato
        INNER JOIN Adinco.dbo.CO_AreaContractual ac
            ON ac.IdAreaContractual = c.IdAreaContractual
        LEFT JOIN dbo.S_Usuario u
            ON t.IdAprobador = u.IdUsuario
    WHERE tao.IdDocumento = @IdSolicitudPedido
          AND sp.IdProveedor = @IdProveedor


END;


