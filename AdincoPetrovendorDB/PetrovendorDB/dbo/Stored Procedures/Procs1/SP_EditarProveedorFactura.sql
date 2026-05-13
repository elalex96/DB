-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EditarProveedorFactura] 
@Correo NVARCHAR(100),
@IdRelacion INT
--@IdProveedor INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdProveedor INT 
	SET @IdProveedor = (SELECT P.IdProveedor FROM S_Proveedor P 
	                    INNER JOIN PV_ContratistaSubContratista CSC
						ON P.IdProveedor = CSC.IdContratista
						WHERE CSC.IdRelacion = @IdRelacion
	                    )

   UPDATE PV_ContratistaSubContratista 
   SET
   Correo = @Correo
   where IdContratista = @IdProveedor


	--UPDATE S_Proveedor 
	--SET CorreoProveedor = @CorreoProveedor
	--WHERE IdProveedor = @IdProveedor

END
