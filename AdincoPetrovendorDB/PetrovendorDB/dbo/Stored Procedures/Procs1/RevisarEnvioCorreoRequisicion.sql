CREATE PROCEDURE RevisarEnvioCorreoRequisicion
@IdSolicitudPedido INT,
@IdIdentificador NVARCHAR(MAX)
AS
BEGIN
	DECLARE @EnviarCorreo BIT,
			@IdUsuarioModifico INT,
			@IdUsuarioRequisitor INT	
	
   SELECT @EnviarCorreo = EnviarCorreo, @IdUsuarioModifico = IdUsuario FROM dbo.RequisicionBandera WHERE IdSolicitudPedido = @IdSolicitudPedido AND EnviarCorreo = 1

   SELECT @IdUsuarioRequisitor = IdUsuarioSolicitante FROM dbo.MM_SolicitudPedido WHERE IdSolicitudPedido = @IdSolicitudPedido

   SELECT ISNULL(@EnviarCorreo, 0), CASE WHEN ISNULL(@IdUsuarioModifico, 0) <> ISNULL(@IdUsuarioRequisitor, 0) THEN 1 ELSE 0 END, @IdUsuarioRequisitor	 

   UPDATE dbo.RequisicionBandera
   SET EnviarCorreo = 0
   WHERE IdSolicitudPedido = @IdSolicitudPedido	


END;


