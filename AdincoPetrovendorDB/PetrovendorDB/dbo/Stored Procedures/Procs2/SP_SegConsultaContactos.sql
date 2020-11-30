-- =============================================
-- Author:		Manuel Cruz - Modificado Daniel AC
-- Create date: 31-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegConsultaContactos]
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT C.IdProveedor, C.IdContacto, C.IdTipoContacto, TC.NombreTipoContacto, Nombres, Apellidos, Email, Telefono, IsPredeterminado 
	FROM S_Contacto AS C
	INNER JOIN S_TipoContacto AS TC ON TC.IdTipoContacto = C.IdTipoContacto
	WHERE C.IdProveedor = @IdProveedor
END

