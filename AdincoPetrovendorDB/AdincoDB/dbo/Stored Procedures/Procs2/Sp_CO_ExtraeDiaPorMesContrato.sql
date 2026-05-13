-- =============================================
-- Author:		Reyna Olvera
-- Create date: 22/02/2018
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Sp_CO_ExtraeDiaPorMesContrato]
	-- Add the parameters for the stored procedure here
	
	@FechaMesAnio  nvarchar(Max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @mes int,
			@anio int; 

	Select @mes= Month(@FechaMesAnio);
	Select @anio= Year(@FechaMesAnio);
    -- Insert statements for procedure here

Select idFecha, dia From AP_Calendario
where mes=@mes and anio=@anio



END
