USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_ConsultaDescargaXMLFacturaEliminada]    Script Date: 12/11/2021 12:45:25 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03-06-2019>
-- Description:	<Consultar datos xml para descargar factura>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ConsultaDescargaXMLFacturaEliminada] 
	-- Add the parameters for the stored procedure here
	@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		F.XML
	FROM dbo.PR_FI_Factura AS F
	WHERE F.IdFactura = @IdFactura

END