
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <31-07-2018>
-- Description:	<Actualizacion para los modulos>
-- =============================================

CREATE PROCEDURE AD_EI_UpdateModulos	
	@IdModulo INT,
	@Modulo NVARCHAR(100),
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	UPDATE dbo.EI_Modulo
		SET Modulo = @Modulo
		WHERE IdModulo = @IdModulo
END