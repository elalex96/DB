-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/09/2020>
-- Description:	<Consulta a detalle de un Pedimento/Comprobante de Procura>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaDocContenidoNacional] --1182

	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT 
		IdAchivoCNCD,
		null,
		nombreArchivo,
		nombreArchivo,
		Extension,
		Mime,
		Carpeta,
		Identificador
	FROM dbo.CN_ArchivoCartaCompraDirecta
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante


END
