-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE sp_EN_Frecuencia 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0, 
	@IdUsuario int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT        IdFrecuenciaEntregable, FrecuenciaEntregable
FROM            EN_FrecuenciaEntregable
END
