-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 13-09-2017
-- Description:	VALIDAR SI EL USUARIO ES APROBADOR O ASIGNADOR
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ValidarTipoUsuarioSolicitud] 
	-- Add the parameters for the stored procedure here
 @IdUsuario int, 
 @IdTipoAprobador int,
 @IdSolicitudPedido int 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RESPONSE NVARCHAR(300)  = 'NO_APROBADOR_NO_ASIGNADOR'
	


    -- Insert statements for procedure here
	IF @IdTipoAprobador = '2'  ---ASIGNADOR
	BEGIN 

		SELECT CASE  WHEN COUNT(O.IdDocumento)>0 THEN    'ES_ASIGNADOR'   ELSE   'NO_APROBADOR_NO_ASIGNADOR' END 
		FROM TA_Operacion AS O
		INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= O.IdDocumento
		WHERE O.IdDocumento = @IdSolicitudPedido AND O.IdAsignador= @IdUsuario AND O.IdTipoOperacion=2

	END 

	IF @IdTipoAprobador = '1'  --APROBADOR
	BEGIN 

		SELECT CASE  WHEN COUNT(O.IdDocumento)>0 THEN    'ES_APROBADOR'   ELSE   'NO_APROBADOR_NO_ASIGNADOR' END 
		FROM TA_Operacion AS O
		INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido= O.IdDocumento
		INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdOperacion = O.IdOperacion
		LEFT JOIN TA_Tarea AS TA ON TA.IdTarea = TAO.IdTarea 
		WHERE O.IdDocumento = @IdSolicitudPedido AND TA.IdAprobador= @IdUsuario AND O.IdTipoOperacion=2

	END 

	


END

