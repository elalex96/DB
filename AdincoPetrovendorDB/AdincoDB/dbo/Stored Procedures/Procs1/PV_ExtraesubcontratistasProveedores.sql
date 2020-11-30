-- =============================================
-- Author:		Reyna Olvera
-- Create date: 01/06/2018
-- Description:	<Description,,>
-- =============================================
create PROCEDURE PV_ExtraesubcontratistasProveedores
	-- Add the parameters for the stored procedure here
	@idContrato int,
	@idUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select idSubcontratista, RazonSocial From [PV_Subcontratista];
END