-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarSiExisteFacturaProveedor]
@IdProveedor      int,
@IdSubcontratista int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		select IdRelacion
	from PV_ContratistaSubContratista 
	where IdContratista = @IdSubcontratista
	and IdSubContratista = @IdProveedor
	and IsActivo = 1

END

