-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <15/12/2020>
-- Description:	<Consulta de los documentos por contrato y usuario guardados>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EniArchivosDescargaCarpeta] --3,10009
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT
		UUIDAmazon,
		NombreArchivo,
		Meta,
		Folder
	FROM dbo.AWS_DocumentoENI AS DE
	WHERE DE.Folder = 'ENIArchivos/PLANESAPROBADOS/'
		AND DE.IdContrato = @IdContrato
		AND DE.Privado = 0
	UNION
	SELECT
		UUIDAmazon,
		NombreArchivo,
		Meta,
		Folder
	FROM dbo.AWS_DocumentoENI AS DE
	WHERE DE.Folder = 'ENIArchivos/PLANESAPROBADOS/'
		AND DE.IdContrato = @IdContrato
		AND DE.Privado = 1
		AND DE.CreadoPor = @IdUsuario;

END


