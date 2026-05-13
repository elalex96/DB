-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/11/2018
-- Description:	Consulta si ya se reenvio esta esta PRE-SES para aprobacion
-- =============================================
CREATE procedure [dbo].[SP_MPY_ConsultaUltimaPRESES]
	-- Add the parameters for the stored procedure here
	@PONumber VARCHAR(50),
	@PRESES VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		PSES.IdEstatus,
		PSES.ModificadoEl,
		US.Nombre,
		PSES.IdPRESES
	FROM Adinco.dbo.CO_SAPPRESES AS PSES
		LEFT JOIN dbo.S_Usuario AS US ON PSES.ModificadoPor = US.IdUsuario
	WHERE PSES.SAPPONumber = @PONumber
		AND PSES.SAPSESNumber = @PRESES
	ORDER BY PSES.CreadoEl DESC
END
