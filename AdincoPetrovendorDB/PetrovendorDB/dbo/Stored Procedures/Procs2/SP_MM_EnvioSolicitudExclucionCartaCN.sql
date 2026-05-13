-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <06/12/2019>
-- Description:	<guardar solicitud de exclucion de carta CN>
-- =============================================
create PROCEDURE [dbo].[SP_MM_EnvioSolicitudExclucionCartaCN] 
-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT, 
@IdUsuario          INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        -- Insert statements for procedure here
        --BIT PARA INDICAR QUE SE PIDIO EXCLUCION DE CARTA DE ESA ACEPTACION
        INSERT INTO dbo.MM_Solicitud_ExclucionCN
        (IdAceptacionPedido, 
         IdEstatus, 
         IdUsuarioRequesitor, 
         FechaSolicitud
        )
        VALUES
        (@IdAceptacionPedido, -- IdAceptacionPedido - int
         1, -- IdEstatus - int
         @IdUsuario, -- IdUsuarioRequesitor - int
         GETDATE() -- FechaSolicitud - datetime
        );

        --DATOS PARA NOTIFICAR A LOS APROBADORES
        SELECT AP.IdAceptacionPedido, --0
               PS.IdPedido, --1
               CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')) AS Contrato, --2
               US.IdUsuario AS IdUsuarioAprobador, --3
               US.Nombre AS NombreAprobador, --4
               US.Correo AS CorreoAprobador, --5
               USR.IdUsuario AS IdUsuarioRequisitor, --6
               USR.Nombre AS NombreRequisitor, --7
               USR.Correo AS CorreoRequisitor--8
        FROM dbo.MM_AceptacionPedido AS AP
             LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
             LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido
                                               AND PS.IdProveedorCliente = P.IdProveedorCompras
             LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = P.IdContrato
             LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
             LEFT JOIN dbo.S_UsuarioProveedor AS USP ON USP.IdProveedor = P.IdProveedorCompras
             LEFT JOIN dbo.S_UsuarioRol AS UR ON UR.IdUsuario = USP.IdUsuario
             LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = UR.IdUsuario
             LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
             LEFT JOIN dbo.S_Usuario AS USR ON USR.IdUsuario = SP.IdUsuarioSolicitante
        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
              AND UR.IdRol = 3
              AND UR.Activo = 1
              AND US.Activo = 1
        GROUP BY CONCAT(ISNULL(C.NumeroContrato, ''), ' - ', ISNULL(AC.NombreAreaContractual, '')), 
                 AP.IdAceptacionPedido, 
                 PS.IdPedido, 
                 US.IdUsuario, 
                 US.Nombre, 
                 US.Correo, 
                 USR.IdUsuario, 
                 USR.Nombre, 
                 USR.Correo;
    END;