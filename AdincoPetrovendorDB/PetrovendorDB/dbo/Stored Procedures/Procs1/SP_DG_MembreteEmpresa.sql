-- =============================================
-- Author:		Manuel Cruz
-- Create date: 29-06-17
-- Description:	
-- =============================================
-- ============================================= 
-- Modified: DANIEL AC
-- Updated date: 03/01/2018 
-- Description: SE CAMBIO RETORNO DE IMAGEN NVARCHAR(MAX) A IMAGENPROVEEDOR  IMAGE
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_MembreteEmpresa] 
	-- Add the parameters for the stored procedure here
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	declare @sinImagen int 
	set @sinImagen = (select count(IdImagen) from S_ImagenPerfil where IdProveedor = @IdProveedor)

	IF(@sinImagen > 0)
	BEGIN
	SELECT IP.ImagenProveedor FROM S_Proveedor P
	JOIN S_ImagenPerfil IP ON P.IdProveedor = IP.IdProveedor
	WHERE IP.IdProveedor = @IdProveedor
	END
	--ELSE
	--BEGIN
	--SELECT 'VACIO' 
	--END
END
