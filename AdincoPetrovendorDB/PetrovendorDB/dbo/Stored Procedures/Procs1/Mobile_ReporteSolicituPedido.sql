--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE [dbo].[Mobile_ReporteSolicituPedido]
    @IdSolicitudPedido AS INT,
	@IdUsuarioAdinco AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS

DECLARE @Correo varchar(200)
		,@IdUsuarioPetrovendor int;
	
	SET @Correo = (SELECT Usuario FROM Adinco.dbo.AP_Usuario WHERE UsuarioID=@IdUsuarioAdinco)
	SET @IdUsuarioPetrovendor =(SELECT IdUsuario FROM dbo.S_Usuario WHERE Correo= @Correo AND Activo=1 AND IsEliminado = 0);

	SELECT 
	@IdUsuarioPetrovendor AS 'IdUsuario'
	,SP.IdSolicitudPedido AS 'Solped'
	,SP.IdProveedor
	FROM dbo.TA_Operacion AS TAO
	JOIN dbo.MM_SolicitudPedido AS SP 
	ON TAO.IdDocumento = SP.IdSolicitudPedido
	WHERE TAO.IdDocumento = @IdSolicitudPedido
	
