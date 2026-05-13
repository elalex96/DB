-- =============================================
-- Author:		Reyna Olvera
-- =============================================
CREATE PROCEDURE [dbo].[sp_JOA_ObtenFrecuencia]--3,10061,2
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

	SELECT 
		IdFrecuenciaEntregable, FrecuenciaIngles as FrecuenciaEntregable
	FROM 
		[EN_FrecuenciaEntregable]
	WHERE
		FrecuenciaIngles	IS NOT NULL
	
END;


