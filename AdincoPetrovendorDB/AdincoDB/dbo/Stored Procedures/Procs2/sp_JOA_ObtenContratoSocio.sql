CREATE PROCEDURE [dbo].[sp_JOA_ObtenContratoSocio]--10061,3
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;
	SELECT CS.UrlDoc, CA.NombreContratista,RFC 
	FROM 
		CO_ContratoSocio CS
	JOIN
		CO_Contratista	CA
		ON CS.IdContratistaSocio	=	CA.IdContratista
	WHERE 
		IdContrato	=	@idContrato
END