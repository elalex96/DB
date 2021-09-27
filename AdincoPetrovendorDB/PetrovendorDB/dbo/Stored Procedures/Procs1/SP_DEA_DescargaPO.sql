USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DEA_DescargaPO]    Script Date: 24/09/2021 01:26:48 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/08/2019>
-- Description:	<Descarga PO>
-- Author:		<Manuel Cruz>
-- Create date: <23/09/20219>
-- Description:	<Se agrega columna Bucket para que devuelva el select descarga estandar avance 5>
-- =============================================
ALTER PROCEDURE [dbo].[SP_DEA_DescargaPO]
	-- Add the parameters for the stored procedure here
	@IdAdjuntoPO NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		D.NombreDocumento,
		D.Extension,
		D.Mime,
		D.Carpeta,
		D.Identificador,
		D.IdDocumento,
		D.Bucket
	FROM dbo.DEA_Documento_S3 D
	LEFT JOIN dbo.DEA_AdjuntoPO AS PO ON PO.IdDocumento = D.IdDocumento
	WHERE PO.IdAdjuntoPO = @IdAdjuntoPO
	AND D.IdTipoDocumento = 2

END