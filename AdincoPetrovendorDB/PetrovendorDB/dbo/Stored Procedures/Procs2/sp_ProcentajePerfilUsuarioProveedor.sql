-- =============================================
-- Author:		Alexander Enriquez
-- Create date: 30/06/2017
-- Description:	Procedimiento que obtiene el porcentaje de el llenado de datos del Perfil Social del Proveedor
-- =============================================
CREATE PROCEDURE [dbo].[sp_ProcentajePerfilUsuarioProveedor] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  SELECT ((CASE WHEN NombreComercial IS NULL THEN 0 ELSE 7 END)
			+ (CASE WHEN Giro IS NULL THEN 0 ELSE 7 END)
			+ (CASE WHEN Tipo IS NULL THEN 0 ELSE 7 END)
			+ (CASE WHEN Ofrece IS NULL THEN 0 ELSE 7 END)
			+ (CASE WHEN Ramo IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN PaisOrigen IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN NumeroEmpleados IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN RegionesAtendidas IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN TelContacto IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN EmailContacto IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN Facebook IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN Twitter IS NULL THEN 0 ELSE 8 END)
			+ (CASE WHEN Skipe IS NULL THEN 0 ELSE 8 END)) AS PorcentajePerfil 
			FROM PS_Proveedor WHERE Proveedor = @IdProveedor
END
