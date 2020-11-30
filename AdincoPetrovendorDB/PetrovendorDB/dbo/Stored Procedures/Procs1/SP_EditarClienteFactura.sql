-- =============================================
-- Modificado por:		<Jose Roman>
-- Create date: <22/01/2018>
-- Description:	<Se corrige el Update del Correo para que solo actualize el registro deseado y se agregan parametros de contrato>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EditarClienteFactura] 
	@Correo NVARCHAR(100),
	@IdRelacion INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--DECLARE @IdProveedor INT 
	--SET @IdProveedor = (SELECT P.IdProveedor FROM S_Proveedor P 
	--                    INNER JOIN PV_ContratistaSubContratista CSC
	--					ON P.IdProveedor = CSC.IdSubContratista
	--					WHERE CSC.IdRelacion = @IdRelacion
	--                    )
    
   UPDATE PV_ContratistaSubContratista 
   SET
   Correo = @Correo
   where IdRelacion = @IdRelacion

END

