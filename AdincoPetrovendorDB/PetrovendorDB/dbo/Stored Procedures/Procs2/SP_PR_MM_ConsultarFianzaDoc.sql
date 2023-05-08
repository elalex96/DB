-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================

CREATE PROCEDURE SP_PR_MM_ConsultarFianzaDoc @IdDocumento INT
AS
	BEGIN
		SELECT	IdDocFianza, NombreDoc, Documento
		FROM	[dbo].TA_DocFianzaOperacion
		WHERE
				IdDocFianza = @IdDocumento
				AND Activo = 1
	END