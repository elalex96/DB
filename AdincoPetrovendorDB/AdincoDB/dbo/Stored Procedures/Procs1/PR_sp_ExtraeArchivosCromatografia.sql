CREATE PROCEDURE [dbo].[PR_sp_ExtraeArchivosCromatografia]--1,10038
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
SET LANGUAGE spanish;  
SELECT 
	CA.Id,
	CA.CromatografiaId,
	CA.AWSDocumentoId,
	CA.ContratoId,
	CA.Anio,
	DATENAME( MONTH, DATEADD( MONTH, CA.Mes, -1)) AS Mes,
	CA.CreadoEl,
	CA.CreadoPor
		,D.*, U.Nombre AS ImportadoPor
		FROM 
			CO_CromatografiaArchivo	CA
		JOIN
			AWS_Documentos	D
			ON	CA.AWSDocumentoId	=	D.AWSDocumentoId
			AND CA.ContratoId =	@IdContrato
		JOIN
			AP_USUARIO U
			ON CA.CreadoPor = U.UsuarioID
		WHERE CA.ContratoId =	@IdContrato
		ORDER BY CA.CREADOEL DESC
END;
