 -- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/09/2020>
-- Description:	<Consulta a detalle de un Pedimento/Comprobante de Procura>
-- =============================================
-- Author:      <Luis David>
-- Create date: <31/08/2021>
-- Description: <Se agrega el campo bucket al sp>
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
	
	SELECT top 1
		IdAchivoCNCD,
		null,
		nombreArchivo,
		nombreArchivo,
		Extension,
		Mime,
		Carpeta,
		Identificador,
		Bucket
	FROM dbo.CN_ArchivoCartaCompraDirecta
	WHERE IdPedimentoComprobante = @IdPedimentoComprobante
END
