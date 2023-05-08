-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EN_ActualizacionEntregableInternoGeneral] 
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdContratoEntregable INT,
	@MostrarLineaTiempo INT,
	@NA INT,
	@CortoPlazo INT,
	@MedianoPlazo INT,
	@LargoPlazo INT,
	@IdEntregable INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE EN_ContratoEntregable
	SET BitMostrarLineaTiempo = @MostrarLineaTiempo,
		BitNA = @NA,
		BitCortoPlazo = @CortoPlazo,
		BitMedianoPlazo = @MedianoPlazo,
		BitLargoPlazo = @LargoPlazo
	WHERE IdContratoEntregable = @IdContratoEntregable;

END