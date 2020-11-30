-- =============================================
-- Author:		Reyna
-- Create date: 13/02/18
-- Description:	Extrae Días
-- =============================================
CREATE PROCEDURE CO_ExtraeDias
	-- Add the parameters for the stored procedure here
	@mes int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		Select  idFecha from ap_calendario 
		where mes= @mes and anio=2018


		--Select idFecha, VolumenProgramado
		--		from CO_NominacionVolumen
		--	where Month(idFecha)=02 and year(idFecha)= 2018
END

