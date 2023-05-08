-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22/01/2018>
-- Description:	<Se crea para consultar el correo de clientes>
-- =============================================

CREATE procedure CB_SP_ConsultaCorreoSubContratista
	@IdContratista INT,
	@IdSubContratista INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	
	SELECT ISNULL(Correo,'') AS correo
		FROM dbo.PV_ContratistaSubContratista
		WHERE IdSubContratista = @IdSubContratista
			AND IdContratista = @IdContratista
			AND IsActivo = 1

END
