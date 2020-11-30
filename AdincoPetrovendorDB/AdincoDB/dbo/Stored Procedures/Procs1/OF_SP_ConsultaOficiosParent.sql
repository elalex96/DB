-- =============================================
-- Author:		<Jose Roman>
-- Create date: <08/05/2018>
-- Description:	<Se crea consulta para grid de oficios parent>
-- =============================================

create PROCEDURE OF_SP_ConsultaOficiosParent
	@IdTipoOficio INT,
	@IdContrato INT
AS
BEGIN
	SELECT IdDocumentoOficio, 
		NumDocumento,
		Descripcion
	FROM dbo.OF_DocumentoOficio
	WHERE IdTipoOficio <> @IdTipoOficio
		AND IdContrato = @IdContrato
END