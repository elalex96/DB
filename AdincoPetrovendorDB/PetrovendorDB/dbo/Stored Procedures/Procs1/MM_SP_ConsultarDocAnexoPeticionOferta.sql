
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <05-04-2018>
-- Description:	<Consulta de documentos anexos a la peticion oferta por IdPeticionOferta>
-- =============================================

CREATE procedure MM_SP_ConsultarDocAnexoPeticionOferta
	@IdPeticionOferta INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdDocAnexoPeticionOferta, NomDocumento
	FROM dbo.MM_DocAnexosPeticionOferta
	WHERE IdPeticionOferta = @IdPeticionOferta
		AND Eliminado = 0
END