-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/11/2018
-- Description:	Consulta el historial de la aprobacion de una preses de una orden de compra
-- =============================================
CREATE procedure [dbo].[SP_MPY_HistorialPRESES]
	-- Add the parameters for the stored procedure here
	@IDPO NVARCHAR(20),
	@ReferenceNumber VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		SPRESES.IdPRESES,
		US.Nombre,
		SPRESES.ModificadoEl,
		SPRESES.Justificacion,
		CASE
			WHEN SPRESES.IdEstatus = 2 THEN 'APPROVED'
			WHEN SPRESES.IdEstatus = 3 THEN 'REFUSE'
		END AS ESTATUS
	FROM Adinco.dbo.CO_SAPPRESES AS SPRESES
	LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = SPRESES.ModificadoPor
	WHERE SPRESES.SAPPONumber = @IDPO
		AND SPRESES.SAPSESNumber = @ReferenceNumber
END

SELECT * FROM Adinco.dbo.CO_SAPPRESES
