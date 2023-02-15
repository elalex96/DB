CREATE PROCEDURE [dbo].[co_sp_ExtraeArchivoLayoutGasto]--1,10038
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
SET LANGUAGE spanish;  
SELECT 
	CA.Id,
	CA.AWSDocumentoId,
	CA.ContratoId,
	CA.CreadoEl,
	CA.CreadoPor
		,D.*, U.Nombre AS ImportadoPor
		FROM 
			CO_ArchivoLayoutGasto	CA
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