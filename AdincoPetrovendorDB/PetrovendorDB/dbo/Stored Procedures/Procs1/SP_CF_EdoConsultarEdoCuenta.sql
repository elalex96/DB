-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Se agrego validación de ISNULL(isEliminado,0)=0
-- =============================================
CREATE PROCEDURE [dbo].[SP_CF_EdoConsultarEdoCuenta]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@Anio int

AS
BEGIN
	
SELECT [IdEdoCuenta], [NombreDoc] 
FROM [CF_EdoCuentaDocumentos] 
WHERE (([IdProveedor] = @IdProveedor) AND ([Año] = @Anio) AND (ISNULL([isEliminado],0) =0))


END
