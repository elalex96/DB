-- =============================================
-- Author:		<Jose Roman>
-- Create date: <>
-- Description:	<>
-- =============================================

CREATE procedure PV_SP_ConsultarAvisoPrivacidad
	
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT AvisoPrivacidad FROM dbo.PV_AvisoPrivacidad WHERE IdAvisoPrivacidad = 1
END
