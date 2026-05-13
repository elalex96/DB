-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <12-04-18>
-- Description:	<Consulta el estatus para saber si tiene que mostrar o no el modal de las nuevas actualizaciones>
-- =============================================
CREATE PROCEDURE [dbo].[SP_Help_CheckIteraciones]
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	CASE 
	WHEN NotificacionActualizaciones = 0 THEN CAST(0 AS INT)
	WHEN NotificacionActualizaciones = 1 THEN CAST(1 AS INT)
	WHEN NotificacionActualizaciones IS NULL THEN CAST(1 AS INT)
	END AS NotificacionActualizaciones
	FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario

END
