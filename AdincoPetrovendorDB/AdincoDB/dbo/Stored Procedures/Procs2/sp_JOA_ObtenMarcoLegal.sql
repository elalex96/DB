-- =============================================
-- Author:		Reyna Olvera
-- =============================================
CREATE PROCEDURE [dbo].[sp_JOA_ObtenMarcoLegal]--3,10061,2
    @IdContrato INT,
    @IdUsuario INT,
	@idSocio	INT
AS
BEGIN

    SET NOCOUNT ON;

	CREATE TABLE #Contratos(id int identity(1,1), idContrato int);

	INSERT INTO #Contratos(idContrato)
	SELECT 
		cs.IdContrato
	FROM 
		CO_ContratoSocio	CS
	JOIN
		CO_CONTRATO	C
		ON	CS.IdContrato	=	C.IdContrato
	WHERE 
		CS.IdContratistaSocio = @idSocio


		SELECT 
			   ML.IdMarcoLegal,
			   ML.MarcoLegal
		FROM 
			EN_MarcoLegal ML
		JOIN 
			EN_Entregable E 
			ON ML.IdMarcoLegal	=	E.IdMarcoLegal
			AND ML.BitJOA	=	1
		JOIN 
			EN_ContratoEntregable CE 
			on E.IdEntregable	=	CE.IdEntregable 
			
		JOIN
			#Contratos	C
			ON CE.IdContrato	=	C.IdContrato
		where 
				ML.Activo	=	1 
			AND	E.IsActivo	=	1 
			AND CE.Activo	=	1 
		GROUP BY  
			ML.IdMarcoLegal,
			ML.MarcoLegal
		ORDER BY ML.MARCOLEGAL
	
END


