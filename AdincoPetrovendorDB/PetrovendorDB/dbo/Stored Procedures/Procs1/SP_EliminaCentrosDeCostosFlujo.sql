-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[SP_EliminaCentrosDeCostosFlujo]
@IdCentroCosto INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[CC_CentroCosto] 
	SET [IsActivo] = 'false'
	WHERE [IdCentroCosto] = @IdCentroCosto

	UPDATE dbo.RelacionCentroCostoFlujoAprob
	SET	 Activo = 0
	WHERE IdCentroCosto = @IdCentroCosto

END

