-- =============================================
-- Author:		Manuel Cruz
-- Create date: 25-01-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PvconsultarEstatusPerfil]
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COUNT(PP.IdPublicacion) AS PUBLICACIONES,  0 AS SIGUIENDO,0 AS ALIANZAS
	FROM PV_Publicacion AS PP
	INNER JOIN S_Proveedor as P ON P.IdProveedor=PP.IdProveedor
	WHERE PP.IdProveedor=@IdProveedor 

END

