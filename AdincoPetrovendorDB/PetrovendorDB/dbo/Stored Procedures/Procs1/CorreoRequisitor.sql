CREATE PROCEDURE CorreoRequisitor
@IdSolicitudPedido INT,
@IdProveedor INT
AS
BEGIN

    SELECT u.Nombre, sp.MotivoUrgencia, ac.NombreAreaContractual, u.Correo, sp.IdUsuarioSolicitante
    FROM dbo.MM_SolicitudPedido sp
        INNER JOIN dbo.TA_Operacion tao
            ON tao.IdDocumento = sp.IdSolicitudPedido
			AND tao.IdTipoOperacion = 2
        INNER JOIN Adinco.dbo.CO_Contrato c
            ON c.IdContrato = sp.IdContrato
        INNER JOIN Adinco.dbo.CO_AreaContractual ac
            ON ac.IdAreaContractual = c.IdAreaContractual
        LEFT JOIN dbo.S_Usuario u
            ON sp.IdUsuarioSolicitante = u.IdUsuario
    WHERE tao.IdDocumento = @IdSolicitudPedido
          AND sp.IdProveedor = @IdProveedor


END;


