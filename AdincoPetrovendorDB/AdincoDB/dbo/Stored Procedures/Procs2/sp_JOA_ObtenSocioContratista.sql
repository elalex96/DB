CREATE PROCEDURE [dbo].[sp_JOA_ObtenSocioContratista]--10061,3
    @idUsuario INT,
	@idContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @ContratistaId	INT	=	0;

	SELECT  @ContratistaId =	IdContratista	
	FROM	
		CO_Contrato
	WHERE
		IdContrato	=	@idContrato


	SELECT 
		CS.IdContratistaSocio,	CIS.NombreContratista
	FROM
		CO_Contrato	C
	JOIN
		CO_Contratista	CI
		ON	C.IdContratista	=	CI.IdContratista
		AND	C.IdContratista	=	@ContratistaId
	JOIN
		CO_ContratoSocio	CS
		ON	C.IdContrato	=	CS.IdContrato
	JOIN
		CO_Contratista	CIS
		ON	CS.IdContratistaSocio	=	CIS.IdContratista
	GROUP BY
		CS.IdContratistaSocio,	CIS.NombreContratista
	
END

