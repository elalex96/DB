-- =============================================
-- Author:		<AlexanderG>
-- Create date: <11-09-2017>
-- Description:	<Consultar Cantidades de Proveedores Registrados, Activos e Inactivos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_CantidadProveedores] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;
	

    -- Insert statements for procedure here
	DECLARE @PR INT = (SELECT COUNT(IdProveedor) FROM S_Proveedor) 
	DECLARE @PA INT = (SELECT COUNT(IdProveedor) FROM S_Proveedor WHERE Activo = 1)
	DECLARE @PI INT = (SELECT COUNT(IdProveedor) FROM S_Proveedor WHERE Activo = 0)

	SELECT @PR AS REGISTRADOS, @PA AS ACTIVOS, @PI AS INACTIVOS
END

