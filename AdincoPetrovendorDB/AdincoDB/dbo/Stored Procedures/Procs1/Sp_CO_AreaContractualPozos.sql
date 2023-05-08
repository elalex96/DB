
-- =============================================
-- Author:		Reyna Olvera and Luis de la Cruz
-- Create date: 14/09/17
-- Description:	extrae coordenadas para area contractual
-- =============================================
CREATE PROCEDURE [dbo].[Sp_CO_AreaContractualPozos]
	-- Add the parameters for the stored procedure here
	@idArea int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select utmx,utmy,IdEstatus,NombreInstalacion from
	 CO_Instalacion where idareacontractual =@idArea and utmx is not null and utmy is not null AND UTMX!= 0 AND UTMY!= 0;
END

