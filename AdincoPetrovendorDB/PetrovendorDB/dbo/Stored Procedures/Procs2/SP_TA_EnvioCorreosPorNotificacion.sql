-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/02/2021>
-- Description:	<Consulta de usuarios a los que se enviara correo por envio personalizado>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_EnvioCorreosPorNotificacion]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdContrato INT,
	@TipoNotificacion NVARCHAR(50)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
		ISNULL(ECP.IdUsuario,US.IdUsuario) AS IdUsuario,
		ISNULL(ECP.NombreDestinatario,US.Nombre) AS Nombre,
		ISNULL(ECP.Correo,US.Correo) AS Correo
	FROM dbo.TA_EnvioCorreoPersonalizado AS ECP
		LEFT JOIN S_Usuario AS US ON ECP.IdUsuario = US.IdUsuario
	WHERE ECP.IdContrato = @IdContrato AND
		ECP.IdProveedor = @IdProveedor AND
		ECP.TipoNotificacion = @TipoNotificacion AND
		ECP.Activo = 1

END