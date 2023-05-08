-- =============================================
-- Author:		Reyna O
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE CO_nominacionVolumenCaptura
	-- Add the parameters for the stored procedure here
	@VolumenProgramado float ,
	@idNominacionVolumen int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update CO_NominacionVolumen
set VolumenProgramado=@VolumenProgramado
where idNominacionVolumen=@idNominacionVolumen
END

