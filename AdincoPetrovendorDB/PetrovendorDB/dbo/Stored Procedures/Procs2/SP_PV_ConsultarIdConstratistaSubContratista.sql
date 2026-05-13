-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarIdConstratistaSubContratista]
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select CS.IdRelacion,CS.IdSubContratista,P.RazonSocial,P.RFC from PV_ContratistaSubContratista CS
	inner join S_Proveedor P on CS.IdSubContratista = P.IdProveedor
	where CS.IdContratista = @IdProveedor and CS.IsActivo = 1

END

