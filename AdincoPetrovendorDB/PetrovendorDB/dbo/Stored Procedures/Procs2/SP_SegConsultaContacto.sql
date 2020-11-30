-- =============================================
-- Author:		Manuel Cruz
-- Create date: 31-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegConsultaContacto]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select IdTipoContacto as Id, NombreTipoContacto as Descripcion from S_TipoContacto
END

