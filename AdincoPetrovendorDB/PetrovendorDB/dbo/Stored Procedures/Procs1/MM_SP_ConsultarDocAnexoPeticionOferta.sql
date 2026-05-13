-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <05-04-2018>
-- Description:	<Consulta de documentos anexos a la peticion oferta por IdPeticionOferta>
-- =============================================

CREATE procedure [dbo].[MM_SP_ConsultarDocAnexoPeticionOferta]
	@IdPeticionOferta INT,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
AS
BEGIN
	SELECT IdDocAnexoPeticionOferta, NomDocumento
	FROM dbo.MM_DocAnexosPeticionOferta  (NOLOCK)
	WHERE IdPeticionOferta = @IdPeticionOferta
	AND Eliminado = 0
END